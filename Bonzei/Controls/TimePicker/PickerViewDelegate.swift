//
//  PickerViewDelegate.swift
//  PickerView
//
//  Created by Tomasz on 01/06/2020.
//  Copyright © 2020 urbanowicz. All rights reserved.
//

import Foundation
import UIKit

protocol PickerViewDelegate {
    func valueChanged()
    
    func pickerDidScroll(sender: UIView)
}
