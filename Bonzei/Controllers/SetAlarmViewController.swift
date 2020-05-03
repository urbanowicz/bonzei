//
//  SetAlarmViewController.swift
//  Bonzei
//
//  Created by Tomasz on 15/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit
import AVFoundation

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
    
    /// A  name of a melody that is currently displayed in this scene
    /// If a user presses the `saveButton` this is the melody that will be associated with the alarm.
    ///
    /// - See also: `Melody.swift`
    var selectedMelody = melodies[0]
    
    /// Audio player used for previewing melodies
    var audioPlayer: AVAudioPlayer?
    
    /// A standard date picker. Not customizable. Need to be replaced with a custom control.
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var melodyLabel: UILabel!
    
    @IBOutlet weak var playMelodyButton: UIButton!
    
    @IBOutlet weak var setMelodyButton: UIButton!
    
    @IBOutlet weak var dayOfWeekPicker: DayOfWeekPicker!
    
    @IBOutlet weak var snoozeSwitch: UISwitch!
    
    //MARK: - Initialization
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Clear the background that might have been set in the story board for debugging.
        playMelodyButton.backgroundColor = UIColor.clear
        setMelodyButton.backgroundColor = UIColor.clear
        
        // Setup a `UITapGestureRecognizer` for `melodyLabel`
        // When `melodyLabel` is tapped, we want to transition to `SetMelodyViewController`
        melodyLabel.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(SetAlarmViewController.melodyLabelTapped(tapRecoginzer:)))
        melodyLabel.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Check if we've transitioned from `WakeUpViewController` or from `SetMelodyViewController`
        // `isBeingPresented` equal to `true` means we've transitioned from `WakeUpViewController`.
        // `isBeingPresented` equal to `false` means we've transitioned back from `SetMelodyViewController.
        if isBeingPresented {
            switch request {
            case .newAlarm:
                melodyLabel.text = selectedMelody
                
            case .editExistingAlarm:
                let alarm = alarms[alarmIndex!]
                melodyLabel.text = alarm.melodyName
                selectedMelody = alarm.melodyName
                dayOfWeekPicker.selection = alarm.repeatOn
                datePicker.date = alarm.date
                snoozeSwitch.isOn = alarm.snoozeEnabled
            }
        }
        else {
            melodyLabel.text = selectedMelody
        }
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // If the audio is being played we need to stop it now.
        
        if let audioPlayer = self.audioPlayer {
            audioPlayer.stop()
        }
        
    }
    
    // MARK: - Actions and Navigation
    
    /// Starts or stops a melody preview.
    @IBAction func playMelodyButtonPressed(_ sender: UIButton) {
            
        // If a melody is being previewed, stop the playback and return immediately
        if audioPlayer != nil && audioPlayer!.isPlaying{
            audioPlayer!.stop()
            return
        }
        
        // Play the selected melody
        if let path = Bundle.main.path(forResource: selectedMelody + ".mp3", ofType: nil) {
            
            let url = URL(fileURLWithPath: path)
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("Playing a melody failed. \"\(selectedMelody).mp3\"")
            }
            
        } else {
            print("Couldn't preview a melody because the sound file was not found: \"\(selectedMelody).mp3\"")
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
    
    /// Called when  `melodyLabel` is tapped.
    @IBAction func melodyLabelTapped(tapRecoginzer: UITapGestureRecognizer) {
       
        performSegue(withIdentifier: "SetAlarmToSetMelody", sender: self)
    
    }
    
    @IBAction func unwindSetMelody(_ unwindSegue: UIStoryboardSegue) {
        
        let setMelodyViewController = unwindSegue.source as! SetMelodyViewController
        if setMelodyViewController.selectedMelody != nil {
            selectedMelody = setMelodyViewController.selectedMelody!
        }
    
    }
}
