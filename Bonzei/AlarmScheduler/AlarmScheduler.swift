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
import os.log

/// An alarm scheduler.
///
/// Provides a convenient API for scheduling of recurring alarms.
/// Rrelies on services provided by the`UNUserNotificationCenter`
/// To schedule an alarm, client code must create an instance of the `Alarm` class and pass it to the scheduler
/// There is one, shared instance of the scheduler in the application. It can be accessed like so:
///
///     let scheduler = AlarmScheduler.sharedInstance
///
class AlarmScheduler: NSObject, AVAudioPlayerDelegate {
    
    /// A single, shared instance of the scheduler.
    /// Use it to access scheduler's API.
    static let sharedInstance = AlarmScheduler()
    
    /// A delegate for the scheduler
    var delegate: AlarmSchedulerDelegate?
    
    /// State of the scheduler. There are two states:
    /// - `waiting`. No alarm is being played. The scheduler is waiting for an alarm to be triggered.
    /// - `alarmTriggered`. An alarm has been triggered and a melody associated with it is playing.
    private(set) var state: AlarmSchedulerState = .waiting
    
    /// After an alarm has been triggered and the scheduler has entered the `alarmPlaying` state this variable will hold the relevant alarm.
    private(set) var currentlyTriggeredAlarm: Alarm?
    
    var isAlarmPlaying: Bool {
        get {
            return state == .alarmTriggered
        }
    }
    
    /// All scheduled alarms
    private var scheduledAlarms = [Alarm]()
    
    private var log = OSLog(subsystem: "Alarm", category: "AlarmScheduler")
    
    /// When an alarm is triggerd,  a melody is played by the audio player
    var audioPlayer: AVAudioPlayer?
    
    // This is a singleton class, hence a private constructor
    private override init() {
        super.init()
        
        readAlarmsAndNotificationsFromDisk()
        dump()
        dumpNotifications()
    }
    
    /// Schedules a given alarm.
    ///
    /// If an alarm with the same id is already scheduled, the request is ignored. Use `AlarmScheduler.update()` to reschedule an existing alarm.
    ///
    /// The alarm will ring on every weekday specified by `Alarm.repeatOn` at time specified by `Alarm.date`.
    /// Only the time component of `Aalarm.date` is taken into consideration. Other components (`year`, `month`, `day of month`)  are ignored.
    /// This means, it is impossible to schedule an alarm to ring once on a given date.
    ///
    /// If `Alarm.repeatOn` is empty, the alarm is added to the scheduler, but will not be scheduled for execution.
    /// Similarly, if `Alarm.isActive` is false, the alarm is added to the scheduler, but will not be scheduled for execution.
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
        
        scheduledAlarms.insert(newAlarm, at: 0)
        AlarmPersistenceService.sharedInstance.create(alarm: newAlarm)
        
        if !newAlarm.isActive {
            os_log("Added a new alarm to the scheduler. The alarm is inactive.", log: log, type: .info)
            return
        }
        
        ifNotificationsAreAllowed {
            self.setupNotificationsForAlarm(newAlarm)
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
        
        cancelNotificationsForAlarm(withId: alarmId)
    
        scheduledAlarms = scheduledAlarms.filter({ $0.id != alarmId })
    
        AlarmPersistenceService.sharedInstance.deleteAlarm(withId: alarmId)
        
        print("Scheduler: removed alarm: \(alarmId)")
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
            let hasCorrectWeekday = repeatOn.contains(now.weekday!) || !alarm.isRecurring
            
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
        
        for var alarm in alarms {
            let snoozeExpired = shouldTriggerSnoozedAlarm(alarm, now: nowDate)
            
            if snoozeExpired || (alarm.hour == now.hour && alarm.minute == now.minute && now.second! < 15 && !alarm.isSnoozed) {
                
                if snoozeExpired {
                    os_log("Triggering a snoozed alarm", log: log, type: .info)
                } else {
                    os_log("Triggering alarm", log: log, type: .info)
                }
                
                state = .alarmTriggered
                
                alarm.lastTriggerDate = Date()
                
                alarm.snoozeDate = nil
                
                // if this is a one time alarm, make sure we change it to inactive and remove related notification requests.
                if !alarm.isRecurring {
                    alarm.isActive = false
                }
                
                refreshAlarm(alarm)
                
                self.currentlyTriggeredAlarm = alarm
                
                delegate?.didTriggerAlarm(alarm)
                
                // post didTriggerAlarm notification
                NotificationCenter.default.post(name: .didTriggerAlarm, object: self, userInfo: ["alarm": alarm])
                
                playAlarm(alarm)
            }
        }
    }
    
    public func dismissAlarm() {
        os_log("Will dismiss currently triggered alarm", log: log, type: .info)
        
        guard state == .alarmTriggered else {
            os_log("There's no alarm to dismiss. No alarm is currently triggered")
            return
        }
        
        state = .waiting
        currentlyTriggeredAlarm = nil
        
        stopAudioPlayer()
        
        os_log("Alarm dismissed", log: log, type: .info)
    }
    
