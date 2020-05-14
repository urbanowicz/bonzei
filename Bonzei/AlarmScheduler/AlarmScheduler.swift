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

/// An alarm scheduler.
///
/// Provides a convenient API for scheduling of recurring alarms.
/// Under the hood, it relies on services provided by the`UNUserNotificationCenter`
/// To schedule an alarm, client code must create an instance of the `Alarm` class and pass it to the scheduler
/// There is one, shared instance of the scheduler in the application. It can be accessed like so:
///
///     let scheduler = AlarmScheduler.sharedInstance
///
///
class AlarmScheduler {
    
    /// A single, shared instance of the scheduler.
    /// Use it to access scheduler's API.
    static let sharedInstance = AlarmScheduler()
    
    /// All scheduled alarms
    private var scheduledAlarms = [Alarm]()
    
    /// Maps `alarmId` to all`requestNotificationId`identifiers associated with this alarm.
    private var notificationRequests = [ String: Set<String> ]()
    
    private let alarmsPersistenceFile = "alarms.db"
    
    /// When an alarm is triggerd,  a melody is played by the audio player
    var audioPlayer: AVAudioPlayer?
    
    // This is a singleton class, hence a private constructor
    private init() {
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
        guard !isScheduledAlarm(withId: alarm.id) else {
            return
        }
        
        scheduledAlarms.insert(alarm, at: 0)
        AlarmPersistenceService.sharedInstance.create(alarm: alarm)
        
        if !alarm.isActive || alarm.repeatOn.isEmpty {
            print("Scheduler: added an inactive alarm: \(alarm.id)")
            return
        }
        
        ifNotificationsAreAllowed {
            self.addNotification(forAlarm: alarm)
            print("Scheduler: added alarm: \(alarm.id)")
        }
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
        
        guard let i = indexOfAlarm(withId: alarmId) else { return }
        
        let updatedAlarm = Alarm(id: alarmId,
                                 date: alarm.date,
                                 repeatOn: alarm.repeatOn,
                                 melodyName: alarm.melodyName,
                                 snoozeEnabled: alarm.snoozeEnabled,
                                 isActive: alarm.isActive,
                                 lastTriggerDate: nil)
        
        let dao = AlarmPersistenceService.sharedInstance
        
        scheduledAlarms[i] = updatedAlarm
        dao.updateAlarm(withId: alarmId, using: updatedAlarm)
        
        cancelNotificationsForAlarm(withId: alarmId)
        dao.deleteNotificationRequestsForAlarm(withId: updatedAlarm.id)
        
        if (!alarm.isActive || alarm.repeatOn.isEmpty) {
            print("Scheduler: Alarm: \(alarmId) updated to inactive")
            return
        }
        
        ifNotificationsAreAllowed {
            self.addNotification(forAlarm: updatedAlarm)
            print("Scheduler: updated alarm: \(alarmId)")
        }
        
    }
    
    /// Indicates whether an alarm is scheduled.
    ///
    /// - Returns: a boolean value indicating whether the alarm is scheduled (`true`) or not (`false`)
    ///
    public func isScheduledAlarm(withId id: String) -> Bool {
        return indexOfAlarm(withId: id) != nil
    }
    
    /// Cancels all pending notifications.
    /// Then, for each active alarm requests a new notification to be scheduled.
    public func rescheduleAllAlarms() {
        cancelAllNotifications()
        AlarmPersistenceService.sharedInstance.deleteAllNotificationRequests()
        
        ifNotificationsAreAllowed {
            let activeAlarms:[Alarm] = self.scheduledAlarms.filter({ $0.isActive })
            activeAlarms.forEach({ alarm in self.addNotification(forAlarm: alarm) })
        }
    }
    
    public func checkAndRunAlarms() {
        let nowDate = Date()
        let now = Calendar.current.dateComponents([.weekday, .hour, .minute, .second], from: nowDate)
        
        //Only active alarms
        var alarms: [Alarm] = scheduledAlarms.filter({ alarm in alarm.isActive})
        
        //Only alarms that have the right weekday
        alarms = alarms.filter({ alarm in
            let repeatOn = alarm.repeatOn.map({ dayOfWeek in return (dayOfWeek + 1) % 7 + 1})
            return repeatOn.contains(now.weekday!)
        })
        
        //Only alarms that haven't been triggered today
        alarms = alarms.filter({alarm in
            if alarm.lastTriggerDate == nil {
                return true
            }
            let result = Calendar
                .current
                .compare(nowDate, to: alarm.lastTriggerDate!, toGranularity: .day)
            return result != .orderedSame
        })
        
        for alarm in alarms {
            let triggerDate = Calendar
                .current
                .dateComponents([.hour, .minute], from: alarm.date)
            if (triggerDate.hour == now.hour && triggerDate.minute == now.minute && now.second! < 15) {
                print("{")
                print("Triggering alarm:  \(alarm.string())")
                print("}")
                let i = indexOfAlarm(withId: alarm.id)!
                scheduledAlarms[i].lastTriggerDate = Date()
                
                AlarmPersistenceService
                    .sharedInstance
                    .updateAlarm(withId: alarm.id, using: scheduledAlarms[i])
                
                playAlarm(alarm)
            }
        }
    }
    
