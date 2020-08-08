//
//  SoundTimerDoneViewController.swift
//  Bonzei
//
//  Created by Tomasz on 08/08/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class SoundTimerDoneViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        backgroundTopColor = #colorLiteral(red: 0.1377221048, green: 0.249750644, blue: 0.2173544168, alpha: 1)
        backgroundBottomColor = #colorLiteral(red: 0.1411813796, green: 0.3443938792, blue: 0.2596455514, alpha: 1)
    }

}
