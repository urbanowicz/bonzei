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
    
    /// Convienience method for getting basic components of a date.
    /// - Returns: year, day of month, weekday, hour, minute, second, time zone components using the current calendar
    func components() -> DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second, .timeZone], from: self)
    }
}
