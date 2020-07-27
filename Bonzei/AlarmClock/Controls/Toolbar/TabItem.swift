//
//  TabItem.swift
//  Bonzei
//
//  Created by Tomasz on 19/07/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import UIKit

enum TabItem: String, CaseIterable {
    case wakeUp = "Wake Up"
    case learn = "Learn"
    case powerMode = "Powermode"
    
    var viewController: UIViewController {
        switch self {
        case .wakeUp:
            return UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "WakeUpViewController")
            
        case .learn:
            return UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "ArticlesCollectionViewController")
            
        case .powerMode:
            return UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "PowerModeViewController")
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .wakeUp:
            return UIImage(named: "clock-green")!
        case .learn:
            return UIImage(named: "ic-learn-green")!
        case .powerMode:
            return UIImage(named: "ic-super")!
        }
        
    }
    
    var displayTitle: String {
        return self.rawValue.capitalized(with: nil)
    }
}
