//
//  Helpers.swift
//  Bonzei
//
//  Created by Tomasz on 21/07/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation

/// - Returns: `true` if 24 hour syststem should be used. `false` if AM/PM system should be used
func shouldUse24HourMode() -> Bool {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.current
    dateFormatter.timeStyle = .short

    if dateFormatter.dateFormat!.prefix(2) == "HH" {
        return true
    } else {
        return false
    }
}
