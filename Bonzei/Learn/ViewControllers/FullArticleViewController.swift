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
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let article = self.article {
            webView.loadHTMLString(article.text, baseURL: nil)
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "UnwindToArticlesCollection", sender: self)
    }

}
