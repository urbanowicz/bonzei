//
//  TestArticleProvider.swift
//  Bonzei
//
//  Created by Tomasz on 30/06/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation

class TestArticlesProvider: ArticlesProvider {
    
    private let backendArticles = [
        Article(
            title: "Cold Bath",
            subtitle: "You really need one",
            text: "This article explains what is a cold bath and why you really need one.",
            creationDate: Date(),
            id: 1)]
    
    public func getAll() -> [Article]? {
        return ArticlePersistenceService.sharedInstance.readAll()
    }
    
    public func syncWithBackend() {
        
    }
    
}
