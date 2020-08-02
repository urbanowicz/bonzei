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
    
    var title: String
    
    var description: String
    
    var creationDate: Date
    
    var coverImageURL: String
    
    var coverImage: UIImage?
}

extension PowerMode {
    init?(dictionary: [String : Any]) {
        guard let id = dictionary["id"] as? String,
            let title = dictionary["title"] as? String,
            let description = dictionary["description"] as? String,
            let creationDate = dictionary["creationDate"] as? Date,
            let coverImageURL = dictionary["coverImageURL"] as? String else { return nil }

        self.init(
            id: id,
            title: title,
            description: description,
            creationDate: creationDate,
            coverImageURL: coverImageURL)
    }
}
