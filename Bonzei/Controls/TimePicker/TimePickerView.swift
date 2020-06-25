//
//  TimePickerView.swift
//  Bonzei
//
//  Created by Tomasz on 25/06/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class TimePickerView: UIView, TimePicker {
    
    public var is24mode = true
    
    private var timePicker_24: TimePicker_24?
    
    private var timePicker_AM_PM: TimePicker_AM_PM?
    
    // MARK:- Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        is24mode = shouldUse24Mode()
        if is24mode {
            timePicker_24 = TimePicker_24()
            addSubview(timePicker_24!)
        } else {
            timePicker_AM_PM = TimePicker_AM_PM()
            addSubview(timePicker_AM_PM!)
        }
    }
    
    // MARK:- Layout
    
    override func layoutSubviews() {
        layoutTimePicker_24()
        layoutTimePicker_AM_PM()
    }
    
    private func layoutTimePicker_24() {
        guard let timePicker = timePicker_24 else { return }
        
        timePicker.frame = bounds
    }
    
    private func layoutTimePicker_AM_PM() {
        guard let timePicker = timePicker_AM_PM else { return }
        
        timePicker.frame = bounds
    }
    
    
    private func shouldUse24Mode() -> Bool {
        return true
    }
    
    // MARK:- TimePicker protocol
    
    func getDate() -> Date {
        if is24mode {
            return timePicker_24!.getDate()
        } else {
            return timePicker_AM_PM!.getDate()
        }
    }
    
    func setDate(to date: Date) {
        if is24mode {
            timePicker_24!.setDate(to: date)
        } else {
            timePicker_AM_PM!.setDate(to: date)
        }
    }
    
    func setDelegate(_ delegate: TimePickerDelegate) {
        if is24mode {
            timePicker_24!.setDelegate(delegate)
        } else {
            timePicker_AM_PM!.setDelegate(delegate)
        }
    }
}
