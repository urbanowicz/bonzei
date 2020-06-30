//
//  TestArticleProvider.swift
//  Bonzei
//
//  Created by Tomasz on 30/06/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation

class TestArticlesProvider: ArticlesProvider {
    
    private let backendArticles: [Article] = [
        Article(
            title: "Cold Bath",
            subtitle: "What is it and why you really need one",
            text: "This article explains what a cold bath is and why you really need one.",
            creationDate: Date(),
            id: 1)]
    
    public func getAll() -> [Article]? {
        return ArticlePersistenceService.sharedInstance.readAll()
    }
    
    public func syncWithBackend() {
        var localArticles = ArticlePersistenceService.sharedInstance.readAll()
        
        var newArticles: [Article]?
        
        if localArticles == nil {
            newArticles = fetchAllBackendArticles()
        } else {
            localArticles!.sort() { $0.id > $1.id }
            newArticles = fetchBackendArticles(newerThan: localArticles!.last!.id)
        }
        
        newArticles?.forEach() { ArticlePersistenceService.sharedInstance.create(article: $0) }
    }
    
    private func fetchAllBackendArticles() -> [Article] {
        return backendArticles
    }
    
    private func fetchBackendArticles(newerThan articleId: Int64) -> [Article] {
        return backendArticles.filter() {$0.id > articleId }
    }
}
