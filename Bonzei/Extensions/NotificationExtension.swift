//
//  NotificationExtension.swift
//  Bonzei
//
//  Created by Tomasz on 21/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    // posted by the AlarmScheduler
    static let didTriggerAlarm = Notification.Name("didTriggerAlarm")
    static let didDismissAlarm = Notification.Name("didDismissAlarm")
    static let didSnoozeAlarm = Notification.Name("didSnoozeAlarm")
    
    
}
