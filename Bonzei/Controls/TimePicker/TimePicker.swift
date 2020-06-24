//
//  TimePicker.swift
//  Bonzei
//
//  Created by Tomasz on 24/06/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation

protocol TimePicker {
    func getDate() -> Date
    
    func setDate(to date: Date)
    
    func setDelegate(_ delegate: TimePickerDelegate)
}
