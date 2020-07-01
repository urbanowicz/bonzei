//
//  TestArticleProvider.swift
//  Bonzei
//
//  Created by Tomasz on 30/06/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation

class TestArticlesProvider: ArticlesProvider {
    
    private var backendArticles: [Article] = [Article]()
    
    init() {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        backendArticles = [
            Article(
                title: "Cold Bath",
                subtitle: "What is it and why you really need one",
                text: "This article explains what a cold bath is and why you really need one.",
                creationDate: df.date(from: "2020-06-30 21:28:00")!,
                id: "1")
        ]
    }
    
    public func getAll() -> [Article]? {
        return ArticlePersistenceService.sharedInstance.readAll()
    }
    
    public func syncWithBackend(completionHandler: @escaping ()->Void) {
        var localArticles = ArticlePersistenceService.sharedInstance.readAll()
        
        var newArticles: [Article]?
        
        if localArticles == nil {
            newArticles = fetchAllBackendArticles()
        } else {
            localArticles!.sort() { $0.creationDate > $1.creationDate }
            newArticles = fetchBackendArticles(newerThan: localArticles!.last!.creationDate)
        }
        
        newArticles?.forEach() { ArticlePersistenceService.sharedInstance.create(article: $0) }
    }
    
    private func fetchAllBackendArticles() -> [Article] {
        return backendArticles
    }
    
    private func fetchBackendArticles(newerThan creationDate: Date) -> [Article] {
        return backendArticles.filter() {$0.creationDate > creationDate }
    }
}
