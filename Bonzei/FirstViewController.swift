//
//  FirstViewController.swift
//  Bonzei
//
//  Created by Tomasz on 15/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class WakeUpViewController: UIViewController {
    
    @IBOutlet weak var setAlarmButton: UIButton!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstLabel.isHidden = false
        secondLabel.isHidden = true
        // Do any additional setup after loading the view.
    }

    @IBAction func setAlarmButtonPressed(_ sender: UIButton) {
        firstLabel.isHidden.toggle()
        secondLabel.isHidden.toggle()
    }
    
}

