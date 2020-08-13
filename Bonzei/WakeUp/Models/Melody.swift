//
//  Melody.swift
//  Bonzei
//
//  Created by Tomasz on 03/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation

/// A static array of names of melodies.
///
/// For every melody name in the array there must be a corresponding `.mp3` file the `SoundFiles` folder.


let melodies = ["5AM Club",
                "Bellflowers Dew",
                "Crystal Vision",
                "Earth Tribe",
                "Endorphin Birds",
                "Into The Source",
                "Ocean Cliffs",
                "Peace of Mind",
                "Sea Horizon",
                "Sky Sailing",
                "Stellar Outflow"]

let melodyStartTime: [String: TimeInterval] = ["5AM Club" : 25,
                                  "Bellflowers Dew": 80,
                                  "Crystal Vision": 11,
                                  "Earth Tribe": 21,
                                  "Endorphin Birds": 7,
                                  "Into The Source": 20,
                                  "Ocean Cliffs": 0,
                                  "Peace of Mind": 25,
                                  "Sea Horizon": 27,
                                  "Sky Sailing": 0,
                                  "Stellar Outflow": 8]
