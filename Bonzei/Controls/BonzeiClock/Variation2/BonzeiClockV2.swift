//
//  BonzeiClockV2.swift
//  Bonzei
//
//  Created by Tomasz on 06/06/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class BonzeiClockV2: UIView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        ClockFaceAndDots.drawCanvas1(frame: rect, resizing: .aspectFit)
    }
}
