//
//  OvalButton.swift
//  Bonzei
//
//  Created by Tomasz on 04/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import UIKit

/// A button that has a circle as a background.
@IBDesignable
class OvalButton: UIButton {
    
    /// Color of the circle in the background
    @IBInspectable var circleColor:UIColor = UIColor.systemGray3
    
    /// Color of the symbol in the foreground
    @IBInspectable var symbolColor:UIColor = UIColor.systemGreen
    
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        backgroundColor = circleColor
        tintColor = symbolColor
        
        //Make the background a circle
        layer.cornerRadius = bounds.size.width / 2.0
        clipsToBounds = true
        
    }
}
