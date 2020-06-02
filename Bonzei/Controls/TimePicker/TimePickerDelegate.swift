//
//  TimePickerDelegate.swift
//  PickerView
//
//  Created by Tomasz on 01/06/2020.
//  Copyright © 2020 urbanowicz. All rights reserved.
//

import Foundation

protocol TimePickerDelegate {
    func valueChanged(sender: TimePicker)
    
    func hourPickerDidScroll(picker: WraparoundPickerView)
    
    func minutePickerDidScroll(picker: WraparoundPickerView)
}
