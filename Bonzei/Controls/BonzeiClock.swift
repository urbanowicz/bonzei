//
//  BonzeiClock.swift
//  Bonzei
//
//  Created by Tomasz on 26/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable
class Clock: UIControl {
    
    var date: Date = Date()
    
    @IBInspectable var fillColor = BonzeiColors.darkGray
    
    @IBInspectable var smallCircleColor = BonzeiColors.darkGray
    
    @IBInspectable var bigCircleColor = BonzeiColors.darkTextColor
    
    @IBInspectable var handColor = BonzeiColors.coquelicot
    
    @IBInspectable var hourHandRadius = 20.0
    
    @IBInspectable var minuteHandRadius = 10.0
    
    var hour = 0
    
    var minute = 30
    
    var bigCircleRadius:CGFloat = 0.0
    
    /// In this layer, static elemnents of the clock are drawn
    var staticLayer = CAShapeLayer()
    
    /// In this layer, moving parts of the clock are drawn
    var dynamicLayer = CAShapeLayer()
    
    
    //MARK: - Initializarion
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        commonInit()
        
    }
    
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        commonInit()
        
    }
    
    public func setTime(date: Date) {
        var h = date.hour
        
        if h >= 12 {
           h = h % 12
        }
        
        let m = date.minute
        
        self.hour = h
        self.minute = m
        
        setNeedsDisplay()
    }
    
    
    private func commonInit() {

        staticLayer.backgroundColor = UIColor.clear.cgColor
        
        staticLayer.fillColor = fillColor.cgColor
        
        
        
        dynamicLayer.backgroundColor = UIColor.clear.cgColor
        
        dynamicLayer.fillColor = handColor.cgColor
        
        layer.addSublayer(staticLayer)
        
        layer.addSublayer(dynamicLayer)
        
        
        
    }
    
    
    
    //MARK: - Layout
    
    override func layoutSubviews() {
        // The distance between the edge of the big circle and the eges of the bounding rectangle.
        // Small circles must fit into a space created by the margin.
        let margin = CGFloat(13)
        
        // Holds the big circle and the small circles that make up the static part of the clock face.
        
        let clockFace = CGMutablePath()
        
        //1. Draw the big circle
        bigCircleRadius = (bounds.width/2) - margin
        
        clockFace.addPath(circle(
            
            centerX: bounds.width/2,
            
            centerY: bounds.width/2,
            
            radius: bigCircleRadius)
            
        )
        
        
        
        //2. Draw small circles
        let smallCircleRadius = CGFloat(2)
        
        // Space betweeen the big circle and the small circles
        let space = CGFloat(7)
        
        
        
        // Set the angle to 12 o'clock. This is in radians.
        
        var angle = 0.0
        
        
        
        // To draw the next small circle (eg. 1 o'clock) we need to increase the angle by (1/12 * 360 degrees)
        
        // We are using radians, 360 degrees = 2.0 * pi
        
        let deltaAngle = ((2.0 * .pi) / 12.0)
        
        
        
        for _ in 1...12 {
            
            angle += deltaAngle
            
            let centerX = CGFloat(cos(angle)) * (bigCircleRadius + space + smallCircleRadius) + bounds.width / 2.0
            
            let centerY = CGFloat(sin(angle)) * (bigCircleRadius + space + smallCircleRadius) + bounds.width / 2.0
            
            clockFace.addPath(circle(centerX: centerX, centerY: centerY, radius: smallCircleRadius))
            
        }
        
        
        
        staticLayer.path = clockFace
        
        
        
    }
    
    
    
    /// - Parameter centerX: x coordinate of the center point of the circle.
    
    /// - Parameter centerY: y coordinate of the center point of the circle.
    
    /// - Parameter radius: radius of the circle.
    
    /// - Returns: a `CGPath` representing the requested circle.
    
    private func circle(centerX: CGFloat, centerY: CGFloat, radius: CGFloat) -> CGPath {
        let x = centerX - radius
        let y = centerY - radius
        
        return UIBezierPath.init(ovalIn: CGRect(x: x, y: y, width: radius * 2.0, height: radius * 2.0)).cgPath
        
    }
    
    
    
    //MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        let handsOfAClock = CGMutablePath()
    
        
        handsOfAClock.addPath(hourHand(
            
            hour: hour,
            
            minutes: minute,
            
            hourHandLength: bigCircleRadius - 5,
            
            radius: CGFloat(hourHandRadius))
            
        )
        
        
        handsOfAClock.addPath(minutesHand(
            
            minutes: minute,
            
            minuteHandLength: bigCircleRadius - 22 ,
            
            radius: CGFloat(minuteHandRadius))
            
        )
        
        
        
        dynamicLayer.path = handsOfAClock
        
        
        
    }
    
    
    
    private func hourHand(hour: Int, minutes: Int, hourHandLength: CGFloat, radius: CGFloat) -> CGPath {
        
        
        
        let hour = Double(hour)
        
        let minutes = Double(minutes)
        
        
        
        // Number of minutes that passed since 12 o'clock divided by the total number of minutes in 12 hours.
        
        // This will give us the angle at which the hour hand must be drawn
        
        let ratio = (hour * 60.0 + minutes) / (12.0 * 60.0)
        
        
        
        let angle = (2.0 * .pi ) * ratio - 0.5 * .pi
        
        
        
        let centerX = CGFloat(cos(angle)) * hourHandLength + bounds.width / 2.0
        
        
        
        let centerY = CGFloat(sin(angle)) * hourHandLength + bounds.width / 2.0
        
        
        
        return circle(centerX: centerX, centerY: centerY, radius: radius)
        
    }
    
    
    
    private func minutesHand(minutes: Int, minuteHandLength: CGFloat, radius: CGFloat) -> CGPath {
        
        
        
        let minutes = Double(minutes)
        
        
        
        // Number of minutes that passed since the last hour divided by the number of minutes in one hour.
        
        // This will give us the angle at which the minute hand must be drawn.
        
        let ratio = minutes / 60.0
        
        
        
        let angle = (2.0 * Double.pi ) * ratio - 0.5 * .pi
        
        
        
        let centerX = CGFloat(cos(angle)) * minuteHandLength + bounds.width / 2.0
        
        
        
        let centerY = CGFloat(sin(angle)) * minuteHandLength + bounds.width / 2.0
        
        
        
        return circle(centerX: centerX, centerY: centerY, radius: radius)
        
        
        
    }
    
}

