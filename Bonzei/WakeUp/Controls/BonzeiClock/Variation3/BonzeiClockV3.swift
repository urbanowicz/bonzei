//
//  BonzeiClockV3.swift
//  Bonzei
//
//  Created by Tomasz on 06/06/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class BonzeiClockV3: UIView {
    
    private var smallCircleColor: UIColor = UIColor.white.withAlphaComponent(0.1)
    
    private var smallCircleRadius: Double =  2.0
    
    /// Small circles will be drawn in this layer
    
    private var bigCircleLayer = CAShapeLayer()
    private var smallCirclesLayer = CAShapeLayer()
    
    
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
        backgroundColor = UIColor.clear
        
        setupBigCircleLayer()
        setupSmallCirclesLayer()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    private func setupBigCircleLayer() {
        bigCircleLayer.backgroundColor = UIColor.clear.cgColor
        bigCircleLayer.fillColor = smallCircleColor.cgColor
        
        layer.addSublayer(bigCircleLayer)
    }
    
    private func setupSmallCirclesLayer() {
        smallCirclesLayer.backgroundColor = UIColor.clear.cgColor
        smallCirclesLayer.fillColor = smallCircleColor.cgColor
        
        layer.addSublayer(smallCirclesLayer)
    }
    
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutBigCircle()
        layoutSmallCircles()
    }
    
    private func layoutBigCircle() {
        let bigCircleBoundsWidth = self.bounds.width * 0.85
        
        bigCircleLayer.frame = CGRect(x: (bounds.width - bigCircleBoundsWidth) / 2,
                                      y: (bounds.height - bigCircleBoundsWidth) / 2,
                                      width: bigCircleBoundsWidth,
                                      height: bigCircleBoundsWidth)
        
        bigCircleLayer.path = UIBezierPath.init(ovalIn: bigCircleLayer.bounds).cgPath
    }
    
    private func layoutSmallCircles() {
        smallCirclesLayer.frame = bounds
        
        var angle = 0.0
        
        // To draw the next small circle (eg. 1 o'clock) we need to increase the angle by (1/12 * 360 degrees)
        // We are using radians, 360 degrees = 2.0 * pi
        let deltaAngle = ((2.0 * .pi) / 12.0)
        
        let smallCirclesPath = CGMutablePath()
        
        let distance = (0.95 * bounds.width) / 2.0
        
        for _ in 1...12 {
            angle += deltaAngle
            let (x,y) = convertToPoint(angle: angle, distance: distance)
            smallCirclesPath.addPath(makeCirclePath(centerX: x, centerY: y, radius: smallCircleRadius))
        }
        
        smallCirclesLayer.path = smallCirclesPath
    }
    
    // MARK:- Private API
    
    /// - Parameter centerX: x coordinate of the center point of the circle.
    /// - Parameter centerY: y coordinate of the center point of the circle.
    /// - Parameter radius: radius of the circle.
    /// - Returns: a `CGPath` representing the requested circle.
    private func makeCirclePath(centerX: Double, centerY: Double, radius: Double) -> CGPath {
        let x = centerX - radius
        let y = centerY - radius
        
        return UIBezierPath.init(ovalIn: CGRect(x: x, y: y, width: radius * 2.0, height: radius * 2.0)).cgPath
    }
    
    /// Returns a point that is `distance` units away from the center of the bounding box and at the angle `angle`
    private func convertToPoint(angle: Double, distance: Double) -> (Double, Double){
        let x = cos(angle) * distance + Double(bounds.width) / 2.0
        let y = sin(angle) * distance + Double(bounds.height) / 2.0
        return (x,y)
    }
}
