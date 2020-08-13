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
    
    // eg. "Theta"
    var waveType: String
    
    // description
    var description: String
    
    // creation date
    var creationDate: Date
    
    // cover color as a Hex string
    var coverColor: String
    
    // Background gradient top color as Hex string
    var gradientTopColor: String
    
    // Background gradient bottom color as Hex string
    var gradientBottomColor: String
}

extension PowerNap {
    init?(dictionary: [String : Any]) {
        guard let id = dictionary["id"] as? String,
            let melodyName = dictionary["melodyName"] as? String,
            let alarmMelodyName = dictionary["alarmMelodyName"] as? String,
            let waveType = dictionary["waveType"] as? String,
            let description = dictionary["description"] as? String,
            let creationDate = dictionary["creationDate"] as? Date,
            let coverColor = dictionary["coverColor"] as? String,
            let gradientTopColor = dictionary["gradientTopColor"] as? String,
            let gradientBottomColor = dictionary["gradientBottomColor"] as? String else { return nil }

        self.init(
            id: id,
            melodyName: melodyName,
            alarmMelodyName: alarmMelodyName,
            waveType: waveType,
            description: description,
            creationDate: creationDate,
            coverColor: coverColor,
            gradientTopColor: gradientTopColor,
            gradientBottomColor: gradientBottomColor)
    }
}

let pn1 = PowerNap(id: "ZeroGravity",
                   melodyName: "Zero Gravity",
                   alarmMelodyName: "ZeroGravityAlarm",
                   waveType: "THETA / DELTA",
                   description: "Lose gravity and take a flight through the boundless blue sky.",
                   creationDate: Date(),
                   coverColor: "#144C3D",
                   gradientTopColor: "#234037",
                   gradientBottomColor: "#245842")

let pn2 = PowerNap(id: "RainForest",
                   melodyName: "Rainforest",
                   alarmMelodyName: "RainForestAlarm",
                   waveType: "COMING SOON",
                   description: "Float in the humid rainforest soundscape.",
                   creationDate: Date(),
                   coverColor: "#6F463D",
                   gradientTopColor: "#6F463D",
                   gradientBottomColor: "#573931")

let pn3 = PowerNap(id: "Underwater",
                   melodyName: "Underwater",
                   alarmMelodyName: "UnderwaterAlarm",
                   waveType: "COMING SOON",
                   description: "Dive deep with lower frequencies of binaural waves.",
                   creationDate: Date(),
                   coverColor: "#273051",
                   gradientTopColor: "#303856",
                   gradientBottomColor: "#273051")

let sounds = [pn1, pn2, pn3]
