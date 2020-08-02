//
//  PowerModeViewController.swift
//  Bonzei
//
//  Created by Tomasz on 27/07/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class PowerModeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FirebasePowerNapProvider.sharedInstance.syncWithBackend {
            print("Done.")
        }
    }
}
