//
//  SoundTimerViewController.swift
//  Bonzei
//
//  Created by Tomasz on 06/08/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class SoundTimerViewController: UIViewController {
    
    public var backgroundTopColor = #colorLiteral(red: 0.1377221048, green: 0.249750644, blue: 0.2173544168, alpha: 1) {
        didSet {
            backgroundCircleView.topColor = backgroundTopColor
        }
    }
    public var backgroundBottomColor = #colorLiteral(red: 0.1411813796, green: 0.3443938792, blue: 0.2596455514, alpha: 1) {
        didSet {
            backgroundCircleView.bottomColor = backgroundBottomColor
        }
    }
    
    public var napTime: TimeInterval = 30.0
    
    @IBOutlet weak var backgroundCircleView: GradientView!
    
    private let backgroundCircleBorder = CAShapeLayer()
   
    @IBOutlet weak var circularProgressView: CircularProgressView!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var timerView: TimerView!
    
    private var isTimerPaused = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundCircleView()
        setupTimerView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Clip the circle in the background
        self.view.clipsToBounds = true
        
        startNap()
    }
    
    private func setupBackgroundCircleView() {
        backgroundTopColor = #colorLiteral(red: 0.1377221048, green: 0.249750644, blue: 0.2173544168, alpha: 1)
        backgroundBottomColor = #colorLiteral(red: 0.1411813796, green: 0.3443938792, blue: 0.2596455514, alpha: 1)
        
        backgroundCircleBorder.backgroundColor = UIColor.clear.cgColor
        backgroundCircleBorder.strokeColor = backgroundBottomColor.cgColor
        backgroundCircleBorder.fillColor = UIColor.clear.cgColor
        backgroundCircleBorder.lineWidth = 3.0
        view.layer.addSublayer(backgroundCircleBorder)
    }
    
    private func setupTimerView() {
        timerView.mode = .timer
        timerView.countDownTimeSeconds = Int(napTime)
        if let font = UIFont(name: "Muli-SemiBold", size: 57) {
            timerView.font = font
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
        performSegue(withIdentifier: "UnwindToSoundPicker", sender: self)
    }
    
    private func startNap() {
        guard timerView.countDownTimeSeconds > 0 else { return }
        
        timerView.start(interval: 0.1) {
            let progress = (self.napTime - self.timerView.timeLeft) / self.napTime
            self.circularProgressView.progress = progress
            
            if self.timerView.timerDone {
                self.performSegue(withIdentifier: "SoundTimerDone", sender: self)
            }
        }
    }
    
    private func pauseNap() {
        timerView.pause()
    }
    
    private func stopNap() {
        timerView.stop()
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
