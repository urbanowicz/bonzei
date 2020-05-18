//
//  DismissAlarmViewController.swift
//  Bonzei
//
//  Created by Tomasz on 18/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class DismissAlarmViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func dismissAlarmButtonPressed(_ sender: UIButton) {
        AlarmScheduler.sharedInstance.dismissAlarm()
        performSegue(withIdentifier: "UnwindDismissAlarm", sender: self)
    }
    
}
