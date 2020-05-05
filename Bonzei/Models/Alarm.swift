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
    
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .medium
        dateFormatter.setLocalizedDateFormatFromTemplate("hh:mm")
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: date)
    }
    
    var repeatOn = Set<Int>([0])
    
    var melodyName: String
    
    var snoozeEnabled = true
    
    var isActive: Bool = true
    
}

/// An array that holds every alarm created by the user.
/// It is shared by controllers.
var alarms = [Alarm]()
