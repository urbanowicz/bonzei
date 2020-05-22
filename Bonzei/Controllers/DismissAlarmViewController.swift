//
//  DismissAlarmViewController.swift
//  Bonzei
//
//  Created by Tomasz on 18/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class DismissAlarmViewController: UIViewController {

    @IBOutlet weak var snoozeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        snoozeButton.isHidden = true
    }
    
    func prepareToDismissAlarm(_ alarm: Alarm?) {
        guard let alarmToDismiss = alarm else { return }
       
        loadViewIfNeeded()
        
        snoozeButton.isHidden = !alarmToDismiss.snoozeEnabled
    }
    
    @IBAction func snoozeButtonPressed(_ sender: Any) {
        AlarmScheduler.sharedInstance.snooze()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissAlarmButtonPressed(_ sender: UIButton) {
        AlarmScheduler.sharedInstance.dismissAlarm()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
