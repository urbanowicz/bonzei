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
    
    @IBOutlet weak var backgroundCircleView: GradientView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    private let backgroundCircleBorder = CAShapeLayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackgroundCircleView()
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
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
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
