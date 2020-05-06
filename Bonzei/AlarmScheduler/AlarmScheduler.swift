//
//  AlarmScheduler.swift
//  Bonzei
//
//  Created by Tomasz on 05/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import UserNotifications

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
    private var notificationRequests = [String:[String]]()
    
    // This is a singleton class, hence a private constructor
    private init() {

        if let savedAlarms = fileDbRead(fileName: "alarms.db") as? [Alarm] {
            scheduledAlarms = savedAlarms
        }
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
        
        if !alarm.isActive || alarm.repeatOn.isEmpty {
            print("Scheduler::added inactive: \(alarm.id)")
        } else {
                
            let notificationCenter = UNUserNotificationCenter.current()
            
            notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                guard granted == true && error == nil else { return }
                self.addNotification(forAlarm: alarm)
            }
                
            print("Scheduler::added: \(alarm.id)")
        }
    
    }

    /// Removes an alarm from the scheduler.
    ///
    /// All pending notifications associated with the alarm are immediately canceled
    /// If `id` is not registered in the scheduler, the request is ignored.
    ///
    /// - Parameter id: identifier of the alarm that you wish to unschedule
    ///
    public func unscheduleAlarm(withId id: String) {
        
        let i = indexOfAlarm(withId: id)
        
        if i == nil {
            return
        }
        
        cancelNotification(forAlarm: scheduledAlarms[i!])
        
        scheduledAlarms = scheduledAlarms.filter({ $0.id != id })
        
        print("Scheduler::Removed: \(id)")
    }
    
    /// Returns all scheduled alarms .
    ///
    /// - Returns: an array of `Alarm` values that represent scheduled alarms.
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
    public func updateAlarm(withId id: String, using alarm: Alarm) {
        
        let i = indexOfAlarm(withId: id)
        
        if i == nil {
            return
        }
        
        let updatedAlarm = Alarm(id: id,
                      date: alarm.date,
                      repeatOn: alarm.repeatOn,
                      melodyName: alarm.melodyName,
                      snoozeEnabled: alarm.snoozeEnabled,
                      isActive: alarm.isActive)
        
        scheduledAlarms[i!] = updatedAlarm
        
        cancelNotification(forAlarm: updatedAlarm)
        
        if (!alarm.isActive || alarm.repeatOn.isEmpty) {
            print("Scheduler::Updated to inactive: \(id)")
        } else {
            addNotification(forAlarm: updatedAlarm)
            print("Scheduler::Updated: \(id)")
        }
    }
    
    /// Indicates whether an alarm is scheduled.
    ///
    /// - Returns: a boolean value indicating whether the alarm is scheduled (`true`) or not (`false`)
    ///
    public func isScheduledAlarm(withId id: String) -> Bool {
        return indexOfAlarm(withId: id) != nil
    }
    
    //MARK: - Helper functions
    
    /// Schedule necessary notifications for a given alarm
    ///
    /// - Parameter alarm: an alarm for which notifications need to be added.
    ///
    private func addNotification(forAlarm alarm: Alarm) {
        
        if notificationRequests[alarm.id] == nil {
            notificationRequests[alarm.id] = [String]()
        }
        
        //1.Content
        let content = UNMutableNotificationContent()
        content.title = "Wake up"
        content.body = alarm.melodyName
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(alarm.melodyName+".mp3"))

        for dayOfWeek in alarm.repeatOn {
            //2.Trigger
            var datePattern = Calendar.current.dateComponents([.hour, .minute, .timeZone], from: alarm.date)
            datePattern.weekday = (dayOfWeek + 1) % 7 + 1
            let trigger = UNCalendarNotificationTrigger (dateMatching: datePattern, repeats: true)
            
            //3.Request
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger)
            
            UNUserNotificationCenter
                .current()
                .add(request) { error in
                    guard error == nil else { return }
                    self.notificationRequests[alarm.id]!.append(request.identifier)
                    print("Scheduler::Notification added OK: \(datePattern.weekday!)")
            }
        }
    }
    
    /// Cancel  pending notifications for a given alarm.
    private func cancelNotification(forAlarm alarm: Alarm) {
        
        guard notificationRequests[alarm.id] != nil else {
            return
        }
        
        guard notificationRequests[alarm.id]!.count > 0 else {
            return
        }
        
        UNUserNotificationCenter
            .current()
            .removePendingNotificationRequests(withIdentifiers: notificationRequests[alarm.id]!)
        
        notificationRequests.removeValue(forKey: alarm.id)
        
        print("Scheduler::Canceled Notifications for: \(alarm.id)")
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
    
    
    func dump() {
        for alarm in scheduledAlarms {
            print(alarm.string())
        }
    }
    
    func dumpNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests() {
            notificationRequests in
            
            for req in notificationRequests {
                print("{")
                print(req.identifier)
                print(req.content.body)
                print("}")
            }
        
        }
    }
}
