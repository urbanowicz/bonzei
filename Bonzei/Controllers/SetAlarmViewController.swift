//
//  SetAlarmViewController.swift
//  Bonzei
//
//  Created by Tomasz on 15/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class SetAlarmViewController: UIViewController {
    
    var newAlarm:Alarm?
    
    var selectedMelody = "Ambient Sea Waves"
    //A standard date picker. Not customizable. Need to be replaced with a custom widget.
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var melodyLabel: UILabel!
    @IBOutlet weak var playMelodyButton: UIButton!
    @IBOutlet weak var setMelodyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playMelodyButton.backgroundColor = UIColor.clear
        setMelodyButton.backgroundColor = UIColor.clear 
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        melodyLabel.text = selectedMelody
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        newAlarm = Alarm(date: datePicker.date, melodyName: selectedMelody)
        performSegue(withIdentifier: "unwindSaveAlarmSegue", sender: self) 
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func unwindSetMelody(_ unwindSegue: UIStoryboardSegue) {
        let setMelodyViewController = unwindSegue.source as! SetMelodyViewController
        if setMelodyViewController.selectedMelody != nil {
            selectedMelody = setMelodyViewController.selectedMelody!
        }
    }
}
