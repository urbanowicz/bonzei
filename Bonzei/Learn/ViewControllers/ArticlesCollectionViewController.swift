//
//  ArticlesCollectionViewController.swift
//  Bonzei
//
//  Created by Tomasz on 29/06/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class ArticlesCollectionViewController: UIViewController {
    
    private var articlesProvider = TestArticlesProvider()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        articlesProvider.syncWithBackend()
        print()
        print("Articles:")
        articlesProvider.getAll()?.forEach() { print($0.title) }
    }

}
