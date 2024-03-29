//
//  GradientView.swift
//  Bonzei
//
//  Created by Tomasz on 28/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import UIKit

class GradientView: UIView {
    override open class var layerClass: AnyClass {
       return CAGradientLayer.classForCoder()
    }
    
    var topColor: UIColor = UIColor.yellow {
        didSet {
            updateGradient()
        }
    }
    
    var bottomColor: UIColor = UIColor.red {
        didSet {
            updateGradient()
        }
    }
    
    var locations: [NSNumber] = [0.0, 1.0] {
        didSet {
            updateGradient()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateGradient()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateGradient()
    }
    
    private func updateGradient() {
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = locations
    }
}
