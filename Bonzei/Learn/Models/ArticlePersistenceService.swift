//
//  ArticlePersistenceService.swift
//  Bonzei
//
//  Created by Tomasz on 29/06/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import os.log

class ArticlePersistenceService {
    
    static let sharedInstance = ArticlePersistenceService()
    
    private var viewContext: NSManagedObjectContext!
    
    private var log = OSLog(subsystem: "Learn", category: "ArticlePersistenceService")
    
    private init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        viewContext = appDelegate.persistentContainer.viewContext
    }
    
    // MARK: -Public API
    
    /// Stores a given article in the device's database
    public func create(article: Article) {
        let managedArticle = ManagedArticle(context: viewContext)
        managedArticle.id = article.id
        managedArticle.title = article.title
        managedArticle.subtitle = article.subtitle
        managedArticle.creationDate = article.creationDate
        managedArticle.text = article.text
        
        commit()
    }
    
    public func read(articleWithId id: String) -> Article? {
        return nil
    }
    
    public func readAllArticles() -> [Article]? {
        return nil
    }
    
    public func update(article: Article) {
        
    }
    
    public func delete(articleWithId id: String) {
        
    }
    
    // MARK: -Private API
    
    private func commit() {
        do {
            try viewContext.save()
        } catch let error as NSError {
            os_log("Failed to commit changes: %{public}s", log: log, type: .error, error.localizedDescription)
        }
    }
}
