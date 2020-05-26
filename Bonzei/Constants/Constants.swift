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
    
    static let jungleGreen = UIColor(red: 0.14, green: 0.24, blue: 0.21, alpha: 1.00)
    
    // Used as background for some of the buttons (eg. play, pause, stop, repeat on)
    static let gray = UIColor(red: 0.94, green: 0.91, blue: 0.95, alpha: 1.00)
    
    // Used as background for all views
    static let offWhite = UIColor(red: 1.00, green: 0.99, blue: 0.99, alpha: 1.00)
    
    // Used as text color
    static let darkGray = UIColor(red: 0.42, green: 0.42, blue: 0.42, alpha: 1.00)
    
    // Used as text color
    static let darkTextColor = UIColor(red: 0.11, green: 0.14, blue: 0.13, alpha: 1.00)
}

// Fonts
struct BonzeiFonts {
    static let title =  Font(name: "Muli-Bold", size: 28, character: 0.37, line: 37)
}

struct Font {
    var name: String
    var size: CGFloat
    var character: CGFloat
    var line: CGFloat
}


