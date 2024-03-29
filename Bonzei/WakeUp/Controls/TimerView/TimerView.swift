//
//  TimerView.swift
//  Bonzei
//
//  Created by Tomasz on 05/06/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class TimerView: UIView {
    
    /// There are two modes of operation
    /// - `clock`: the view acts as a clock displaying the current time
    /// - `timer`: the view acts as a timer, counting down from the value set in `countDownFrom`
    enum Mode {
        case clock
        case timer
    }
    
    @IBInspectable var font:UIFont = UIFont.systemFont(ofSize: 16) {
        didSet {
            label.font = font
        }
    }
    
    @IBInspectable var textColor:UIColor = UIColor.darkText {
        didSet {
            label.textColor = textColor
        }
    }
    
    public var mode: Mode = .clock
    
    /// A label used to display the time. eg '05:55'
    public var label = UILabel()
    
    /// In`timer` mode  the length of the timer.
    public var countDownTimeSeconds: Int = 0 {
        didSet {
            if mode == .timer {
                label.text = formatCountDownString(secondsLeft: countDownTimeSeconds)
            }
        }
    }
    
    /// In `clock` mode, this is the format that will be used to display the current time.
    public var timeFormat:String = "HH:mm"
    
    private var timer: Timer?
    
    private var stopDate: Date?
    
    private(set) var timeLeft: TimeInterval = 0
    
    var timerDone: Bool {
        get {
            return stopDate == nil && timeLeft == 0
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        commonInit()
    }
    
    private func commonInit() {
        label.text = "00:00"
        label.textColor = textColor
        label.font = font
        label.textAlignment = .center
        addSubview(label)
    }
    
    // MARK: - Layout subiews
    
    override func layoutSubviews() {
//        label.sizeToFit()
//        label.frame = CGRect(
//            x: 0,
//            y: 0 ,
//            width: bounds.width,
//            height: label.frame.height)
//
//        self.frame = CGRect(
//            x: frame.origin.x,
//            y: frame.origin.y,
//            width: frame.width,
//            height: label.frame.height
//        )
        
         label.frame = bounds
    }
    
    // MARK: - Private API
    private func startClock() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = timeFormat
        
        label.text = dateFormatter.string(from: Date())
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            timer in
            
            self.label.text = dateFormatter.string(from: Date())
        }
    }
    
    private func startTimer(interval: Double, handler: (()->Void)? ) {
        guard countDownTimeSeconds >= 0 else {
            fatalError("Can't create a timer with a negative count down time.")
        }
        
        let calendar = Calendar.current
        stopDate = calendar.date(
            byAdding: .second,
            value: countDownTimeSeconds,
            to: Date()
        )
        
        label.text = formatCountDownString(secondsLeft: Int(stopDate!.timeIntervalSinceNow))
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) {
            timer in
            
            self.timeLeft = self.stopDate!.timeIntervalSinceNow
            
            var timeLeftSeconds = Int(self.stopDate!.timeIntervalSinceNow)
            if timeLeftSeconds > self.countDownTimeSeconds {
                timeLeftSeconds = self.countDownTimeSeconds
            }
            if timeLeftSeconds < 0 {
                timeLeftSeconds = 0
                self.stop()
            }
            
            let timeLeftString = self.formatCountDownString(secondsLeft: timeLeftSeconds)
            self.label.text = timeLeftString
            if let handler = handler {
                handler()
            }
        }
    }
    
    /// Turns a number of seconds into a displayable string : "02:34"
    private func formatCountDownString(secondsLeft: Int) -> String {
        let minute = Int(secondsLeft / 60)
        var minuteString = String(minute)
        if minute < 10 {
            minuteString = "0" + minuteString
        }
        
        let second = secondsLeft % 60
        var secondString = String(second)
        if second < 10 {
            secondString = "0" + secondString
        }
        
        return minuteString + ":" + secondString
    }
    
    // MARK: - Public API
    
    /// Call this method to start the timer.
    public func start() {
        timer?.invalidate()
        start(interval: 1.0, handler: nil)
    }
    
    public func start(interval: Double, handler: (()->Void)?) {
        switch(mode) {
        case .clock:
            startClock()
        case .timer:
            startTimer(interval: interval, handler: handler)
        }
    }
    /// Call this method when the timer is no longer needed.
    public func stop() {
        timer?.invalidate()
        stopDate = nil
        countDownTimeSeconds = 0
        timeLeft = 0.0
    }
    
    public func pause() {
        guard mode == .timer else { return }
        guard timeLeft > 0 else {return}
        
        timer?.invalidate()
        stopDate = nil
        countDownTimeSeconds = Int(timeLeft)
    }
}
