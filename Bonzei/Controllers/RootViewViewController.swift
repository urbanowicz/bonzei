//
//  RootViewViewController.swift
//  Bonzei
//
//  Created by Tomasz on 18/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class RootViewViewController: UITabBarController, AlarmSchedulerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AlarmScheduler.sharedInstance.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
         if AlarmScheduler.sharedInstance.isAlarmPlaying {
             performSegue(withIdentifier: "PresentDismissAlarm", sender: self)
             return
         }
    }
    
    /// Called when an alarm is playing and a user has just dismissed it
    @IBAction func unwindDismissAlarm(_ unwindSegue: UIStoryboardSegue) {
        // Nothing to do here.
    }
    
    // MARK: - AlarmSchedulerDelegate
    
    func didTriggerAlarm(_ alarm: Alarm) {
        // if the view is loaded and alarm has been triggered, present the `DismissAlarmViewController` 
        if self.isViewLoaded {
            performSegue(withIdentifier: "PresentDismissAlarm", sender: self)
        }
    }
}
