//
//  PersistableAlarm.swift
//  Bonzei
//
//  Created by Tomasz on 07/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation

/// A wrapper class around the Alarm struct. Used only for presisting alarms.
///
class PersistableAlarm: NSObject, NSCoding {
    
    private var id: String
    
    private var date: Date
    
    private var repeatOn: Set<Int>
    
    private var melodyName: String
    
    private var snoozeEnabled: String
    
    private var isActive: String
    
    private var notificationRequests: Set<String>
    
    private var lastTriggerDate: Date?
    
    init(alarm: Alarm, notificationRequests: Set<String>?, lastTriggerDate: Date? ) {
        
        id = alarm.id
        date = alarm.date
        repeatOn = alarm.repeatOn
        melodyName = alarm.melodyName
        snoozeEnabled = alarm.snoozeEnabled.string
        isActive = alarm.isActive.string
        self.lastTriggerDate = lastTriggerDate
        
        if notificationRequests != nil {
            self.notificationRequests = notificationRequests!
        } else {
            self.notificationRequests = Set<String>()
        }
        
        super.init()
    
    }
    
    required init?(coder: NSCoder) {
        
        snoozeEnabled = coder.decodeObject(forKey: "snoozeEnabled") as! String
        id = coder.decodeObject(forKey:"id") as! String
        date = coder.decodeObject(forKey:"date") as! Date
        
        if let repeatOn = coder.decodeObject(forKey: "repeatOn") as? Set<Int> {
            self.repeatOn = repeatOn
        } else {
            self.repeatOn = Set<Int>()
        }
        
        melodyName = coder.decodeObject(forKey: "melodyName") as! String
        snoozeEnabled = coder.decodeObject(forKey: "snoozeEnabled") as! String
        isActive = coder.decodeObject(forKey: "isActive") as! String
        
        if let notificationRequests = coder.decodeObject(forKey: "notificationRequests") as? Set<String> {
            self.notificationRequests = notificationRequests
        } else {
            self.notificationRequests = Set<String>()
        }
        
        lastTriggerDate = coder.decodeObject(forKey: "lastTriggerDate") as? Date
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(snoozeEnabled, forKey: "snoozeEnabled")
        coder.encode(id, forKey:"id")
        coder.encode(date, forKey:"date")
        coder.encode(repeatOn, forKey: "repeatOn")
        coder.encode(melodyName, forKey: "melodyName")
        coder.encode(isActive, forKey: "isActive")
        coder.encode(notificationRequests, forKey: "notificationRequests")
        coder.encode(lastTriggerDate, forKey: "lastTriggerDate")
    }
    
    public func alarm() -> Alarm {
        return Alarm(id: id,
                     date: date,
                     repeatOn: repeatOn,
                     melodyName: melodyName,
                     snoozeEnabled: snoozeEnabled == "true",
                     isActive: isActive == "true")
    }
    
    public func getNotificationRequests() -> Set<String> {
        return notificationRequests
    }
    
    public func getLastTriggerDate() -> Date? {
        return lastTriggerDate
    }
}

fileprivate extension Bool {
    var string: String {
        get {
            if self {
                return "true"
            } else {
                return "false"
            }
        }
    }
}
