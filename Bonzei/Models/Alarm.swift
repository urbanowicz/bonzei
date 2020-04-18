//
//  Alarm.swift
//  Bonzei
//
//  Created by Tomasz on 17/04/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation

struct Alarm {
    var date: Date
    var repeatOn:[Bool] = [true, true, true, true, true, true, true]
    var melodyName: String
}
