//
//  SetAlarmViewController.swift
//  Bonzei
//
//  Created by Tomasz on 15/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit
import AVFoundation

class SetAlarmViewController: UIViewController, AVAudioPlayerDelegate {
    
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
    /// - In case of 'RequestType.editExistingAlarm' the variable must contain the alarm that a user wishes to edit.
    /// - Must be set by the presenting view controller.
    var alarmToEdit: Alarm?
    
    /// A  name of a melody that is currently displayed in this scene
    /// If a user presses the `saveButton` this is the melody that will be associated with the alarm.
    ///
    /// - See also: `Melody.swift`
    var selectedMelody = melodies[0]
    
    /// Audio player used for previewing melodies
    var audioPlayer: AVAudioPlayer?
    
    /// Indicates whether a user is previewing the selected melody
    var isMelodyPlaying = false {
        didSet {
            if isMelodyPlaying {
                playMelodyButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            } else {
                playMelodyButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
        }
    }
    
    /// A standard date picker. Not customizable. Need to be replaced with a custom control.
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var melodyLabel: UILabel!
    
    @IBOutlet weak var playMelodyButton: UIButton!
    
    @IBOutlet weak var setMelodyButton: UIButton!
    
    @IBOutlet weak var dayOfWeekPicker: DayOfWeekPicker!
    
    @IBOutlet weak var snoozeSwitch: UISwitch!
    
    @IBOutlet weak var clock: Clock!
    
    //MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // So that we can play sound in silent mode:
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        } catch {
            
        }
        
        // Clear the background that might have been set in the story board for debugging.
        playMelodyButton.backgroundColor = UIColor.clear
        
        setMelodyButton.backgroundColor = UIColor.clear
        
        snoozeSwitch.onTintColor = BonzeiColors.gray
        
        // Setup a `UITapGestureRecognizer` for `melodyLabel`
        // When `melodyLabel` is tapped, we want to transition to `SetMelodyViewController`
        melodyLabel.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(SetAlarmViewController.melodyLabelTapped(tapRecoginzer:)))
        melodyLabel.addGestureRecognizer(tapGestureRecognizer)
        
        datePicker.addTarget(self, action: #selector(SetAlarmViewController.datePickerValueChanged), for: .valueChanged)
        
    }
    
    func prepareTofulfillRequest(withType requestType: RequestType, forAlarm alarm: Alarm?) {
        loadViewIfNeeded()
        
        request = requestType
        
        switch request {
        case .newAlarm:
            melodyLabel.text = selectedMelody
            
        case .editExistingAlarm:
            alarmToEdit = alarm
            melodyLabel.text = alarmToEdit!.melodyName
            selectedMelody = alarmToEdit!.melodyName
            dayOfWeekPicker.selection = alarmToEdit!.repeatOn
            datePicker.date = alarmToEdit!.date
            snoozeSwitch.isOn = alarmToEdit!.snoozeEnabled
        }
        
        clock.setTime(date: datePicker.date)
        setSnoozeSwitchThumbTintColor()
    }
    
    // MARK: - Actions and Navigation
    
    /// Starts or stops a melody preview.
    @IBAction func playMelodyButtonPressed(_ sender: UIButton) {
            
        // If a melody is being previewed, stop the playback and return immediately
        if audioPlayer != nil && audioPlayer!.isPlaying{
            stopPlayback()
            return
        }
        
        // Play the selected melody
        if let path = Bundle.main.path(forResource: selectedMelody + ".mp3", ofType: nil) {
            
            let url = URL(fileURLWithPath: path)
            
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("activating session failed")
            }
                
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
                audioPlayer?.play()
                isMelodyPlaying = true
            } catch {
                print("Playing a melody failed. \"\(selectedMelody).mp3\"")
            }
            
        } else {
            print("Couldn't preview a melody because the sound file was not found: \"\(selectedMelody).mp3\"")
        }
    }

    @IBAction func saveButtonPressed(_ sender: UIButton) {
        switch request {
        case .newAlarm:
             newAlarm = Alarm(
                date: datePicker.date,
                repeatOn: dayOfWeekPicker.selection,
                melodyName: selectedMelody,
                snoozeEnabled: snoozeSwitch.isOn
            )
        
        case .editExistingAlarm:
            let alarm = Alarm(
                id: alarmToEdit!.id,
                date: datePicker.date,
                repeatOn: dayOfWeekPicker.selection,
                melodyName: selectedMelody,
                snoozeEnabled: snoozeSwitch.isOn,
                isActive: true
            )
            
            alarmToEdit = alarm
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
            melodyLabel.text = selectedMelody
        }
    }
    
    @IBAction func snoozeSwitchToggled(_ sender: UISwitch) {
        setSnoozeSwitchThumbTintColor()
    }
    
    @IBAction func datePickerValueChanged(sender: UIDatePicker, forEvent event: UIEvent) {
        print(datePicker.date)
        clock.setTime(date: datePicker.date)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        stopPlayback()
        
        if segue.identifier! == "SetAlarmToSetMelody" {
            let setMelodyViewController = segue.destination as! SetMelodyViewController
            setMelodyViewController.selectedMelody = selectedMelody
        }
    }
    
    //MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isMelodyPlaying = false
    }
    
    //MARK: - Helper functions
    
    private func stopPlayback() {
        isMelodyPlaying = false
        if let audioPlayer = self.audioPlayer {
            audioPlayer.stop()
        }
    }
    
    private func setSnoozeSwitchThumbTintColor() {
        if snoozeSwitch.isOn {
            snoozeSwitch.thumbTintColor = BonzeiColors.jungleGreen
        } else {
            snoozeSwitch.thumbTintColor = UIColor.white
        }
    }
}
