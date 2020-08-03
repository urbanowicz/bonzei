//
//  SoundPickerViewController.swift
//  Bonzei
//
//  Created by Tomasz on 03/08/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class SoundPickerViewController: UIViewController {
    
    @IBOutlet weak var mainHeaderLabel: UILabel!
    
    var mainHeader: String? {
        didSet {
            mainHeaderLabel.text = mainHeader
        }
    }
    
    var soundHeader: String?
    
    var timeHeader: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMainHeader()
        setupSoundHeader()
        setupTimeHeader()
        
        // Do any additional setup after loading the view.
    }
    
    private func setupMainHeader() {
        mainHeader = "Power nap"
    }
    
    private func setupSoundHeader() {
        soundHeader = "BINAURAL BEAT"
    }
    
    private func setupTimeHeader() {
        timeHeader = "NAP TIME"
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
    }
}
