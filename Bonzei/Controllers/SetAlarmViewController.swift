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
    var request: RequestType = .newAlarm
    
    /// - In case of 'RequestType.newAlarm' this variable will hold the new alarm after it has been created by this controller.
    /// - In case of 'RequestType.editExistingAlarm' the variable is ignored.
    var newAlarm: Alarm?
    
    /// - In case of 'RequestType.newAlarm' the variable is ignored.
    /// - In case of 'RequestType.editExistingAlarm' the variable must be set to a valid index of the alarm that a user wishes to edit.
    /// - Must be set by the presenting view controller.
    var alarmIndex: Int?
    
    var selectedMelody = "Ambient Sea Waves"
    
    //A standard date picker. Not customizable. Need to be replaced with a custom widget.
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var melodyLabel: UILabel!
    @IBOutlet weak var playMelodyButton: UIButton!
    @IBOutlet weak var setMelodyButton: UIButton!
    @IBOutlet weak var dayOfWeekPicker: DayOfWeekPicker!
    @IBOutlet weak var snoozeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playMelodyButton.backgroundColor = UIColor.clear
        setMelodyButton.backgroundColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isBeingPresented {
            switch request {
            case .newAlarm:
                melodyLabel.text = selectedMelody
                
            case .editExistingAlarm:
                let alarm = alarms[alarmIndex!]
                melodyLabel.text = alarm.melodyName
                dayOfWeekPicker.selection = alarm.repeatOn
                datePicker.date = alarm.date
                snoozeSwitch.isOn = alarm.snoozeEnabled
            }
        }
        else {
            melodyLabel.text = selectedMelody
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let alarm = Alarm(
            date: datePicker.date,
            repeatOn: dayOfWeekPicker.selection,
            melodyName: selectedMelody,
            snoozeEnabled: snoozeSwitch.isOn
        )
        
        switch request {
        case .newAlarm:
            newAlarm = alarm
        
        case .editExistingAlarm:
            alarms[alarmIndex!] = alarm
        }
        
        performSegue(withIdentifier: "unwindSaveAlarmSegue", sender: self) 
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindCancel", sender: self)
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