    /// Snooze currently triggered alarm
    public func snooze() {
        os_log("Will snooze currently triggered alarm", log: log, type: .info)
        
        guard state == .alarmTriggered && currentlyTriggeredAlarm != nil else {
            os_log("There's no alarm to snooze. No alarm is currently triggered")
            return
        }
        
        let i = indexOfAlarm(withId: currentlyTriggeredAlarm!.id)!
        
        scheduledAlarms[i].snoozeDate = Date().new(byAdding: .minute, value: 2)
        
        let alarmToSnooze = scheduledAlarms[i]
        
        AlarmPersistenceService.sharedInstance.updateAlarm(withId: alarmToSnooze.id, using: alarmToSnooze)
        
        state = .waiting
        currentlyTriggeredAlarm = nil
        
        stopAudioPlayer()
        
        ifNotificationsAreAllowed {
            let content = self.prepareNotificationContentForAlarm(alarmToSnooze)

            let trigger = self.prepareNotificationTriggerForSnooze(alarmToSnooze)
            
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger)

            self.requestNotificationForAlarm(alarmToSnooze, request: request)
        }
        
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
            os_log("There aren't any snoozed alarms.")
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        os_log("Finished playing a melody for an alarm", log: log, type: .info)
        dismissAlarm()
    }
    
    // MARK: - Helper functions
    
    private func ifNotificationsAreAllowed(run: @escaping () -> Void) {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .sound, .badge] ) { granted, error in
                guard granted == true && error == nil else {
                    return
                }
                
                run()
        }
    }
    
    private func setupNotificationsForAlarm(_ alarm: Alarm) {
        if alarm.isRecurring {
            setupRecurringNotificationsForAlarm(alarm)
        } else {
            setupOneTimeNotificationForAlarm(alarm)
        }
    }
    
    /// Setup one time notification request for a given alarm
    ///
    /// - Parameter alarm: an alarm for which you want to request a notification.
    ///
    private func setupOneTimeNotificationForAlarm(_ alarm: Alarm) {
        let content = prepareNotificationContentForAlarm(alarm)
        
        let trigger = prepareNotificationTriggerForOneTimeAlarm(alarm)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger)
        
        requestNotificationForAlarm(alarm, request: request)
    }
    
    /// Setup  recurring notifications for a given alarm
    ///
    /// - Parameter alarm: an alarm for which notifications need to be added.
    ///
    private func setupRecurringNotificationsForAlarm(_ alarm: Alarm) {
        let content = prepareNotificationContentForAlarm(alarm)

        for dayOfWeek in alarm.repeatOn {
            
            let datePattern = DateComponents(
                timeZone: .current,
                hour: alarm.hour,
                minute: alarm.minute,
                weekday: (dayOfWeek + 1) % 7 + 1)
            
            let trigger = UNCalendarNotificationTrigger (dateMatching: datePattern, repeats: true)
            
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger)
            
            requestNotificationForAlarm(alarm, request: request)
        }
    }
    
    private func requestNotificationForAlarm(_ alarm: Alarm, request: UNNotificationRequest) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        let dao = AlarmPersistenceService.sharedInstance
        
        notificationCenter.add(request) { error in
            guard error == nil else { return }
            
            dao.createNotificationRequest(NotificationRequest(identifier: request.identifier, alarmId: alarm.id))
        }
    }
    
    private func refreshAlarm(_ alarm: Alarm) {
        let dao = AlarmPersistenceService.sharedInstance
        
        // 1. Update the alarm in the database
        dao.updateAlarm(withId: alarm.id, using: alarm)
        
        let i = indexOfAlarm(withId: alarm.id)!
        scheduledAlarms[i] = alarm
        
        // 2. Cancel all pending notifications
        cancelNotificationsForAlarm(withId: alarm.id)
        dao.deleteNotificationRequestsForAlarm(withId: alarm.id)
        
        // 3. Setup notifications anew
        ifNotificationsAreAllowed {
            guard alarm.isActive else { return }
            
            self.setupNotificationsForAlarm(alarm)
        }
    }
    
    /// Cancel  pending notifications for a given alarm.
    private func cancelNotificationsForAlarm(withId alarmId: String) {
        guard let notificationRequests = getNotificationRequestsForAlarm(withId: alarmId) else  {
            return
        }
        
        let notificationRequestIds:[String] = notificationRequests.map({ return $0.identifier })
        
        UNUserNotificationCenter
            .current()
            .removePendingNotificationRequests(withIdentifiers: notificationRequestIds)
    }
    
    /// cancel all pending notifications
    private func cancelAllNotifications() {
        UNUserNotificationCenter
            .current()
            .removeAllPendingNotificationRequests()
        
        AlarmPersistenceService.sharedInstance.deleteAllNotificationRequests()
    }
    
    private func prepareNotificationContentForAlarm(_ alarm: Alarm) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Wake up"
        content.body = alarm.melodyName
        content.categoryIdentifier = "alarm"
        content.sound = .none
        return content
    }
    
    private func prepareNotificationTriggerForOneTimeAlarm(_ alarm: Alarm) -> UNCalendarNotificationTrigger {
        let now = Date()
        
        var triggerDate = now
            .new(bySetting: .hour, to: alarm.hour)
            .new(bySetting: .minute, to: alarm.minute)
            .new(bySetting: .second, to: 0)

        if now.hour > alarm.hour ||
           (now.hour == alarm.hour && now.minute >= alarm.minute) {
            triggerDate = triggerDate.new(byAdding: .day, value: 1)
        }
        
        let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        
        return UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
    }
    
    private func prepareNotificationTriggerForSnooze(_ alarm: Alarm) -> UNCalendarNotificationTrigger {
        let triggerDateComponents = Calendar
            .current
            .dateComponents([.year, .month, .day, .hour, .minute], from: alarm.snoozeDate!)
        
        return UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
    }
    
    /// Finds an alarm given by `id` in the internal `scheduledAlarms` array.
    ///
    private func indexOfAlarm(withId id: String) -> Int? {
        return scheduledAlarms.firstIndex(where: {$0.id == id})
    }
    
    /// Loads alarms, and notification requests into memory
    private func readAlarmsAndNotificationsFromDisk() {
        scheduledAlarms = [Alarm]()
        
        let dao = AlarmPersistenceService.sharedInstance
        
        guard let persistedAlarms = dao.readAllAlarms() else { return }
        
        scheduledAlarms = persistedAlarms
    }
    
    private func getNotificationRequestsForAlarm(withId alarmId: String) -> [NotificationRequest]? {
        let dao = AlarmPersistenceService.sharedInstance
        
        guard let persistedNotificationRequests = dao.readNotificationRequestsForAlarm(withId: alarmId) else {
            return nil
        }
        
        var notificationRequests = [NotificationRequest]()
        
        persistedNotificationRequests.forEach({notificationRequest in
            notificationRequests.append(notificationRequest)
        })
        
        return notificationRequests
    }
    
    private func playAlarm(_ alarm: Alarm) {
        
        if audioPlayer != nil && audioPlayer!.isPlaying{
            os_log("Will not play melody for the current alarm. A previous alarm is still playing.", log: log, type: .info)
            return
        }
        
        os_log("Will play melody now.", log: log, type: .info)
        
        // Play the selected melody
        let path = Bundle.main.path(forResource: alarm.melodyName + ".mp3", ofType: nil)
            
        let url = URL(fileURLWithPath: path!)
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            os_log("Activating session failed: %{public}s", log: log, type: .error, error.localizedDescription)
        }
            
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.numberOfLoops = 5
            audioPlayer?.setVolume(1.0, fadeDuration: 1)
            audioPlayer?.play()
        } catch let error as NSError {
            os_log("Playing melody for alarm %{public}s failed: %{public}s", log: log, type: .error, error.localizedDescription)
            
        }
    }
    
    private func shouldTriggerSnoozedAlarm(_ alarm: Alarm, now: Date) -> Bool {
        guard let snoozeDate = alarm.snoozeDate else { return false }
        
        return now.equals(snoozeDate, toGranularity: .minute)
    }
    
    private func stopAudioPlayer() {
        if audioPlayer != nil && audioPlayer!.isPlaying {
            audioPlayer!.stop()
            audioPlayer = nil
        }
    }
    
    func purge() {
        cancelAllNotifications()
        AlarmPersistenceService.sharedInstance.deleteAllAlarms() //Deletes all notification requests as well through 'cascade' rule.
    }
    
    func dump() {
        print("")
        print("--------------------ALARMS--------------------")
        for alarm in scheduledAlarms {
            
            let notificationRequests = getNotificationRequestsForAlarm(withId: alarm.id)!
            
            let requests:[String] = notificationRequests.map({ return $0.identifier })
            
            print("{")
            print("    \(alarm.dateString)")
            print("    \(alarm.melodyName)")
            print("    Notifications:")
            print("    [")
            for notificationRequestId  in requests {
                print("        \(notificationRequestId)")
            }
            print("    ]")
            print("}")
        }
    }
    
    func dumpNotifications() {
        print("")
        print("--------------------Notification Requests --------------------")
        UNUserNotificationCenter.current().getPendingNotificationRequests() {
            notificationRequests in
            
            print("[")
            for req in notificationRequests {
                let trigger = req.trigger as! UNCalendarNotificationTrigger
                print("    \(req.identifier) \(trigger.nextTriggerDate()) \(req.content.body)")
            }
            print("]")
            
        }
    }
}

enum AlarmSchedulerState {
    case waiting
    
    case alarmTriggered
}
