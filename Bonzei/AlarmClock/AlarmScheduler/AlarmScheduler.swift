//
//  AlarmScheduler.swift
//  Bonzei
//
//  Created by Tomasz on 05/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import UserNotifications
import AVFoundation
import MediaPlayer
import os.log

/// An alarm scheduler.
///
/// Provides a convenient API for scheduling of recurring alarms.
/// To schedule an alarm, client code must create an instance of the `Alarm` class and pass it to the scheduler
/// There is one, shared instance of the scheduler in the application. It can be accessed like so:
///
///     let scheduler = AlarmScheduler.sharedInstance
///
/// - See `NotificationExtension.swift` for the list of notifications that `AlarmScheduler` will post.
class AlarmScheduler: NSObject, AVAudioPlayerDelegate {
    
    /// A single, shared instance of the scheduler.
    /// Use it to access scheduler's API.
    public static let sharedInstance = AlarmScheduler()
    
    /// A delegate for the scheduler
    public var delegate: AlarmSchedulerDelegate?
    
    /// State of the scheduler. There are two states:
    /// - `waiting`. No alarm is being played. The scheduler is waiting for an alarm to be triggered. Can transition to `alarmTriggered`
    /// - `alarmTriggered`. An alarm has been triggered and a melody associated with it is playing. Can transition to `waiting`, `alarmSnoozed`
    /// - `alarmSnoozed`. An alarm has been snooozed. The melody is stopped. Can transition to `waiting`, `alarmTriggered`
    private(set) var state: AlarmSchedulerState = .waiting
    
    /// After an alarm has been triggered and the scheduler has entered the `alarmPlaying` state this variable will hold the relevant alarm.
    private(set) var currentlyTriggeredAlarm: Alarm?
    
    private(set) var currentlySnoozedAlarm: Alarm?
    
    public var isAlarmPlaying: Bool {
        get {
            return state == .alarmTriggered
        }
    }
    
    public var isAlarmSnoozed: Bool {
        get {
            return state == .alarmSnoozed
        }
    }
    
    let snoozeTimeMinutes = 8
    
    let numberOfLoops = 200
    
    /// All scheduled alarms
    private var scheduledAlarms = [Alarm]()
    
    private var log = OSLog(subsystem: "Alarm", category: "AlarmScheduler")
    
    /// When an alarm is triggerd,  a melody is played by the audio player
    private var audioPlayer: AVAudioPlayer?
    
    private let noLaterThanSeconds = 15
    
    // This is a singleton class, hence a private constructor
    private override init() {
        super.init()
        
        readAlarmsAndNotificationsFromDisk()
        
        // it might be that the set of available melodies changed
        // In such a case we must delete alarms that reference nonexisting melodies
        let alarmsWithMissingMelodyFiles = scheduledAlarms.filter( { alarm in !melodies.contains(alarm.melodyName) && alarm.melodyName != "Shuffle" })
        alarmsWithMissingMelodyFiles.forEach({ alarm in self.unscheduleAlarm(withId: alarm.id) })

    }
    
    //MARK: - Public API
    
    /// Schedules a given alarm.
    ///
    /// If an alarm with the same id is already scheduled, the request is ignored. Use `AlarmScheduler.update()` to reschedule an existing alarm.
    ///
    /// - Parameter alarm : an Alarm to be scheduled.
    ///
    public func schedule(alarm: Alarm) {
        os_log("Will add a new alarm to the scheduler.", log: log, type: .info)
        guard !isScheduledAlarm(withId: alarm.id) else {
            return
        }
        
        var newAlarm = alarm
        newAlarm.lastUpdateDate = Date()
        
        scheduledAlarms.append(alarm)
        sortAlarms()
        
        AlarmPersistenceService.sharedInstance.create(alarm: newAlarm)
        
        if !newAlarm.isActive {
            os_log("Added a new alarm to the scheduler. The alarm is inactive.", log: log, type: .info)
            return
        }
        
        os_log("Added a new alarm to the scheduler. The alarm is active.", log: log, type: .info)
    }

