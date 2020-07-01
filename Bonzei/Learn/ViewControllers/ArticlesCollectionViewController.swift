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
        articlesProvider.syncWithBackend() {
            let articles = ArticlePersistenceService.sharedInstance.readAll()

            articles?.forEach() {
                print()
                print($0.string())
                self.articlesProvider.getUIImage(forURL: $0.coverImageURL) {
                    coverImage in
                    print("Downloaded image")
                }
            }
        }
    }
}
