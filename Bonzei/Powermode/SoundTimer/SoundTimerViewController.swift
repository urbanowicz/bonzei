//
//  SoundTimerViewController.swift
//  Bonzei
//
//  Created by Tomasz on 06/08/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit
import AVFoundation

class SoundTimerViewController: UIViewController {
    
    public var powerNap: PowerNap!
    
    public var backgroundTopColor = #colorLiteral(red: 0.137254902, green: 0.2509803922, blue: 0.2156862745, alpha: 1) {
        didSet {
            backgroundCircleView.topColor = backgroundTopColor
        }
    }
    public var backgroundBottomColor = #colorLiteral(red: 0.1411764706, green: 0.3450980392, blue: 0.2588235294, alpha: 1) {
        didSet {
            backgroundCircleView.bottomColor = backgroundBottomColor
        }
    }
    
    public var napTime: TimeInterval = 60.0
    
    @IBOutlet weak var backgroundCircleView: GradientView!
    
    private let backgroundCircleBorder = CAShapeLayer()
   
    @IBOutlet weak var circularProgressView: CircularProgressView!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var timerView: TimerView!
    
    @IBOutlet weak var soundNameLabel: UILabel!
    
    private var isTimerPaused = false
    
    private var audioPlayer: AVAudioPlayer?
    
    private var soundFile = "Rainforest.mp3"
    
    private var isFadingOut = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        soundNameLabel.text = powerNap.melodyName
        
        soundFile = "\(powerNap.melodyName)_\(Int(napTime/60)).mp3"
        setupBackgroundCircleView()
        setupTimerView()
        
        setupAudioSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Clip the circle in the background
        self.view.clipsToBounds = true
        
        startNap()
    }
    
    private func setupBackgroundCircleView() {
        backgroundTopColor = UIColor(hexString: powerNap.gradientTopColor)
        backgroundBottomColor = UIColor(hexString: powerNap.gradientBottomColor)
        
        backgroundCircleBorder.backgroundColor = UIColor.clear.cgColor
        backgroundCircleBorder.strokeColor = backgroundBottomColor.cgColor
        backgroundCircleBorder.fillColor = UIColor.clear.cgColor
        backgroundCircleBorder.lineWidth = 1.0
        view.layer.insertSublayer(backgroundCircleBorder, at: 0)
    }
    
    private func setupTimerView() {
        timerView.mode = .timer
        timerView.countDownTimeSeconds = Int(napTime)
        if let font = UIFont(name: "Muli-SemiBold", size: 57) {
            timerView.font = font
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        } catch {
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        layoutBackgroundCircleView()
    }
    
    private func layoutBackgroundCircleView() {
        backgroundCircleView.locations = [0.5, 1.0]
        backgroundCircleView.layer.cornerRadius = backgroundCircleView.bounds.height / 2.0
        
        backgroundCircleBorder.frame = backgroundCircleView.frame
        backgroundCircleBorder.path = UIBezierPath.init(ovalIn: backgroundCircleBorder.bounds).cgPath
    }
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        if (isTimerPaused) {
            startNap()
            isTimerPaused = false
            playPauseButton.setImage(UIImage(named: "pause-button"), for: .normal)
        } else {
            pauseNap()
            isTimerPaused = true
            playPauseButton.setImage(UIImage(named: "play-button"), for: .normal)
        }
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        stopNap()
        performSegue(withIdentifier: "UnwindToSoundPicker", sender: self)
    }
    
    private func startNap() {
        guard timerView.countDownTimeSeconds > 0 else { return }
        
        timerView.start(interval: 0.1) {
            let progress = (self.napTime - self.timerView.timeLeft) / self.napTime
            self.circularProgressView.progress = progress
            
            if (self.timerView.timeLeft <= 3 && !self.isFadingOut ) {
                self.audioPlayer?.setVolume(0.0, fadeDuration: self.timerView.timeLeft)
                self.isFadingOut = true
            }
            
            if self.timerView.timerDone {
                self.stopNap()
                self.performSegue(withIdentifier: "SoundTimerDone", sender: self)
            }
        }
        
        // Play audio
        isFadingOut = false
        
        if audioPlayer != nil {
            audioPlayer!.play()
            return
        }
        
        if let path = Bundle.main.path(forResource: soundFile, ofType: nil) {
            let url = URL(fileURLWithPath: path)
            
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                
            }
                
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.setVolume(1.0, fadeDuration: 0.1)
                audioPlayer?.play()
            } catch {
                
            }
        }
    }
    
    private func pauseNap() {
        timerView.pause()
        
        if audioPlayer != nil {
            audioPlayer!.pause()
        }
    }
    
    private func stopNap() {
        timerView.stop()
        
        if audioPlayer != nil {
            audioPlayer!.setVolume(0, fadeDuration: 0.05)
            Thread.sleep(forTimeInterval: 0.1)
            audioPlayer!.stop()
            audioPlayer = nil
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SoundTimerDone" {
            let timerDoneVC = segue.destination as! SoundTimerDoneViewController
            
            timerDoneVC.powerNap = powerNap
        }
    }
}

fileprivate class CircleView: GradientView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // size of the bounds of the circle
        let a = (812.0 / 1069.0) * UIScreen.main.bounds.height
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = CGRect(x: 0, y: 0, width: a, height: a)
        maskLayer.path = UIBezierPath.init(ovalIn: maskLayer.frame).cgPath
        
        layer.mask = maskLayer
    }
}
