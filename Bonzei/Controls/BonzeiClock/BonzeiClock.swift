//
//  Clock.swift
//  Bonzei
//
//  Created by Tomasz on 27/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class BonzeiClock: UIControl, CAAnimationDelegate {
    
    @IBInspectable var margin: Double = 17
    
    @IBInspectable var smallCircleRadius: Double =  2.0

    @IBInspectable var minuteCircleRadius: Double = 10.0
    
    @IBInspectable var hourCircleRadius: Double = 20.0
    
    private var smallCircleColor: UIColor = BonzeiColors.gray
    
    private var topColor = BonzeiColors.Gradients.coquelicot.top
    
    private var bottomColor = BonzeiColors.Gradients.coquelicot.bottom
    
    /// Space between the edge of the big circle and edges of the small circles
    private var space: Double = 7.0
    
    /// Radius of the clock face. Calculated based on the size of the frame and the desired margin.
    private var bigCircleRadius: Double = 0.0
    
    /// Big circle will be drawn in this layer
    private var bigCircleView = ClockFaceView()
    
    /// Small circles will be drawn in this layer
    private var smallCirclesLayer = CAShapeLayer()
    
    private var hourCircleView = CircleView()
    
    private var minuteCircleView = CircleView()
    
    var boundsRadius: Double {
        get {
            return bounds.width.asDouble / 2.0
        }
    }
    
    var boundsCenterX: Double {
        get {
            return bounds.width.asDouble / 2.0
        }
    }
    
    var boundsCenterY: Double {
        get {
            return bounds.height.asDouble / 2.0
        }
    }
    
    private var hourAngle: Double = 0.0
    
    private var minuteAngle: Double = 0.0
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(bigCircleView)
        
        setupSmallCirclesLayer()
        
        setupHourCircleView()
        
        setupMinuteCircleView()
    }
    
    private func setupSmallCirclesLayer() {
        smallCirclesLayer.backgroundColor = UIColor.clear.cgColor
        smallCirclesLayer.fillColor = smallCircleColor.cgColor
        
        layer.addSublayer(smallCirclesLayer)
    }
    
    private func setupHourCircleView() {
        hourCircleView.topColor = topColor
        hourCircleView.bottomColor = bottomColor
        
        addSubview(hourCircleView)
    }
    
    private func setupMinuteCircleView() {
        minuteCircleView.topColor = topColor
        minuteCircleView.bottomColor = BonzeiColors.Gradients.coquelicot.bottom
    
        addSubview(minuteCircleView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutBigCircle()
        
        layoutSmallCircles()
        
        updateHourCirclePosition()
        
        updateMinuteCirclePosition()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        updateHourCirclePosition()
        
        updateMinuteCirclePosition()
    }
    
    //MARK:- Animation Delegate
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
    }
    
    private func updateHourCirclePosition() {
        let angle = hourAngle
        
        let (x,y) = convertToPoint(angle: angle, distance: hourHandLength())
        
        hourCircleView.frame = CGRect(
            x: 0,
            y: 0,
            width: 2.0 * hourCircleRadius.cgFloat,
            height: 2.0 * hourCircleRadius.cgFloat)
        
        hourCircleView.center = CGPoint(x: x, y: y)
    }
    
    private func updateMinuteCirclePosition() {
        let angle = self.minuteAngle
        
        let (x,y) = convertToPoint(angle: angle, distance: minuteHandleLength())
        
        minuteCircleView.frame = CGRect(
            x: 0,
            y: 0,
            width: 2.0 * minuteCircleRadius.cgFloat,
            height: 2.0 * minuteCircleRadius.cgFloat)
        
        minuteCircleView.center = CGPoint(x: x, y: y)
    }
    
    private func layoutBigCircle() {
        bigCircleRadius = boundsRadius - margin
        bigCircleView.frame = CGRect(x: 0, y: 0, width: 2.0 * bigCircleRadius, height: 2.0 * bigCircleRadius)
        bigCircleView.center = CGPoint(x: boundsCenterX, y: boundsCenterY)
    }
    
    private func layoutSmallCircles() {
        smallCirclesLayer.frame = bounds
        
        var angle = 0.0
        
        // To draw the next small circle (eg. 1 o'clock) we need to increase the angle by (1/12 * 360 degrees)
        // We are using radians, 360 degrees = 2.0 * pi
        let deltaAngle = ((2.0 * .pi) / 12.0)
        
        let smallCirclesPath = CGMutablePath()
        
        for _ in 1...12 {
            angle += deltaAngle
            let (x,y) = convertToPoint(angle: angle, distance: bigCircleRadius + space + smallCircleRadius)
            smallCirclesPath.addPath(makeCirclePath(centerX: x, centerY: y, radius: smallCircleRadius))
        }
        
        smallCirclesLayer.path = smallCirclesPath
    }
    
    //MARK:- Private API
    
    /// Calculates the angle for the hour hand 
    private func hourHandAngle(hour: Int) -> Double {
        let hour = Double(hour)
        
        // Number of minutes that passed since 12 o'clock divided by the total number of minutes in 12 hours.
        // This will give us the angle at which the hour hand must be drawn
        let ratio = (hour * 60.0) / (12.0 * 60.0)
        
        var angle = (2.0 * .pi ) * ratio + 1.5 * .pi
        if angle >= 2.0 * .pi {
            angle = angle - 2.0 * .pi
        }
        
        return angle
    }
    
    /// Calculates the lenth of the hour hand
    /// Think of it as a distance from the center of the view to the center of the hourCircle
    private func hourHandLength() -> Double {
        return bigCircleRadius - 5
    }
    
    private func minuteHandAngle(minute: Int) -> Double {
        let minute = Double(minute)
         
         // Number of minutes that passed since the last hour divided by the number of minutes in one hour.
         // This will give us the angle at which the minute hand must be drawn.
         let ratio = minute / 60.0
        
        var angle = (2.0 * .pi ) * ratio + 1.5 * .pi
        if angle >= 2.0 * .pi {
            angle = angle - 2.0 * .pi
        }
         
        return angle
    }
    
    /// Calculates the lenth of the hour hand
    /// Think of it as a distance from the center of the view to the center of the minuteCircle
    private func minuteHandleLength() -> Double {
        return bigCircleRadius - 22
    }
    
    /// Returns a point that is `distance` units away from the center of the bounding box and at the angle `angle`
    private func convertToPoint(angle: Double, distance: Double) -> (Double, Double){
        let x = cos(angle) * distance + Double(bounds.width) / 2.0
        let y = sin(angle) * distance + Double(bounds.width) / 2.0
        return (x,y)
    }
    
    
    /// - Parameter centerX: x coordinate of the center point of the circle.
    /// - Parameter centerY: y coordinate of the center point of the circle.
    /// - Parameter radius: radius of the circle.
    /// - Returns: a `CGPath` representing the requested circle.
    private func makeCirclePath(centerX: Double, centerY: Double, radius: Double) -> CGPath {
        let x = centerX - radius
        let y = centerY - radius
        
        return UIBezierPath.init(ovalIn: CGRect(x: x, y: y, width: radius * 2.0, height: radius * 2.0)).cgPath
    }
    
    private func calculateAnimationTrajectoryForHourCircle(newHour: Int, newMinute: Int) -> CGPath {
        let startAngle = hourAngle.cgFloat
       
        let endAngle = hourHandAngle(hour: newHour).cgFloat
        
        var clockwise = false
        
        var deltaAngle =  endAngle - startAngle
        if deltaAngle < 0 {
            deltaAngle = 2.0 * .pi + deltaAngle
        }
        
        if deltaAngle <= .pi {
            clockwise = true
        }
        
        return UIBezierPath.init(
            arcCenter: CGPoint(x: boundsCenterX, y: boundsCenterY),
            radius: hourHandLength().cgFloat,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: clockwise).cgPath
        
    }
    
    private func calculateAnimationTrajectoryForMinuteCircle(newMinute: Int) -> CGPath {
        let startAngle = minuteAngle
        let endAngle = minuteHandAngle(minute: newMinute)
        
        let clockwise = shouldMoveClockwiseBetween(startAngle: startAngle, endAngle: endAngle)
        
        return UIBezierPath.init(
            arcCenter: CGPoint(x: boundsCenterX, y: boundsCenterY),
            radius: minuteHandleLength().cgFloat,
            startAngle: startAngle.cgFloat,
            endAngle: endAngle.cgFloat,
            clockwise: clockwise
        ).cgPath
    }
    
    /// Returns `true` if the clockwise move between two angles is shorter than counterclockwise. Otherwise it retursn `false`
    private func shouldMoveClockwiseBetween(startAngle: Double, endAngle: Double) -> Bool {
        var clockwise = false
        
        var deltaAngle =  endAngle - startAngle
        if deltaAngle < 0 {
            deltaAngle = 2.0 * .pi + deltaAngle
        }
        
        if deltaAngle <= .pi {
            clockwise = true
        }
        
        return clockwise
    }
    
    // MARK:- Public API
    
    public func setHourAngle(to angle: Double) {
        // We need to move the angle by 90 degrees
        // because 0 degrees is at 3 O'clock and we want it to be at 12 O'clock
        hourAngle = angle - (0.5 * .pi)
        
        setNeedsDisplay()
    }
    
    public func setMinuteAngle(to angle: Double) {
                
        // We need to move the angle by 90 degrees
        // because 0 degrees is at 3 O'clock and we want it to be at 12 O'clock
        minuteAngle = angle - (0.5 * .pi)
        
        setNeedsDisplay()
    }
    
    public func setTime(date: Date, animated: Bool) {
        var newHour = date.hour
        
        if (newHour >= 12) {
            newHour = newHour % 12
        }
        
        let newMinute = date.minute
        
        if !animated {
        
            self.hourAngle = hourHandAngle(hour: newHour)
            self.minuteAngle = minuteHandAngle(minute: newMinute)
            setNeedsDisplay()
        
        } else {
            
            let animation = CAKeyframeAnimation()
            animation.keyPath = "position"
            animation.duration = 0.1
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            animation.path = calculateAnimationTrajectoryForHourCircle(
                newHour: newHour,
                newMinute: newMinute)
            animation.isRemovedOnCompletion = true
            animation.delegate = self
            
            hourAngle = hourHandAngle(hour: newHour)
            updateHourCirclePosition()
            
            hourCircleView.layer.add(animation, forKey: "move")
            
            let minuteCircleAnimation = CAKeyframeAnimation()
            minuteCircleAnimation.keyPath = "position"
            minuteCircleAnimation.duration = 0.1
            minuteCircleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            minuteCircleAnimation.isRemovedOnCompletion = true
            minuteCircleAnimation.path = calculateAnimationTrajectoryForMinuteCircle(newMinute: newMinute)
            
            minuteAngle = minuteHandAngle(minute: newMinute)
            updateMinuteCirclePosition()
            
            minuteCircleView.layer.add(minuteCircleAnimation, forKey: "move")
        }
    }
}

fileprivate class ClockFaceView: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let frameWidth = rect.width * (1.57733511 * 1.1)
        let frameHeight = rect.height * (1.33215589 * 1.1)
        BonzeiClockFace.drawCanvas1(frame: CGRect(x: -2.0, y: -2.0, width: frameWidth, height: frameHeight), resizing: .aspectFill)
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        maskLayer.path = UIBezierPath.init(ovalIn: maskLayer.bounds).cgPath
        
        layer.mask = maskLayer
    }
}

class CircleView: GradientView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let padding = CGFloat(2.0)
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = CGRect(x: padding, y: padding, width: bounds.width - 2.0 * padding, height: bounds.height - 2.0 * padding)
        maskLayer.path = UIBezierPath.init(ovalIn: maskLayer.frame).cgPath
        
        layer.mask = maskLayer
    }
}
