//
//  DismissAlarmViewController.swift
//  Bonzei
//
//  Created by Tomasz on 18/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class DismissAlarmViewController: UIViewController {

    @IBOutlet weak var alarmTriggeredView: MovingGradientView!
    
    @IBOutlet weak var clockTimer: TimerView!
    
    @IBOutlet weak var snoozeButton: UIButton!
    
    @IBOutlet weak var alarmSnoozedView: MovingGradientView!
    
    @IBOutlet weak var countDownTimer: TimerView!
    
    @IBOutlet weak var melodyNameLabel: UILabel!
    
    private var clockTimerFontName = "Muli-SemiBold"
    
    private var clockTimerFontSize = 40.0
    
    private var clockTimerTextColor = BonzeiColors.darkTextColor
    
    private var countDownTimerFontName = "Muli-SemiBold"
    
    private var countDownTimerFontSize = 57.0
    
    private var countDowntimerTextColor = UIColor.white
    
    private var currentView: UIView!
    
    private var melodyName: String? {
        didSet {
            melodyNameLabel.text = "\u{266A} \(melodyName ?? "")"
        }
    }
    
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
        alarmTriggeredView.topColor =  UIColor(red: 1.00, green: 0.76, blue: 0.73, alpha: 1.00)
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
        alarmSnoozedView.topColor = UIColor(red: 1.00, green: 0.76, blue: 0.73, alpha: 1.00)
        alarmSnoozedView.bottomColor = BonzeiColors.Gradients.pink.bottom
    }
    
    private func setupCountDownTimer() {
        countDownTimer.mode = .timer
        countDownTimer.label.textAlignment = .center
        countDownTimer.label.font = loadCustomFont(
            fontName: countDownTimerFontName,
            fontSize: countDownTimerFontSize
        )
        countDownTimer.label.textColor = countDowntimerTextColor
        countDownTimer.backgroundColor = UIColor.clear
        countDownTimer.label.backgroundColor = UIColor.clear
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
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
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
        print("HELLLOOO")
        melodyName = AlarmScheduler.sharedInstance.currentlyPlayedMelody
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
            melodyName = AlarmScheduler.sharedInstance.currentlyPlayedMelody
            
            let alarmToDismiss = AlarmScheduler.sharedInstance.currentlyTriggeredAlarm!
            
            snoozeButton.isHidden = !alarmToDismiss.snoozeEnabled
            
            makeVisible(view: alarmTriggeredView)
            makeInvisible(view: alarmSnoozedView)
            
            currentView = alarmTriggeredView
            
            clockTimer.start()
        } else if AlarmScheduler.sharedInstance.isAlarmSnoozed {
            makeVisible(view: alarmSnoozedView)
            makeInvisible(view: alarmTriggeredView)
            currentView = alarmSnoozedView
            
            let stopDate = AlarmScheduler.sharedInstance.currentlySnoozedAlarm!.snoozeDate!
            
            countDownTimer.countDownTimeSeconds = Int(stopDate.timeIntervalSinceNow)
            countDownTimer.start()
        }
    }
}
