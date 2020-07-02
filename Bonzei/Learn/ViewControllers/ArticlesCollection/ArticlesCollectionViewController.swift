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
        articlesProvider.syncWithBackend() {
            guard let allArticles = ArticlePersistenceService.sharedInstance.readAll() else { return }
            
            self.articles = allArticles
            self.articles.sort() { $0.creationDate > $1.creationDate }
            
            for i in 0..<self.articles.count {
                let coverImage = self.articlesProvider.getUIImage(forURL: self.articles[i].coverImageURL) {
                    coverImage in
                    
                    self.articles[i].coverImage = coverImage
                    self.collectionView.reloadData()
                }
                self.articles[i].coverImage = coverImage
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
        
        return articles.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! ArticleCoverCell
        let article = articles[indexPath.row]
        cell.titleLabel.text = article.title
        cell.coverImage.image = article.coverImage
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ArticlesCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let article = articles[indexPath.row]
        
    }
}

// MARK: - ArtileCoverCell
class ArticleCoverCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var coverImage: UIImageView!
}
