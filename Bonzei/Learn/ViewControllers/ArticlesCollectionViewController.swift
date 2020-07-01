//
//  ArticlesCollectionViewController.swift
//  Bonzei
//
//  Created by Tomasz on 29/06/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class ArticlesCollectionViewController: UIViewController {
    
    private var articlesProvider = FirebaseArticlesProvider.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("Calling firestore:")
        articlesProvider.getAll()
//        articlesProvider.syncWithBackend()
//        print()
//        print("ArticlesProvider:")
//        articlesProvider.getAll()?.forEach() { print($0.title) }
//        print()
//        print("ArticlesPersistenceService:")
//        ArticlePersistenceService.sharedInstance.readAll()?.forEach() { print($0.title) }
    }

}
