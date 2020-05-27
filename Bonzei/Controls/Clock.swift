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
    
    var hourHandView = CircleView()
    
    var minuteHandView = CircleView()
    
    
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
        
        func incTime(h: Int, m: Int) -> (Int, Int) {
            var m = m
            var h = h
            
            m += 15
            if m >= 60 {
                m = m % 60
                h += 1
                if h >= 12 {
                    h = h % 12
                }
            }
            return (h,m)
        }
        
        func numberOfFrames(newHour: Int, newMinute: Int) -> Int {
            let dh = abs(newHour - self.hour)
            let dm = abs(newMinute - self.minute)
            return (dh * 60 + dm) / 15
        }
        
        var h = date.hour
        let m = date.minute
        
        print("number of frames: \(numberOfFrames(newHour: h, newMinute: m))")
        
        let animationDuration = 0.05 * Double(numberOfFrames(newHour: h, newMinute: m))
        
        if h >= 12 {
           h = h % 12
        }
        
        var currentHour = self.hour
        var currentMinute = self.minute
        
        self.hour = h
        self.minute = m
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {

           let (centerX, centerY) = self.minutesHand(minutes: self.minute, minuteHandLength: self.bigCircleRadius - 22, radius: CGFloat(self.minuteHandRadius))

            self.minuteHandView.frame = self.circleFrame(centerX: centerX, centerY: centerY, radius: CGFloat(self.minuteHandRadius))
        })
        
        
        print("Hello \(currentHour) \(currentMinute)")
        print("Hello self \(self.hour) \(self.minute)")
        
        UIView.animateKeyframes(withDuration: animationDuration, //1
          delay: 0, //2
          options: .calculationModeLinear, //3
          animations: { //4
            
            var i = 0
            while currentHour != self.hour  {
                (currentHour, currentMinute) = incTime(h: currentHour, m: currentMinute)
                print(currentHour, currentMinute)
                UIView.addKeyframe(withRelativeStartTime: Double(i) * 0.05, relativeDuration: 0.05)  {
                    let (centerX, centerY) = self.hourHand(
                        hour: currentHour,
                        minutes: currentMinute,
                        hourHandLength: self.bigCircleRadius - 5, radius: CGFloat(self.hourHandRadius))
                    
                    self.hourHandView.frame = self.circleFrame(
                        centerX: centerX,
                        centerY: centerY,
                        radius: CGFloat(self.hourHandRadius))
                }
                i+=1
            }
        })
        
        
        //setNeedsDisplay()
    }
    
    
    private func commonInit() {
        staticLayer.backgroundColor = UIColor.clear.cgColor
        staticLayer.fillColor = fillColor.cgColor
        layer.addSublayer(staticLayer)
        self.addSubview(hourHandView)
        self.addSubview(minuteHandView)
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
        
        var (centerX, centerY) = hourHand(hour: hour, minutes: minute, hourHandLength: bigCircleRadius - 5, radius: CGFloat(hourHandRadius))
        hourHandView.frame = circleFrame(centerX: centerX, centerY: centerY, radius: CGFloat(hourHandRadius))
        
        (centerX, centerY) = minutesHand(minutes: minute, minuteHandLength: bigCircleRadius - 22, radius: CGFloat(minuteHandRadius))
        minuteHandView.frame = circleFrame(centerX: centerX, centerY: centerY, radius: CGFloat(minuteHandRadius))
        
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
    
    private func circleFrame(centerX: CGFloat, centerY: CGFloat, radius: CGFloat) -> CGRect {
        let x = centerX - radius
        let y = centerY - radius
        
        return CGRect(x: x, y: y, width: radius * 2.0, height: radius * 2.0)
        
    }
    
    
    
    //MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    private func hourHand(hour: Int, minutes: Int, hourHandLength: CGFloat, radius: CGFloat) -> (CGFloat, CGFloat) {
        
        let hour = Double(hour)
        let minutes = Double(minutes)
        
        // Number of minutes that passed since 12 o'clock divided by the total number of minutes in 12 hours.
        // This will give us the angle at which the hour hand must be drawn
        let ratio = (hour * 60.0 + minutes) / (12.0 * 60.0)
        let angle = (2.0 * .pi ) * ratio - 0.5 * .pi
        
        let centerX = CGFloat(cos(angle)) * hourHandLength + bounds.width / 2.0
        let centerY = CGFloat(sin(angle)) * hourHandLength + bounds.width / 2.0
        
        return (centerX, centerY)
    }
    
    
    
    private func minutesHand(minutes: Int, minuteHandLength: CGFloat, radius: CGFloat) -> (CGFloat, CGFloat) {
        
        let minutes = Double(minutes)
        
        // Number of minutes that passed since the last hour divided by the number of minutes in one hour.
        
        // This will give us the angle at which the minute hand must be drawn.
        let ratio = minutes / 60.0
        let angle = (2.0 * Double.pi ) * ratio - 0.5 * .pi
        
        let centerX = CGFloat(cos(angle)) * minuteHandLength + bounds.width / 2.0
        let centerY = CGFloat(sin(angle)) * minuteHandLength + bounds.width / 2.0
        
        return (centerX, centerY)
        
    }
    
}


