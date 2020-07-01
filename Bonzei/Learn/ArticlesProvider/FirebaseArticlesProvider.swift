//
//  FirebaseArticlesProvider.swift
//  Bonzei
//
//  Created by Tomasz on 01/07/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import os.log
import Firebase

class FirebaseArticlesProvider: ArticlesProvider {
    
    static let sharedInstance = FirebaseArticlesProvider()
    
    private let firestore = Firestore.firestore()
    
    private var log = OSLog(subsystem: "Learn", category: "FireBaseArticlesProvider")
    
    private init() {
        
    }
    
    func getAll() -> [Article]? {
        let timeStamp = Date()
        
        firestore
            .collection("articles")
            .whereField("creationDate", isGreaterThan: timeStamp)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    os_log("Failed to get documents from Firestore db: %{public}s", log: self.log, type: .error, err.localizedDescription)
                } else {
                    for document in querySnapshot!.documents {
                        guard let article = self.convertToArticle(document: document) else { continue }
                        print(article.string())
                        print()
                    }
                }
        }
        
        return nil
    }
    
    private func convertToArticle(document: DocumentSnapshot) -> Article? {
        guard var dictionary = document.data() else { return nil }
        dictionary["creationDate"] = (dictionary["creationDate"] as! Timestamp).dateValue()
        dictionary["id"] = document.documentID
        
        return Article(dictionary: dictionary)
    }
}
