//
//  RoundedButton.swift
//  Bonzei
//
//  Created by Tomasz on 26/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation

import UIKit

/// A rounded button
@IBDesignable
class RoundedButton: UIButton {
    
    /// Color of the circle in the background
    @IBInspectable var cornerRadius:Float = 0.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = CGFloat(cornerRadius)
        clipsToBounds = true
    }
}