    /// Removes an alarm from the scheduler.
    ///
    /// All pending notifications associated with the alarm are immediately canceled
    /// If `id` is not registered in the scheduler, the request is ignored.
    ///
    /// - Parameter id: identifier of the alarm that you wish to unschedule
    ///
    public func unscheduleAlarm(withId alarmId: String) {
        guard indexOfAlarm(withId: alarmId) != nil else { return }

        scheduledAlarms = scheduledAlarms.filter({ $0.id != alarmId })
    
        AlarmPersistenceService.sharedInstance.deleteAlarm(withId: alarmId)
        
        os_log("Unscheduled an alarm.", log: log, type: .info)
    }
    
    /// Returns all scheduled alarms .
    ///
    /// - Returns: an array of `Alarm` objects that represent scheduled alarms.
    ///
    public func allAlarms() -> [Alarm] {
        return scheduledAlarms
    }
    
    /// Reschedules a given alarm.
    ///
    /// Once an alarm has been added to the scheduler using the `schedule()` method it can be rescheduled using the `reschedule()` method.
    /// If an alarm with identifier`id` is not in the scheduler, the request is ignored.
    /// If `alarm.isActive` is false, the alarm will remain in the scheduler, but all related notifications will be immediately canceled.
    /// The same is true if `alarm.repeatOn` is empty.
    ///
    /// - Parameter id: unique identifier of the alarm you wish to reschedule.
    /// - Parameter alarm: provides values that will be used to update the existing alarm.
    ///
    public func updateAlarm(withId alarmId: String, using alarm: Alarm) {
        os_log("Will update an alarm.", log: log, type: .info)
        
        guard let _ = indexOfAlarm(withId: alarmId) else { return }
        
        let updatedAlarm = Alarm(id: alarmId,
                                 date: alarm.date,
                                 snoozeDate: nil,
                                 repeatOn: alarm.repeatOn,
                                 melodyName: alarm.melodyName,
                                 snoozeEnabled: alarm.snoozeEnabled,
                                 isActive: alarm.isActive,
                                 lastTriggerDate: nil,
                                 lastUpdateDate: Date())
        
        
        refreshAlarm(updatedAlarm)
        
        sortAlarms()
        
        if (!alarm.isActive) {
            os_log("Updated an alarm. The alarm is inactive.", log: log, type: .info)
            return
        }
        
        os_log("Updated an alarm. The alarm is active", log: log, type: .info)
    }
    
    /// Indicates whether an alarm is scheduled.
    ///
    /// - Returns: a boolean value indicating whether the alarm is scheduled (`true`) or not (`false`)
    ///
    public func isScheduledAlarm(withId id: String) -> Bool {
        return indexOfAlarm(withId: id) != nil
    }
    
    internal func checkAndTriggerAlarms() {
        let nowDate = Date()
        let now = Calendar.current.dateComponents([.weekday, .hour, .minute, .second], from: nowDate)
        
        let alarms: [Alarm] = scheduledAlarms.filter({ alarm in
            
            let repeatOn = alarm.repeatOn.map({ dayOfWeek in return (dayOfWeek + 1) % 7 + 1})
            let hasCorrectWeekday = repeatOn.contains(now.weekday!) || alarm.isOneTime
            
            var hasNotTriggerdAlready = false
            if alarm.lastTriggerDate == nil {
                hasNotTriggerdAlready = true
            } else {
                let result = Calendar
                    .current
                    .compare(nowDate, to: alarm.lastTriggerDate!, toGranularity: .day)
                hasNotTriggerdAlready = result != .orderedSame
            }
            
            return ( alarm.isActive && hasCorrectWeekday && hasNotTriggerdAlready ) || alarm.isSnoozed
            
        })
        
        for alarm in alarms {
            let snoozeExpired = shouldTriggerSnoozedAlarm(alarm, now: nowDate)
            
            if snoozeExpired {
                triggerSnoozedAlarm(alarm)
            } else if (alarm.hour == now.hour && alarm.minute == now.minute && now.second! < noLaterThanSeconds && !alarm.isSnoozed) {
                triggerAlarm(alarm)
            }
        }
    }
    
