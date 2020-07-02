//
//  ArticlesCollectionViewController.swift
//  Bonzei
//
//  Created by Tomasz on 29/06/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class ArticlesCollectionViewController: UICollectionViewController {
    
    private var articlesProvider = FirebaseArticlesProvider.sharedInstance
    
    private var articles: [Article] = []
    
    private let reuseIdentifier = "ArticleCoverCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("Calling firestore:")
        articlesProvider.syncWithBackend() {
            guard let articles = ArticlePersistenceService.sharedInstance.readAll() else { return }
            
            self.articles = articles
            
            articles.forEach() {
                print()
                print($0.string())
                self.articlesProvider.getUIImage(forURL: $0.coverImageURL) {
                    coverImage in
                    print("Downloaded image")
                }
            }
            
            self.collectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ArticlesCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        
        print("A")
        return articles.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("B")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! ArticleCoverCell
        let article = articles[indexPath.row]
        cell.titleLabel.text = article.title
        cell.backgroundColor = UIColor.systemPink
        
        return cell
    }
}
