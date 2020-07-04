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
    
    //   @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let article = self.article {
//            webView.loadHTMLString(article.text, baseURL: nil)
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard var article = article else { return }
        
        articleView.htmlText = article.text
        print("THIS: \(articleView.htmlText)")
        
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
