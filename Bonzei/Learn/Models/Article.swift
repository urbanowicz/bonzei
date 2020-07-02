//
//  Article.swift
//  Bonzei
//
//  Created by Tomasz on 29/06/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import Firebase

struct Article {
    
    /// Title of the article
    var title: String
    
    /// Subtitle of the article
    var subtitle: String
    
    /// Content of the article in the HTML format
    var text: String
        
    /// Date when the article was added to the backend database
    var creationDate: Date
    
    /// Unique ID of the article
    var id: String
    
    /// Cover image  URL
    var coverImageURL: String
    
    var coverImage: UIImage?
    
    /// - Returns: a dictionary representation of this article
    var dictionary: [String: Any] {
      return [
        "id": id,
        "creationDate": creationDate,
        "title": title,
        "subtitle": subtitle,
        "text": text,
        "coverImageURL": coverImageURL
      ]
    }
}

extension Article {
    
    init?(dictionary: [String : Any]) {
        guard let title = dictionary["title"] as? String,
            let subtitle = dictionary["subtitle"] as? String,
            let text = dictionary["text"] as? String,
            let creationDate = dictionary["creationDate"] as? Date,
            let id = dictionary["id"] as? String,
            let coverImageURL = dictionary["coverImageURL"] as? String else { return nil }

        self.init(title: title, subtitle: subtitle, text: text, creationDate: creationDate, id: id, coverImageURL: coverImageURL)
    }
    
    func string() -> String {
        return """
        id: \(id)
        creationDate: \(creationDate)
        coverImageURL: \(coverImageURL)
        title: \(title)
        subtitle: \(subtitle)
        text: \(text)
        """
    }
}
