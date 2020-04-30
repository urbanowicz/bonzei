//
//  SetAlarmViewController.swift
//  Bonzei
//
//  Created by Tomasz on 15/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class SetAlarmViewController: UIViewController {
    
    /// Used to indicate the kind of request the controller is requested to handle.
    /// - 'newAlarm' means a user wishes to set a new alarm.
    /// - 'editExistingAlarm' means a user wishes to edit an alarm he has previously created.
    enum RequestType {
        case newAlarm
        case editExistingAlarm
    }
    
    /// Used to indicate the kind of request the controller is requested to handle.
    /// Must be set by the presenting controller
    var request:RequestType = .newAlarm
    
    /// - In case of 'RequestType.newAlarm' request this variable will hold the newly created alarm.
    /// - In case of 'RequestType.editExistingAlarm' the variable should be ignored.
    var newAlarm:Alarm?
    
    var selectedMelody = "Ambient Sea Waves"
    
    //A standard date picker. Not customizable. Need to be replaced with a custom widget.
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var melodyLabel: UILabel!
    @IBOutlet weak var playMelodyButton: UIButton!
    @IBOutlet weak var setMelodyButton: UIButton!
    @IBOutlet weak var dayOfWeekPicker: DayOfWeekPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playMelodyButton.backgroundColor = UIColor.clear
        setMelodyButton.backgroundColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        melodyLabel.text = selectedMelody
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        //1.
        newAlarm = Alarm(date: datePicker.date,
                         repeatOn: dayOfWeekPicker.selection,
                         melodyName: selectedMelody)
        
        //2.
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
