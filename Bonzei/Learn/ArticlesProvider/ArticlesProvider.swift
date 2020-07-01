//
//  ArticlesProvider.swift
//  Bonzei
//
//  Created by Tomasz on 30/06/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation

/// `ArticlesProvider` has one responsibility and that is to synchronize the local articles database with the remote database.
/// It is not known at the time of wrting what service will be used as a backened. This is why several articles providers might be implemented.
/// Each implementation will fetch articles from a different backend. Client code should not care what backend is used. It will always call:
///
///     let articlesProvider: ArticlesProvider = getArticlesProvider()
///     articlesProvider.syncWithBackend() { // completion handler code goes here }
///
protocol ArticlesProvider {
    
    /// Synchronize the local articles database with the remote database
    func syncWithBackend(completionHandler: @escaping ()->Void)
}
