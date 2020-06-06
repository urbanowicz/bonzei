//
//  DismissAlarmViewController.swift
//  Bonzei
//
//  Created by Tomasz on 18/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class DismissAlarmViewController: UIViewController {

    @IBOutlet weak var alarmTriggeredView: GradientView!
    
    @IBOutlet weak var clockTimer: TimerView!
    
    @IBOutlet weak var snoozeButton: UIButton!
    
    @IBOutlet weak var alarmSnoozedView: GradientView!
    
    @IBOutlet weak var countDownTimer: TimerView!
    
    var clockTimerFontName: String = "Muli-SemiBold"
    
    var clockTimerFontSize = 40.0
    
    var clockTimerTextColor = BonzeiColors.darkTextColor
    
    private var currentView: UIView!
    
    // MARK:- Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAlarmTriggeredView()
        setupClockTimer()
        
        setupAlarmSnoozedView()
        setupCountDownTimer()
        
        snoozeButton.isHidden = true

    }
    
    private func setupAlarmTriggeredView() {
        alarmTriggeredView.topColor = BonzeiColors.Gradients.pink.top
        alarmTriggeredView.bottomColor = BonzeiColors.Gradients.pink.bottom
    }
    
    private func setupClockTimer() {
        clockTimer.mode = .clock
        clockTimer.label.textAlignment = .center
        clockTimer.label.font = loadCustomFont(
            fontName: clockTimerFontName,
            fontSize: clockTimerFontSize
        )
        clockTimer.label.textColor = clockTimerTextColor
        clockTimer.backgroundColor = UIColor.clear
        clockTimer.label.backgroundColor = UIColor.clear
    }
    
    private func setupAlarmSnoozedView() {
        alarmSnoozedView.topColor = BonzeiColors.Gradients.pink.top
        alarmSnoozedView.bottomColor = BonzeiColors.Gradients.pink.bottom
    }
    
    private func setupCountDownTimer() {
        countDownTimer.mode = .timer
        countDownTimer.label.textAlignment = .center
    }
    
    // MARK:- Actions
    
    @IBAction func snoozeButtonPressed(_ sender: Any) {
        AlarmScheduler.sharedInstance.snooze()
    }
    
    @IBAction func dismissAlarmButtonPressed(_ sender: UIButton) {
        AlarmScheduler.sharedInstance.dismissAlarm()
        countDownTimer.stop()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Private API
    
    /// Used to switch between the `alarmSnoozed' and 'alarmTriggered' views`
    private func switchViews(from fromView: UIView, to toView: UIView) {
        toView.alpha = 0
        toView.isHidden = false
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
            fromView.alpha = 0.0
            toView.alpha = 1.0
            
        }, completion: { finished in
            fromView.isHidden = true
        })
        
        currentView = toView
    }
    
    private func makeVisible(view: UIView) {
        view.alpha = 1.0
        view.isHidden = false
    }
    
    private func makeInvisible(view: UIView) {
        view.alpha = 0.0
        view.isHidden = true
    }
    
    private func loadCustomFont(fontName: String, fontSize: Double) -> UIFont {
        guard let customFont = UIFont(name: fontName , size: CGFloat(fontSize)) else {
            return UIFont.systemFont(ofSize: CGFloat(fontSize))
        }
        
        return UIFontMetrics.default.scaledFont(for: customFont)
    }
    
    func didSnoozeAlarm(_ alarm: Alarm) {
        switchViews(from: alarmTriggeredView, to: alarmSnoozedView)
        clockTimer.stop()
        
        countDownTimer.countDownTimeSeconds = AlarmScheduler.sharedInstance.snoozeTimeMinutes * 60
        countDownTimer.start()
    }
    
    func didTriggerAlarm(_ alarm: Alarm) {
        if currentView == alarmSnoozedView {
            switchViews(from: alarmSnoozedView, to: alarmTriggeredView)
            currentView = alarmTriggeredView
        }
        
        snoozeButton.isHidden = !alarm.snoozeEnabled
        clockTimer.start()
    }
    
    // MARK:- Public API
    public func prepareToDismissAlarm() {
        
        loadViewIfNeeded()
        
        if AlarmScheduler.sharedInstance.isAlarmPlaying {
            let alarmToDismiss = AlarmScheduler.sharedInstance.currentlyTriggeredAlarm!
            
            snoozeButton.isHidden = !alarmToDismiss.snoozeEnabled
            
            makeVisible(view: alarmTriggeredView)
            makeInvisible(view: alarmSnoozedView)
            
            currentView = alarmTriggeredView
            
            clockTimer.start()
        } else if AlarmScheduler.sharedInstance.isAlarmSnoozed {
            fatalError("Not implemented yet")
        }
    }
}
