//
//  MovingGradientView.swift
//  Bonzei
//
//  Created by Tomasz on 08/06/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import UIKit

class MovingGradientView: UIView {
    
    private var animationSpeed = 15.0
    
    private var gradientLayer: CAGradientLayer = CAGradientLayer()
    
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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        layer.insertSublayer(gradientLayer, at: 0)
        updateGradient()
        clipsToBounds = true
    }
    
    private func updateGradient() {
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let w = Double(bounds.width)
        let h = Double(bounds.height)
        
        let gradientLayerFrameWidth = sqrt(w*w + h*h) * 2.0
        let gradientLayerFrameHeight = gradientLayerFrameWidth
        
        let x = (w / 2.0) - (gradientLayerFrameWidth / 2.0)
        let y = (h / 2.0) - (gradientLayerFrameHeight / 4.0)
        
        gradientLayer.frame = CGRect(x: x,
                                     y: y,
                                     width: gradientLayerFrameWidth,
                                     height: gradientLayerFrameHeight
        )
        
        gradientLayer.transform = CATransform3DMakeRotation(.pi/4.0, 0, 0, 1.0)
        
        // Animation
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.y"
        animation.values = [0, -gradientLayerFrameHeight / 2.0, 0]
        animation.keyTimes = [0, 0.5, 1]
        animation.duration = animationSpeed
        animation.isAdditive = true
        animation.isRemovedOnCompletion = false
        animation.repeatCount = .greatestFiniteMagnitude
        gradientLayer.add(animation, forKey: "move")
    }
}
