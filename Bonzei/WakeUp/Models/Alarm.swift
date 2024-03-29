//
//  Alarm.swift
//  Bonzei
//
//  Created by Tomasz on 17/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation

/// A structure that represents a recurring alarm concept.
///
/// It is central to the application. Controllers create instances of this struct and pass them between each other.
/// It is displayed in views, and is used as an input parameter to`AlarmScheduler`.
struct Alarm {
    
    var id: String = UUID().uuidString
    
    var date: Date
    
    var snoozeDate: Date?
    
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = date.timeZone
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .medium
        dateFormatter.setLocalizedDateFormatFromTemplate("hh:mm")
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: date)
    }
    
    var hour: Int {
        get {
            return date.components(in: date.timeZone).hour!
        }
    }
    
    var minute: Int {
        get {
            return date.components(in: date.timeZone).minute!
        }
    }
    
    var repeatOn = Set<Int>([0])
    
    var melodyName: String
    
    var snoozeEnabled: Bool = true
    
    var isActive: Bool = true
    
    var lastTriggerDate: Date?
    
    var lastUpdateDate: Date?
    
    var isRecurring: Bool {
        get {
            return repeatOn.count > 0
        }
    }
    
    var isOneTime: Bool {
        get {
            return repeatOn.count == 0
        }
    }
    
    var isSnoozed: Bool {
        get {
            return snoozeDate != nil 
        }
    }
    
    /// Creates a human readable representation of the alarm
    func string() -> String {
        return """
        id: \(id)
        date: \(dateString)
        snoozeDate: \(snoozeDate?.description ?? "nil")
        lastTriggerDate: \(lastTriggerDate?.description ?? "nil")
        lastUpdateDate: \(lastUpdateDate?.description ?? "nil")
        melody: \(melodyName)
        repeat: \(repeatOn)
        active: \(isActive)
        snooze: \(snoozeEnabled)
        """
    }
}
