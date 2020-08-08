//
//  CircularProgressView.swift
//  Bonzei
//
//  Created by Tomasz on 08/08/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CircularProgressView: UIView {
    
    @IBInspectable var progressColor: UIColor = UIColor.white {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    @IBInspectable var trackColor: UIColor = UIColor.blue {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    @IBInspectable var trackWidth: Double = 3.0 {
        didSet {
            trackLayer.lineWidth = CGFloat(trackWidth)
            progressLayer.lineWidth = CGFloat(trackWidth)
        }
    }
    
    @IBInspectable var isCountDown: Bool = false {
        didSet {
            updateProgress()
        }
    }
    
    public var progress: Double = 0.0 {
        didSet {
            updateProgress()
        }
    }
    
    private let progressLayer = CAShapeLayer()
    
    private let trackLayer = CAShapeLayer()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        // track layer
        trackLayer.backgroundColor = UIColor.clear.cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = CGFloat(trackWidth)
        
        layer.addSublayer(trackLayer)
        
        progressLayer.backgroundColor = UIColor.clear.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = CGFloat(trackWidth)
        progressLayer.transform = CATransform3DMakeRotation(-(.pi / 2.0), 0, 0, 1)
        
        layer.addSublayer(progressLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        trackLayer.frame = self.bounds
        trackLayer.path = UIBezierPath.init(ovalIn: trackLayer.bounds).cgPath
        
        progressLayer.frame = self.bounds
        progressLayer.path = UIBezierPath.init(ovalIn: progressLayer.bounds).cgPath
        
        updateProgress()
    }
    
    private func updateProgress() {
        if isCountDown {
           progressLayer.strokeStart = CGFloat(progress)
        } else {
            progressLayer.strokeEnd = CGFloat(progress)
        }
    }
}
