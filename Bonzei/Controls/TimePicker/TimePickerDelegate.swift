//
//  TimePickerDelegate.swift
//  PickerView
//
//  Created by Tomasz on 01/06/2020.
//  Copyright © 2020 urbanowicz. All rights reserved.
//

import Foundation
import UIKit

protocol TimePickerDelegate {
    func valueChanged(sender: UIView)
    
    func hourPickerDidScroll(picker: WraparoundPickerView)
    
    func minutePickerDidScroll(picker: WraparoundPickerView)
}

// Default empty implementations of the methods defined in the protocol.
// This effectively makes them optional.
// A delegate class that only needs to implement say the `valueChanged` method can skip
// the `minutePickerDidScroll` and `hourPickerDidScroll` mehtods
extension TimePickerDelegate {
    func valueChanged(sender: UIView) {
        
    }
    
    func hourPickerDidScroll(picker: WraparoundPickerView) {
        
    }
    
    func minutePickerDidScroll(picker: WraparoundPickerView) {
        
    }
}
