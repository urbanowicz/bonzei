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
    
    /// Firebase firestore
    private let firestore = Firestore.firestore()
    
    /// Firebase cloud storage
    private let storage = Storage.storage()
    
    private var log = OSLog(subsystem: "Learn", category: "FireBaseArticlesProvider")
    
    private init() {
        
    }
    
    // MARK:- Public API
    
    public func syncWithBackend(completionHandler: @escaping ()->Void) {
        
        // This is a naive implementation that always fetches all documents
        let localArticlesDb = ArticlePersistenceService.sharedInstance
        
        var timestamp = date(from: "2020-01-01 00:00:00") // all articles are newer than this
        
        if var localArticles = localArticlesDb.readAll() {
            localArticles.sort() { $0.creationDate > $1.creationDate }
            timestamp = localArticles.first!.creationDate
        }
        
        firestore
            .collection("articles")
            .whereField("creationDate", isGreaterThan: timestamp)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    os_log("Failed to get documents from Firestore db: %{public}s", log: self.log, type: .error, err.localizedDescription)
                } else {
                    for document in querySnapshot!.documents {
                        guard let article = self.convertToArticle(document: document) else { continue }
                        localArticlesDb.create(article: article)
                    }
                }
                DispatchQueue.main.async {
                    completionHandler()
                }
        }
    }
    
    public func getUIImage(forURL url:String, completionHandler: @escaping (UIImage?) -> Void ) {
        let gsReference = self.storage.reference(forURL: url)
        
        gsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                os_log("Failed to get data from firebase storage: %{public}s", log: self.log, type: .error, error.localizedDescription)
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(UIImage(data: data!))
                }
            }
        }
    }
    
    // MARK:- Private API
    
    private func convertToArticle(document: DocumentSnapshot) -> Article? {
        guard var dictionary = document.data() else { return nil }
        dictionary["creationDate"] = (dictionary["creationDate"] as! Timestamp).dateValue()
        dictionary["id"] = document.documentID
        
        return Article(dictionary: dictionary)
    }
    
    private func date(from: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df.date(from: from)!
    }
}
