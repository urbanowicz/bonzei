//
//  AlarmSchedulerDelegate.swift
//  Bonzei
//
//  Created by Tomasz on 18/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation

protocol AlarmSchedulerDelegate {
    
    func didTriggerAlarm(_ alarm: Alarm, withMelody melody: String)
    
    func didSnoozeAlarm(_ alarm: Alarm)
    
    func didDismissAlarm(_ alarm: Alarm)
    
}
