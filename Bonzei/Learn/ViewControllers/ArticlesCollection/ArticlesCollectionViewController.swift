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
    
    private var selectedArticle: Article?
    
    private let reuseIdentifier = "ArticleCoverCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let localArticlesDb = ArticlePersistenceService.sharedInstance
        
        articlesProvider.syncWithBackend() {
            guard let allArticles = localArticlesDb.readAll() else { return }
            
            self.articles = allArticles
            self.articles.sort() { $0.creationDate > $1.creationDate }
            
            
            for i in 0..<self.articles.count {
                if self.articles[i].coverImage != nil {
                    continue
                }
                let coverImage = self.articlesProvider.getUIImage(forURL: self.articles[i].coverImageURL) {
                    coverImage in
                    
                    self.articles[i].coverImage = coverImage
                    self.collectionView.reloadData()
                    localArticlesDb.update(article: self.articles[i])
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
        selectedArticle = articles[indexPath.row]
        
        performSegue(withIdentifier: "FullArticle", sender: self)
        
    }
}

// MARK: - Navigation
extension ArticlesCollectionViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "FullArticle" {
            let fullArticleViewController = segue.destination as! FullArticleViewController
            
            fullArticleViewController.article = selectedArticle
        }
    }
    
    @IBAction func unwindToArticlesCollection(_ unwindSegue: UIStoryboardSegue) {
        //nothing to do here.
    }
}

// MARK: - ArtileCoverCell
class ArticleCoverCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var coverImage: UIImageView!
}
