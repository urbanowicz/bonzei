//
//  File.swift
//  Bonzei
//
//  Created by Tomasz on 08/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import UIKit


// Colors
struct BonzeiColors {
    
    static let coquelicot = UIColor(red: 1.00, green: 0.23, blue: 0.00, alpha: 1.00)
    
    static let jungleGreen = UIColor(red: 0.14, green: 0.24, blue: 0.21, alpha: 1.00)
    
    // Used as background for some of the buttons (eg. play, pause, stop, repeat on)
    static let gray = UIColor(red: 0.94, green: 0.91, blue: 0.95, alpha: 1.00)
    
    // Used as background for all views
    static let offWhite = UIColor(red: 1.00, green: 0.99, blue: 0.99, alpha: 1.00)
    
    // Used as text color
    static let darkGray = UIColor(red: 0.42, green: 0.42, blue: 0.42, alpha: 1.00)
    
    static let darkGrayDisabled = UIColor(red: 0.42, green: 0.42, blue: 0.42, alpha: 0.5)
    
    // Used as text color
    static let darkTextColor = UIColor(red: 0.11, green: 0.14, blue: 0.13, alpha: 1.00)
    
    //Gradients
    struct Gradients {
        
        static let coquelicot = Gradient(
            top: UIColor(red: 1.00, green: 0.07, blue: 0.00, alpha: 1.00),
            bottom: UIColor(red: 0.96, green: 0.53, blue: 0.43, alpha: 1.00)
        )
        
        static let pink = Gradient(
            top: UIColor(red: 0.99, green: 0.86, blue: 0.84, alpha: 1.00),
            bottom: UIColor(red: 0.87, green: 0.91, blue: 0.98, alpha: 1.00)
        )
        
        static let blue = Gradient(
            top: UIColor(red: 0.23, green: 0.26, blue: 0.95, alpha: 1.00),
            bottom: UIColor(red: 0.23, green: 0.55, blue: 0.95, alpha: 1.00))
    }
}

// Fonts
struct BonzeiFonts {
    static let title =  Font(name: "Muli-Bold", size: 28, character: 0.37, line: 37)
    
    static let label = Font(name: "Muli-Regular", size: 14, character: 0.65, line: 17)
}

struct Font {
    var name: String
    var size: CGFloat
    var character: CGFloat
    var line: CGFloat
}

struct Gradient {
   var top: UIColor
   var bottom: UIColor
}
