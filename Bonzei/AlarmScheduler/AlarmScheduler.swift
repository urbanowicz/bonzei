//
//  AlarmScheduler.swift
//  Bonzei
//
//  Created by Tomasz on 05/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation


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
    
    /// An array with ids of scheduled alarms.
    private var scheduledAlarmsIds = [String]()
    
    // This is a singleton class, hence a private constructor
    private init() {
        
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
        
        guard !scheduledAlarmsIds.contains(alarm.id) else {
            return
        }
        
        scheduledAlarmsIds.append(alarm.id)
        
        if !alarm.isActive || alarm.repeatOn.isEmpty {
            print("Scheduler::added inactive: \(alarm)")
        } else {
            print("Scheduler::added: \(alarm)")
        }
        
    }

    /// Removes an alarm from the scheduler.
    ///
    /// All pending notifications associated with the alarm are immediately canceled
    /// If `id` is not registered in the scheduler, the request is ignored.
    ///
    /// - Parameter id: identifier of the alarm that you wish to unschedule
    ///
    public func unscheduleAlarm(with id: String) {
        
        guard scheduledAlarmsIds.contains(id) else {
            return
        }
        
        print("Scheduler::Removed: \(id)")
    }
    
    /// Returns ids of scheduled alarms.
    ///
    /// - Returns: an array of `String` values that represent the ids of scheduled alarms.
    ///
    public func scheduledAlarms() -> [String] {
        return scheduledAlarmsIds
    }
    
    /// Reschedules a given alarm.
    ///
    /// Once an alarm has been added to the scheduler using the `schedule()` method it can be rescheduled using the `reschedule()` method.
    /// If an alarm with `alarm.id` is not in the scheduler, the request is ignored.
    /// If `alarm.isActive` is false, the alarm will remain in the scheduler, but all related notifications will immediately canceled.
    /// The same is true if `alarm.repeatOn` is empty.
    ///
    /// - Parameter alarm: an alarm to be rescheduled.
    ///
    public func update(alarm: Alarm) {
        
        guard scheduledAlarmsIds.contains(alarm.id) else {
            return
        }
        
        if (!alarm.isActive || alarm.repeatOn.isEmpty) {
            print("Scheduler::Updated to inactive: \(alarm)")
        } else {
            print("Scheduler::Updated: \(alarm)")
        }
    }
    
    /// Tells whether an alarm is scheduled.
    ///
    /// - Returns: a boolean value indicating whether the alarm is scheduled (`true`) or not (`false`)
    ///
    public func isScheduled(alarmWith id: String) -> Bool {
        
        return  scheduledAlarmsIds.contains(id)
    
    }
}
