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
    
    @IBInspectable var trackWidth: Double = 3.0
    
    public var progress: Double = 0.7 {
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        trackLayer.frame = self.bounds
    }
    
    private func updateProgress() {
        
    }
}
