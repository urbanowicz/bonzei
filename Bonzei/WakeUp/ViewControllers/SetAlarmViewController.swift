//
//  SetAlarmViewController.swift
//  Bonzei
//
//  Created by Tomasz on 15/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit
import AVFoundation

class SetAlarmViewController: UIViewController, AVAudioPlayerDelegate, TimePickerDelegate {
    
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
                playMelodyButton.setImage(UIImage(named: "pause-button-regular"), for: .normal)
            } else {
                playMelodyButton.setImage(UIImage(named: "play-button-regular"), for: .normal)
            }
        }
    }
    
    @IBOutlet weak var timePicker: TimePickerView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var melodyLabel: UILabel!
    
    @IBOutlet weak var playMelodyButton: UIButton!
    
    @IBOutlet weak var setMelodyButton: UIButton!
    
    @IBOutlet weak var dayOfWeekPicker: DayOfWeekPicker!
    
    @IBOutlet weak var snoozeSwitch: UISwitch!
    
    @IBOutlet weak var clock: BonzeiClock!
    
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
        
        timePicker.setDelegate(self)
    }
    
    func prepareTofulfillRequest(withType requestType: RequestType, forAlarm alarm: Alarm?) {
        loadViewIfNeeded()
        
        request = requestType
        
        switch request {
        case .newAlarm:
            selectedMelody = melodies[Int.random(in: 0..<melodies.count)]
            melodyLabel.text = selectedMelody
            timePicker.setDate(to: Date())
            
        case .editExistingAlarm:
            alarmToEdit = alarm
            melodyLabel.text = alarmToEdit!.melodyName
            selectedMelody = alarmToEdit!.melodyName
            dayOfWeekPicker.selection = alarmToEdit!.repeatOn
            timePicker.setDate(to: alarmToEdit!.date)
            snoozeSwitch.isOn = alarmToEdit!.snoozeEnabled
        }
        
        clock.setTime(date: timePicker.getDate(), animated: false)
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
        
        var soundFileName = selectedMelody + ".mp3"
        if selectedMelody == "Shuffle" {
            soundFileName = melodies[Int.random(in: 0..<melodies.count)] + ".mp3"
        }
        
        // Play the selected melody
        if let path = Bundle.main.path(forResource: soundFileName, ofType: nil) {
            
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
                print("Playing a melody failed. \"\(soundFileName)\"")
            }
            
        } else {
            print("Couldn't preview a melody because the sound file was not found: \"\(soundFileName)\"")
        }
    }

    @IBAction func saveButtonPressed(_ sender: UIButton) {
        switch request {
        case .newAlarm:
             newAlarm = Alarm(
                date: timePicker.getDate(),
                repeatOn: dayOfWeekPicker.selection,
                melodyName: selectedMelody,
                snoozeEnabled: snoozeSwitch.isOn
            )
        
        case .editExistingAlarm:
            let alarm = Alarm(
                id: alarmToEdit!.id,
                date: timePicker.getDate(),
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
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        stopPlayback()
        
        if segue.identifier! == "SetAlarmToSetMelody" {
            let setMelodyViewController = segue.destination as! SetMelodyViewController
            setMelodyViewController.selectedMelody = selectedMelody
        }
    }
    
    //MARK: - Acting as TimePickerDelegate
    
    func hourPickerDidScroll(picker: WraparoundPickerView) {
        let scrollProgress = picker.getScrollProgress()
        var angle = 0.0
        
        if timePicker.is24mode {
            
            // In 24 hour mode progress of 0.5 means 12 o'clock
            // and progress of 1.0 means 24
            // we need to adjust the progress so that the values between 0.5 and 1.0
            // mean the same thing as values between 0.0 and 0.5.
            // The clock only goes from 0 to 12 after all.
            
            var scrollProgressDoubled = scrollProgress * 24.0
            if scrollProgressDoubled >= 12.0 {
                scrollProgressDoubled -= 12.0
            }
            scrollProgressDoubled /= 12.0
            
            angle = (2.0 * .pi) * scrollProgressDoubled
        } else {

        // In AM/PM mode we need to move the angle forward by the equivalent of one hour.
        // When the AM/PM picker reports scrollProgress of 0 it means 1 o'clock
        // But if we pass 0 angle to the clock it will position the hand at 12 o'clock.
        // Hence the adjustment.
            
            angle = (2.0 * .pi) * scrollProgress + (.pi / 6.0)
        }

        clock.setHourAngle(to: angle)
    }
    
    func minutePickerDidScroll(picker: WraparoundPickerView) {
        let scrollProgress = picker.getScrollProgress()
        
        let angle = (2.0 * .pi) * scrollProgress
        
        clock.setMinuteAngle(to: angle)
    }
    //MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isMelodyPlaying = false
    }
    
    //MARK: - Helper functions
    
    private func stopPlayback() {
        isMelodyPlaying = false
        if let audioPlayer = self.audioPlayer {
            let queue = DispatchQueue(label: "StopAudio", qos: .userInteractive)
            queue.async {
                audioPlayer.setVolume(0, fadeDuration: 0.05)
                Thread.sleep(forTimeInterval: 0.1)
                audioPlayer.stop()
                self.audioPlayer = nil
            }
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
