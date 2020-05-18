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

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func dismissAlarmButtonPressed(_ sender: UIButton) {
        shouldPerformSegue(withIdentifier: "UnwindDismissAlarm", sender: self)
    }
    
}