    //MARK: - Helper functions
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
    
    /// Schedule necessary notifications for a given alarm
    ///
    /// - Parameter alarm: an alarm for which notifications need to be added.
    ///
    private func addNotification(forAlarm alarm: Alarm) {
        
        // We will store ids of notifications requests in the set
        if notificationRequests[alarm.id] == nil {
            notificationRequests[alarm.id] = Set<String>()
        }
        
        // A short name for the notification center
        let center = UNUserNotificationCenter.current()
        
        // A short name for the alarm persistence service
        let dao = AlarmPersistenceService.sharedInstance
        
        // 1. Content
        let content = UNMutableNotificationContent()
        content.title = "Wake up"
        content.body = alarm.melodyName
        content.categoryIdentifier = "alarm"
        content.sound = .none

        for dayOfWeek in alarm.repeatOn {
            //2. Trigger
            var datePattern = Calendar.current.dateComponents([.hour, .minute, .timeZone], from: alarm.date)
            datePattern.weekday = (dayOfWeek + 1) % 7 + 1
            
            let trigger = UNCalendarNotificationTrigger (dateMatching: datePattern, repeats: true)
            
            //3. Request
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger)
            
            center.add(request) { error in
                guard error == nil else { return }
                    
                self.notificationRequests[alarm.id]!.insert(request.identifier)
                
                let notificationRequest = NotificationRequest(
                        identifier: request.identifier,
                        alarmId: alarm.id
                )
                
                dao.createNotificationRequest(notificationRequest)
                    
                print("Scheduler: added notification for the weekday: \(datePattern.weekday!)")
            }
        }
    }
    
    /// Cancel  pending notifications for a given alarm.
    private func cancelNotificationsForAlarm(withId alarmId: String) {
        guard notificationRequests[alarmId] != nil else {
            return
        }
        
        guard notificationRequests[alarmId]!.count > 0 else {
            return
        }
        
        UNUserNotificationCenter
            .current()
            .removePendingNotificationRequests(withIdentifiers: Array(notificationRequests[alarmId]!))
        
        notificationRequests.removeValue(forKey: alarmId)
        
        print("Scheduler: canceled notifications for alarm: \(alarmId)")
    }
    
    /// cancel all pending notifications
    private func cancelAllNotifications() {
        UNUserNotificationCenter
            .current()
            .removeAllPendingNotificationRequests()
        
        notificationRequests.removeAll()
    }
    
    /// Finds an alarm given by `id` in the internal `scheduledAlarms` array.
    ///
    private func indexOfAlarm(withId id: String) -> Int? {
        return scheduledAlarms.firstIndex(where: {$0.id == id})
    }
    
    /// Loads alarms, and notification requests into memory
    private func readAlarmsAndNotificationsFromDisk() {
        scheduledAlarms = [Alarm]()
        
        notificationRequests = [String: Set<String>]()
        
        let dao = AlarmPersistenceService.sharedInstance
        
        guard let persistedAlarms = dao.readAllAlarms() else { return }
        
        scheduledAlarms = persistedAlarms
        
        guard let persistedNotificationRequests = dao.readAllNotificationRequests() else { return }
        
        persistedNotificationRequests.forEach({notificationRequest in
            let alarmId = notificationRequest.alarmId
            
            if notificationRequests[alarmId] == nil {
                notificationRequests[alarmId] = Set<String>()
            }
            
            notificationRequests[alarmId]?.insert(notificationRequest.identifier)
        })
    }
    
    private func playAlarm(_ alarm: Alarm) {
        if audioPlayer != nil && audioPlayer!.isPlaying{
            return
        }
        
        // Play the selected melody
        let path = Bundle.main.path(forResource: alarm.melodyName + ".mp3", ofType: nil)
            
        let url = URL(fileURLWithPath: path!)
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("activating session failed")
        }
            
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.setVolume(1.0, fadeDuration: 1)
            audioPlayer?.play()
        } catch {
            print("Playing a melody failed. \"\(alarm.melodyName).mp3\"")
        }
    }
    
    public func stopAlarm() {
        if audioPlayer != nil && audioPlayer!.isPlaying{
            audioPlayer!.stop()
            audioPlayer = nil
        }
    }
    
    func purge() {
        cancelAllNotifications()
        AlarmPersistenceService.sharedInstance.deleteAllAlarms() //Deletes all notification requests as well through 'cascade' rule.
    }
    
    func dump() {
        print("Scheduler: Alarms:")
        for alarm in scheduledAlarms {
            print("{")
            print(alarm.string())
            print("Notifications: [")
            let requests = notificationRequests[alarm.id]
            if requests != nil {
                for notificationRequestId  in requests! {
                    print("    \(notificationRequestId)")
                }
            }
            print("    ]")
            print("}")
        }
    }
    
    func dumpNotifications() {
        print("Scheduler: Notifications:")
        UNUserNotificationCenter.current().getPendingNotificationRequests() {
            notificationRequests in
            
            print("[")
            for req in notificationRequests {
                print("\(req.identifier) \(req.content.body)")
            }
            print("]")
            
        }
    }
}
