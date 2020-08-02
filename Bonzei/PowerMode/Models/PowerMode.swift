//
//  PowerMode.swift
//  Bonzei
//
//  Created by Tomasz on 02/08/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import UIKit

struct PowerMode {
    var id: String
    
    var name: String
    
    var description: String
    
    var coverImage: UIImage?
}

let powerModes: [PowerMode] = [
    PowerMode(id: "PowerNap",
              name: "Power nap with binaurial beats.",
              description: "Binaural beats are an auditory biohack designed to facilitate brainwave entrainment.",
              coverImage: UIImage(named: "power-nap-cover"))
]
