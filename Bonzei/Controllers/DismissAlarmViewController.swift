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
    
    @IBOutlet weak var alarmSnoozedView: GradientView!
    
    @IBOutlet weak var snoozeButton: UIButton!
    
    // MARK:- Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAlarmTriggeredView()
        
        setupAlarmSnoozedView()
        
        snoozeButton.isHidden = true

    }
    
    private func setupAlarmTriggeredView() {
        alarmTriggeredView.topColor = BonzeiColors.Gradients.pink.top
        alarmTriggeredView.bottomColor = BonzeiColors.Gradients.pink.bottom
    }
    
    private func setupAlarmSnoozedView() {
        alarmSnoozedView.topColor = BonzeiColors.Gradients.pink.top
        alarmSnoozedView.bottomColor = BonzeiColors.Gradients.pink.bottom
    }
    
    
    // MARK:- Actions
    
    @IBAction func snoozeButtonPressed(_ sender: Any) {
        AlarmScheduler.sharedInstance.snooze()
        switchViews(from: alarmTriggeredView, to: alarmSnoozedView)
    }
    
    @IBAction func dismissAlarmButtonPressed(_ sender: UIButton) {
        AlarmScheduler.sharedInstance.dismissAlarm()
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
    }
    
    private func makeVisible(view: UIView) {
        view.alpha = 1.0
        view.isHidden = false
    }
    
    private func makeInvisible(view: UIView) {
        view.alpha = 0.0
        view.isHidden = true
    }
    
    // MARK:- Public API
    public func prepareToDismissAlarm(_ alarm: Alarm?) {
        guard let alarmToDismiss = alarm else { return }
        
        loadViewIfNeeded()
        
        snoozeButton.isHidden = !alarmToDismiss.snoozeEnabled
        
        if AlarmScheduler.sharedInstance.isAlarmPlaying {
            makeVisible(view: alarmTriggeredView)
            makeInvisible(view: alarmSnoozedView)
        }
        
//        if AlarmScheduler.sharedInstance.isAlarmSnoozed {
//            prepareAlarmSnoozedView()
//        }
    }
}
