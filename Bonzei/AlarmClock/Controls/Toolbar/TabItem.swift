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
    
    
    var viewController: UIViewController {
        switch self {
        case .wakeUp:
            return WakeUpViewController()
        case .learn:
            return ArticlesCollectionViewController()
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .wakeUp:
            return UIImage(named: "ic-wakeup-green")!
        case .learn:
            return UIImage(named: "ic-learn-green")!
        }
    }
    
    var displayTitle: String {
        return self.rawValue.capitalized(with: nil)
    }
}
