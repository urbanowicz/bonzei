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
    
    public var mode: Mode = .clock
    
    /// A label used to display the time. eg '05:55'
    public var label = UILabel()
    
    /// In`timer` mode  the length of the timer.
    public var countDownTimeSeconds: Int = 0
    
    /// In `clock` mode, this is the format that will be used to display the current time.
    public var timeFormat:String = "HH:mm"
    
    private var timer: Timer?
    
    private var stopDate: Date?
    
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
    
    private func startTimer() {
        guard countDownTimeSeconds >= 0 else {
            fatalError("Can't create a timer with a negative count down time.")
        }
        
        label.text = formatCountDownString(secondsLeft: countDownTimeSeconds)
        
        let calendar = Calendar.current
        stopDate = calendar.date(
            byAdding: .second,
            value: countDownTimeSeconds,
            to: Date()
        )
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            timer in
            
            var timeLeft = Int(self.stopDate!.timeIntervalSinceNow)
            if timeLeft > self.countDownTimeSeconds {
                timeLeft = self.countDownTimeSeconds
            }
            if timeLeft < 0 {
                timeLeft = 0
                self.stop()
            }
            
            let timeLeftString = self.formatCountDownString(secondsLeft: timeLeft)
            self.label.text = timeLeftString
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
        
        switch(mode){
        case .clock:
            startClock()
        case .timer:
            startTimer()
        }
    }
    /// Call this method when the timer is no longer needed.
    public func stop() {
        timer?.invalidate()
        stopDate = nil
        countDownTimeSeconds = 0
    }
}
