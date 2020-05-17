//
//  DateExtension.swift
//  Bonzei
//
//  Created by Tomasz on 16/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation

extension Date {
    
    var year: Int {
        get {
            return components().year!
        }
    }
    
    var month: Int {
        get {
            return components().month!
        }
    }
    
    var weekday: Int {
        get {
            return components().weekday!
        }
    }
    
    var day: Int {
        get {
            return components().day!
        }
    }
    
    var hour: Int {
        get {
            return components().hour!
        }
    }
    
    var minute: Int {
        get {
            return components().minute!
        }
    }
    
    var second: Int {
        get {
            return components().second!
        }
    }
    
    var timeZone: TimeZone {
        get {
            return Calendar
                .current
                .dateComponents([.timeZone], from: self).timeZone!
        }
    }
    
    /// Convienience method for getting basic components of a date in the current time zone
    /// - Returns: date components in the current time zone
    func components() -> DateComponents {
        return Calendar
            .current
            .dateComponents(in: TimeZone.current, from: self)
    }
    
    /// - Returns: date components of this date using a specified time zone
    func components(in timeZone: TimeZone) -> DateComponents {
        return Calendar
            .current
            .dateComponents(in: timeZone, from: self)
    }
    
    /// - Returns: date components of this date using the time zone in which the date was originally created
    func componentsInOriginalTimeZone() -> DateComponents {
        return components(in: self.timeZone)
    }
    
    func new(byAdding: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(byAdding: byAdding, value: value, to: self)!
    }
    
    func new(bySetting: Calendar.Component, to value: Int) -> Date {
        let calendar = Calendar.current
        
        var dateComponents = calendar.dateComponents(in: TimeZone.current, from: self)
        
        dateComponents.setValue(value, for: bySetting)
        
        return calendar.date(from: dateComponents)!
    }
}