    public func dismissAlarm() {
        os_log("Will dismiss an alarm", log: log, type: .info)
        
        guard state == .alarmTriggered || state == .alarmSnoozed else {
            os_log("There's no alarm to dismiss. No alarm is currently triggered nor snoozed", log: log, type: .info)
            return
        }
        
        var dismissedAlarm = currentlyTriggeredAlarm
        
        if state == .alarmSnoozed {
            dismissedAlarm = currentlySnoozedAlarm
            dismissCurrentlySnoozedAlarm()
            
            os_log("Dismissed the currently snoozed alarm", log: log, type: .info)
        } else {
            currentlyTriggeredAlarm = nil
            stopAudioPlayer()
            deactivateAudioSession()
            
            os_log("Dismissed the currently playing alarm", log: log, type: .info)
        }
        
        state = .waiting
        
        HeartBeatService.sharedInstance.start()
        
        delegate?.didDismissAlarm(dismissedAlarm!)
        NotificationCenter.default.post(name: .didDismissAlarm, object: self, userInfo: ["alarm": dismissedAlarm!])
    }
    
    /// Snooze currently triggered alarm
    public func snooze() {
        os_log("Will snooze currently triggered alarm", log: log, type: .info)
        
        guard state == .alarmTriggered && currentlyTriggeredAlarm != nil else {
            os_log("There's no alarm to snooze. No alarm is currently triggered")
            return
        }
        
        let i = indexOfAlarm(withId: currentlyTriggeredAlarm!.id)!
        
        scheduledAlarms[i].snoozeDate = Date().new(byAdding: .minute, value: snoozeTimeMinutes)
        
        let alarmToSnooze = scheduledAlarms[i]
        
        AlarmPersistenceService.sharedInstance.updateAlarm(withId: alarmToSnooze.id, using: alarmToSnooze)
        
        state = .alarmSnoozed
        currentlyTriggeredAlarm = nil
        currentlySnoozedAlarm = alarmToSnooze
        
        stopAudioPlayer()
        deactivateAudioSession()
        
        HeartBeatService.sharedInstance.start()
        
        delegate?.didSnoozeAlarm(alarmToSnooze)
        NotificationCenter.default.post(name: .didSnoozeAlarm, object: self, userInfo: ["alarm": alarmToSnooze])
       
        os_log("Alarm snoozed", log: log, type: .info)
    }
    
