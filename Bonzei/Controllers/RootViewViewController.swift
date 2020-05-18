//
//  RootViewViewController.swift
//  Bonzei
//
//  Created by Tomasz on 18/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class RootViewViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
         if AlarmScheduler.sharedInstance.isAlarmPlaying {
             performSegue(withIdentifier: "PresentDismissAlarm", sender: self)
             return
         }
    }
    
    /// Called when an alarm is playing and a user has just dismissed it
    @IBAction func unwindDismissAlarm(_ unwindSegue: UIStoryboardSegue) {
        print("Hellloooo")
        // Nothing to do here.
    }
}
