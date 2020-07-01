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

/// Provides CRUD operations for articles stored in local db
class ArticlePersistenceService {
    
    static let sharedInstance = ArticlePersistenceService()
    
    private let articleEntityName = "ManagedArticle"
    
    private var viewContext: NSManagedObjectContext!
    
    private var log = OSLog(subsystem: "Learn", category: "ArticlePersistenceService")
    
    
    private init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        viewContext = appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - Public API
    
    /// Stores an article in the local db
    /// - Parameter article: an article to be saved in the local db
    public func create(article: Article) {
        let managedArticle = ManagedArticle(context: viewContext)
        managedArticle.id = article.id
        managedArticle.title = article.title
        managedArticle.subtitle = article.subtitle
        managedArticle.creationDate = article.creationDate
        managedArticle.text = article.text
        managedArticle.coverImageURL = article.coverImageURL
        
        commit()
    }
    
    /// Reads an article from the local db
    /// - Parameter articleId: unique id of the article to be read from the local db
    /// - Returns: Article given by `articleId` or `nil` if no such article exists
    public func read(articleId: String) -> Article? {
        guard let managedArticle = fetchManagedArticle(articleId: articleId) else { return nil }
        
        return convertToArticle(managedArticle: managedArticle)
    }
    
    /// Reads all articles from the local db
    /// - Returns: all articles stored in the local db or `nil` if the local db is empty.
    public func readAll() -> [Article]? {
        guard let managedArticles = fetchAllManagedArticles() else { return nil }
        guard managedArticles.count > 0 else { return nil }
        
        let articles: [Article] = managedArticles.map() { convertToArticle(managedArticle: $0) }
        
        return articles
    }
    
    /// Updates an article stored in the local db.
    /// The way this operation works is that an article with `article.id` is first fetched from the db and then its values are updated to
    /// values present in the `article`  that was passed as a parameter.
    /// If the local db doesn't contain an article with id = `article.id` this method does nothing. (ie. no error is raised)
    /// - Parameter article: an article to be updated.
    public func update(article: Article) {
        guard let managedArticle = fetchManagedArticle(articleId: article.id) else { return }
        
        managedArticle.title = article.title
        managedArticle.subtitle = article.subtitle
        managedArticle.text = article.text
        managedArticle.creationDate = article.creationDate
        managedArticle.coverImageURL = article.coverImageURL
        
        commit()
    }
    
    /// Removes an article from the local db
    /// - Parameter articleId: id of the article that you wish to dlelete from the local db.
    public func delete(articleId: String) {
        guard let managedArticle = fetchManagedArticle(articleId: articleId) else { return }
        
        viewContext.delete(managedArticle)
        commit()
    }
    
    public func deleteAll() {
        let managedArticles = fetchAllManagedArticles()
        managedArticles?.forEach() { viewContext.delete($0) }
        
        commit()
    }
    
    // MARK: - Private API
    
    private func commit() {
        do {
            try viewContext.save()
        } catch let error as NSError {
            os_log("Failed to commit changes: %{public}s", log: log, type: .error, error.localizedDescription)
        }
    }
    
    private func fetchManagedArticle(articleId id: String) -> ManagedArticle? {
        let fetchRequest = NSFetchRequest<ManagedArticle>(entityName: articleEntityName)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        var managedArticles: [ManagedArticle]?
        
        do {
            managedArticles = try viewContext.fetch(fetchRequest)
        } catch let error as NSError {
            os_log("Failed to fetch an article from local db: %{public}s", log: log, type: .error, error.localizedDescription)
        }
        
        return managedArticles?.first
    }
    
    private func fetchAllManagedArticles() -> [ManagedArticle]? {
        let fetchRequest = NSFetchRequest<ManagedArticle>(entityName: articleEntityName)
        
        var managedArticles: [ManagedArticle]?
        
        do {
            managedArticles = try viewContext.fetch(fetchRequest)
        } catch let error as NSError {
            os_log("Failed to fetch all articles from local db: %{public}s", log: log, type: .error, error.localizedDescription)
        }
        
        return managedArticles
    }
    
    private func convertToArticle(managedArticle: ManagedArticle) -> Article {
        let article = Article(title: managedArticle.title!,
                              subtitle: managedArticle.subtitle!,
                              text: managedArticle.text!,
                              creationDate: managedArticle.creationDate!,
                              id: managedArticle.id!,
                              coverImageURL: managedArticle.coverImageURL!)
        return article
    }

}
