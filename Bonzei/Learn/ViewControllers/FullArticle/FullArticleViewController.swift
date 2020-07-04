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
    
    @IBOutlet weak var articleView: ArticleView!
    
    //   @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        articleView.coverImage = article?.coverImage
        articleView.htmlText = article?.text
//        if let article = self.article {
//            webView.loadHTMLString(article.text, baseURL: nil)
//        }
        
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "UnwindToArticlesCollection", sender: self)
    }

}
