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
        
        localArticlesDb.deleteAll()
        
        firestore
            .collection("articles")
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
    
    public func getUIImage(forURL url:String, completionHandler: @escaping (UIImage?) -> Void ) -> UIImage {
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
        
        return UIImage(named: "default-article-cover")!
    }
    
    // MARK:- Private API
    
    func getAll() -> [Article]? {
        let timeStamp = date(from: "2020-06-01 00:00:00")
        
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
    
    private func date(from: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df.date(from: from)!
    }
}