    /// Cancels snooze for every snoozed alarm. It has no effect if no alarm is snoozed.
    public func cancelSnooze() {
        os_log("Will cancel all snoozed alarms", log: log, type: .info)
        
        var countSnoozedAlarms = 0
        
        for var alarm in scheduledAlarms {
            if alarm.snoozeDate != nil {
                alarm.snoozeDate = nil
                
                if !alarm.isRecurring {
                    alarm.isActive = false
                }
                
                refreshAlarm(alarm)
                
                countSnoozedAlarms += 1
            }
        }
        
        if countSnoozedAlarms > 0 {
            os_log("Did cancel snoozed alarms. Number of snoozes canceled: %{public}d", log: log, type: .info, countSnoozedAlarms)
        } else {
            os_log("There aren't any snoozed alarms.", log: log, type: .info)
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        os_log("Finished playing the melody.", log: log, type: .info)
        snooze()
    }
    
    // MARK: - Private API
    
    private func sendNotificationNow(title: String, body: String) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) else { return }
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.categoryIdentifier = "alarm"
            content.sound = .none
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger)
            
            center.add(request, withCompletionHandler: nil)
        }
    }
    
    private func triggerAlarm(_ alarmToTrigger: Alarm) {
        os_log("Triggering alarm", log: log, type: .info)
        
        if state == .alarmSnoozed {
            os_log("There is a snoozed alarm. Dissmissing it.", log: log, type: .info)
            dismissCurrentlySnoozedAlarm()
        }
        
        var alarm = alarmToTrigger
        
        state = .alarmTriggered
        
        alarm.lastTriggerDate = Date()
        alarm.snoozeDate = nil
        refreshAlarm(alarm)
        
        self.currentlyTriggeredAlarm = alarm
        
        playAlarm(alarm)
        
        delegate?.didTriggerAlarm(alarm)
        
        NotificationCenter.default.post(name: .didTriggerAlarm, object: self, userInfo: ["alarm": alarm])
    }
    
    private func triggerSnoozedAlarm(_ alarmToTrigger: Alarm) {
        os_log("Triggering a snoozed alarm", log: log, type: .info)
        
        var alarm = alarmToTrigger
        alarm.lastTriggerDate = Date()
        alarm.snoozeDate = nil
        
        if alarm.isOneTime {
            alarm.isActive = false
        }

        refreshAlarm(alarm)
        
        if state == .alarmTriggered {
             // There already is a new alarm playing. Snooze must be ignored
            os_log("A different alarm is already triggered. Triggering the snoozed alarm is canceled.", log: log, type: .info)
            return
         }
        
        state = .alarmTriggered
        
        self.currentlyTriggeredAlarm = alarm
        self.currentlySnoozedAlarm = nil
        
        playAlarm(alarm)
        
        delegate?.didTriggerAlarm(alarm)
        
        // post didTriggerAlarm notification
        NotificationCenter.default.post(name: .didTriggerAlarm, object: self, userInfo: ["alarm": alarm])
    }
    
    private func dismissCurrentlySnoozedAlarm() {
        guard currentlySnoozedAlarm != nil else { return }
        
        let i = indexOfAlarm(withId: currentlySnoozedAlarm!.id)!
        
        scheduledAlarms[i].snoozeDate = nil
        refreshAlarm(scheduledAlarms[i])
        currentlySnoozedAlarm = nil
    }
    
    private func refreshAlarm(_ alarm: Alarm) {
        AlarmPersistenceService
            .sharedInstance
            .updateAlarm(withId: alarm.id, using: alarm)
        
        let i = indexOfAlarm(withId: alarm.id)!
        scheduledAlarms[i] = alarm
    }
    
    /// cancel all pending notifications
    private func cancelAllNotifications() {
        UNUserNotificationCenter
            .current()
            .removeAllPendingNotificationRequests()
        
        AlarmPersistenceService.sharedInstance.deleteAllNotificationRequests()
    }
    
    /// sorts the `scheduledAlarms` array
    private func sortAlarms() {
        scheduledAlarms.sort() { alarmA, alarmB in
            if alarmA.hour == alarmB.hour {
                return alarmA.minute < alarmB.minute
            } else {
                return alarmA.hour < alarmB.hour
            }
        }
    }
    /// Finds an alarm given by `id` in the internal `scheduledAlarms` array.
    private func indexOfAlarm(withId id: String) -> Int? {
        return scheduledAlarms.firstIndex(where: {$0.id == id})
    }
    
    /// Loads alarms, and notification requests into memory
    private func readAlarmsAndNotificationsFromDisk() {
        scheduledAlarms = [Alarm]()
        
        let dao = AlarmPersistenceService.sharedInstance
        
        guard let persistedAlarms = dao.readAllAlarms() else { return }
        
        scheduledAlarms = persistedAlarms
        sortAlarms()
    }
    
    private func playAlarm(_ alarm: Alarm) {
        var soundFileName = alarm.melodyName + ".mp3"
        if alarm.melodyName == "Shuffle" {
            soundFileName = melodies[Int.random(in: 0..<melodies.count)] + ".mp3"
        }
        sendNotificationNow(title: "Wake up", body: soundFileName)
        playAudio(fileName: soundFileName, numberOfLoops: numberOfLoops)
    }
    
    private func shouldTriggerSnoozedAlarm(_ alarm: Alarm, now: Date) -> Bool {
        guard let snoozeDate = alarm.snoozeDate else { return false }
        
        let timeIntervalSinceNow = Int(snoozeDate.timeIntervalSinceNow)
        return timeIntervalSinceNow <= 0 && timeIntervalSinceNow >= (-1 * noLaterThanSeconds)
    }
    
    private func playAudio(fileName: String, numberOfLoops: Int) {
        if audioPlayer != nil && audioPlayer!.isPlaying{
            stopAudioPlayer()
        }
        
        os_log("Will play melody now.", log: log, type: .info)
        
        // Play the selected melody
        let path = Bundle.main.path(forResource: fileName, ofType: nil)
            
        let url = URL(fileURLWithPath: path!)
        
        HeartBeatService.sharedInstance.stop()
        
       
        let audioSession = AVAudioSession.sharedInstance()
            
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [ .duckOthers])
        } catch let error as NSError {
            os_log("Setting a category for alarm playback failed: %{public}s", log: log, type: .error, error.localizedDescription)
        }
        
        do {
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch let error as NSError {
            os_log("Overriding output audio port to 'speaker' failed: %{public}s ", log: log, type: .error, error.localizedDescription )
        }
        
        do {
            try audioSession.setActive(true)
        } catch let error as NSError {
            os_log("Activating audio session for alarm playback failed: %{public}s", log: log, type: .error, error.localizedDescription)
        }
            
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.numberOfLoops = numberOfLoops
            audioPlayer?.setVolume(1.0, fadeDuration: 1)
            audioPlayer?.play()
        } catch let error as NSError {
            os_log("Playing an audio file failed. %{public}s failed: %{public}s", log: log, type: .error, error.localizedDescription)
        }
    }
    
    private func stopAudioPlayer() {
        if audioPlayer != nil && audioPlayer!.isPlaying {
            let queue = DispatchQueue(label: "StopAudio", qos: .userInteractive)
             queue.async {
                self.audioPlayer!.setVolume(0, fadeDuration: 0.05)
                Thread.sleep(forTimeInterval: 0.1)
                self.audioPlayer!.stop()
                self.audioPlayer = nil
             }
        }
    }
    
    private func deactivateAudioSession() {
        do {
          try  AVAudioSession.sharedInstance().setActive(false)
        } catch let error as NSError {
            os_log("Deactivating audio session for alarm playback failed: %{public}s", log: log, type: .error, error.localizedDescription)
        }
    }
    
    func purge() {
        cancelAllNotifications()
        AlarmPersistenceService.sharedInstance.deleteAllAlarms() //Deletes all notification requests as well through 'cascade' rule.
    }
    
    func dbg_log(_ msg: String) {
        os_log("%{public}s\n", log: log, type: .info, msg)
    }
    
    func dump() {
        var s = "\n"
        s+="--------------------Alarm--------------------\n"
        for alarm in scheduledAlarms {
            
            s+="{\n"
            s+="    \(alarm.dateString)\n"
            s+="    \(alarm.melodyName)\n"
            s+="}\n"
        }
        dbg_log(s)
    }
    
    func dumpNotifications() {
        var s = "\n"
        s+="--------------------Notification Requests --------------------\n"
        UNUserNotificationCenter.current().getPendingNotificationRequests() {
            notificationRequests in
            
            s+="[\n"
            for req in notificationRequests {
                let trigger = req.trigger as! UNCalendarNotificationTrigger
                s+="    \(req.identifier) \(trigger.nextTriggerDate()!) \(req.content.body)\n"
            }
            s+="]\n"
            
            self.dbg_log(s)
        }
    }
}

public enum AlarmSchedulerState {
    case waiting
    case alarmTriggered
    case alarmSnoozed
}
