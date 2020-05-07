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
    
    init(alarm: Alarm) {
        id = alarm.id
        date = alarm.date
        repeatOn = alarm.repeatOn
        melodyName = alarm.melodyName
        snoozeEnabled = alarm.snoozeEnabled.string
        isActive = alarm.isActive.string
        
        super.init()
    }
    
    required init?(coder: NSCoder) {
        snoozeEnabled = coder.decodeObject(forKey: "snoozeEnabled") as! String
        id = coder.decodeObject(forKey:"id") as! String
        date = coder.decodeObject(forKey:"date") as! Date
        repeatOn = coder.decodeObject(forKey: "repeatOn") as! Set<Int>
        melodyName = coder.decodeObject(forKey: "melodyName") as! String
        snoozeEnabled = coder.decodeObject(forKey: "snoozeEnabled") as! String
        isActive = coder.decodeObject(forKey: "isActive") as! String
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(snoozeEnabled, forKey: "snoozeEnabled")
        coder.encode(id, forKey:"id")
        coder.encode(date, forKey:"date")
        coder.encode(repeatOn, forKey: "repeatOn")
        coder.encode(melodyName, forKey: "melodyName")
        coder.encode(isActive, forKey: "isActive")
    }
    
    public func alarm() -> Alarm {
        return Alarm(id: id,
                     date: date,
                     repeatOn: repeatOn,
                     melodyName: melodyName,
                     snoozeEnabled: snoozeEnabled == "true",
                     isActive: isActive == "true")
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
