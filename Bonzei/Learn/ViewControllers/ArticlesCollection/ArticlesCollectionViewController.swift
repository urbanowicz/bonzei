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
        
        localArticlesDb.deleteAll()
        
        articlesProvider.syncWithBackend() {
            guard let allArticles = localArticlesDb.readAll() else { return }
            
            self.articles = allArticles
            self.articles.sort() { $0.creationDate > $1.creationDate }
            
            
            for i in 0..<self.articles.count {
                print(self.articles[i].string())
                if self.articles[i].coverImage != nil {
                    continue
                }
                self.articlesProvider.getUIImage(forURL: self.articles[i].coverImageURL) {
                    coverImage in
                    
                    self.articles[i].coverImage = coverImage
                    self.collectionView.reloadData()
                    localArticlesDb.update(article: self.articles[i])
                }
                self.articles[i].coverImage = UIImage(named: "default-article-cover")!
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
        cell.subtitleLabel.text = article.subtitle
        cell.coverImage.image = article.coverImage
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "ArticlesCollectionHeader",
                for: indexPath)

        default:
            assert(false, "Invalid element type")
        }
    }
}

// MARK: - UICollectionViewDelegate
extension ArticlesCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedArticle = articles[indexPath.row]
        
        performSegue(withIdentifier: "FullArticle", sender: self)
        
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ArticlesCollectionViewController: UICollectionViewDelegateFlowLayout  {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.width * 0.4289544)
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
    
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var coverImage: UIImageView!
}
