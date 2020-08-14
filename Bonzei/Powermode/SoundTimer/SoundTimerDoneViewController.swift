//
//  SoundTimerDoneViewController.swift
//  Bonzei
//
//  Created by Tomasz on 08/08/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit
import AVFoundation

class SoundTimerDoneViewController: UIViewController {
    
    var powerNap: PowerNap!
    
    let alarmSoundFileName = "Crystal Vision.mp3"
    
    public var backgroundTopColor = #colorLiteral(red: 0.1377221048, green: 0.249750644, blue: 0.2173544168, alpha: 1) {
        didSet {
            if let gradientView = self.view as? GradientView {
                gradientView.topColor = backgroundTopColor
            }
        }
    }
    
    public var backgroundBottomColor = #colorLiteral(red: 0.1411813796, green: 0.3443938792, blue: 0.2596455514, alpha: 1) {
        didSet {
            if let gradientView = self.view as? GradientView  {
                gradientView.bottomColor = backgroundBottomColor
            }
        }
    }
    
    @IBOutlet weak var soundNameLabel: UILabel!
    
    private var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        soundNameLabel.text = powerNap.melodyName
        
        backgroundTopColor = UIColor(hexString: powerNap.gradientTopColor)
        backgroundBottomColor = UIColor(hexString: powerNap.gradientBottomColor)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        playAudio()
    }

    @IBAction func dismissButtonPressed(_ sender: Any) {
        audioPlayer?.setVolume(0, fadeDuration: 0.05)
        Thread.sleep(forTimeInterval: 0.1)
        audioPlayer?.stop()
        
        performSegue(withIdentifier: "SoundTimerDoneToSoundPicker", sender: self)
    }
    
    private func playAudio() {
        let soundFile = self.alarmSoundFileName
        
        if let path = Bundle.main.path(forResource: soundFile, ofType: nil) {
            let url = URL(fileURLWithPath: path)
            
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                
            }
                
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.setVolume(1.0, fadeDuration: 0.1)
                audioPlayer?.numberOfLoops = 500
                audioPlayer?.play()
            } catch {
                
            }
        }
    }
}
