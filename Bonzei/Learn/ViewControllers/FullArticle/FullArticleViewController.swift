//
//  FullArticleViewController.swift
//  Bonzei
//
//  Created by Tomasz on 02/07/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit
import WebKit

class FullArticleViewController: UIViewController {
    
    var article: Article?
    
    private var articlesProvider = FirebaseArticlesProvider.sharedInstance
    
    @IBOutlet weak var articleView: ArticleView!
    
    @IBOutlet weak var backButton: UIButton!
    
    private var scrollContentOffsetY = CGFloat(0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        articleView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard var article = article else { return }
        
        articleView.htmlText = article.text
        
        if let largeCoverImage = article.largeCoverImage {
            articleView.coverImage = largeCoverImage
        } else {
            articleView.coverImage = UIImage(named: "default-large-article-cover")
            articlesProvider.getUIImage(forURL: article.largeCoverImageURL) {
                largeCoverImage in
                self.articleView.coverImage = largeCoverImage
                article.largeCoverImage = largeCoverImage
                ArticlePersistenceService.sharedInstance.update(article: article)
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "UnwindToArticlesCollection", sender: self)
    }

}

// MARK: - ArticleViewDelegate

extension FullArticleViewController: ArticleViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let deltaY = scrollView.contentOffset.y - scrollContentOffsetY
        if deltaY < 0 && backButton.isHidden {
            backButton.alpha = 0.0
            backButton.isHidden = false
            UIView.animate(withDuration: 0.2) {
                self.backButton.alpha = 1.0
            }
        } else if deltaY > 0 && !backButton.isHidden {
            UIView.animate(
                withDuration: 0.2,
                animations: { self.backButton.alpha = 0.0 },
                completion: {success in self.backButton.isHidden = true }
            )
        }
        scrollContentOffsetY = scrollView.contentOffset.y
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // do nothing
    }
    
    
}
