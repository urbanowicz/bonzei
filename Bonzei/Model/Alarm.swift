//
//  Alarm.swift
//  Bonzei
//
//  Created by Tomasz on 17/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation

struct Alarm {
    var hour: Int
    var minutes: Int
    var isAM: Bool
    var repeatOn: [Bool]
    var melodyName: String
}
