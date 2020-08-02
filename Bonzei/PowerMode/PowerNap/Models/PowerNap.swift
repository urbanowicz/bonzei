//
//  PowerNap.swift
//  Bonzei
//
//  Created by Tomasz on 02/08/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import UIKit

struct PowerNap {
    var id: String
    
    // sound played during the nap
    var melodyName: String
    
    // sound played when the nap ends
    var alarmMelodyName: String
    
    // description
    var description: String
    
    // creation date
    var creationDate: Date 
}

extension PowerNap {
    init?(dictionary: [String : Any]) {
        guard let id = dictionary["id"] as? String,
            let melodyName = dictionary["melodyName"] as? String,
            let alarmMelodyName = dictionary["alarmMelodyName"] as? String,
            let description = dictionary["description"] as? String,
            let creationDate = dictionary["creationDate"] as? Date else { return nil }

        self.init(
            id: id,
            melodyName: melodyName,
            alarmMelodyName: alarmMelodyName,
            description: description,
            creationDate: creationDate)
    }
}
