//
//  ArticleView.swift
//  Bonzei
//
//  Created by Tomasz on 04/07/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import UIKit
import WebKit

@IBDesignable
class ArticleView: UIView {
    
    public var coverImage: UIImage? {
        didSet {
            coverImageView.backgroundColor = self.backgroundColor
            coverImageView.image = coverImage
        }
    }
    
    public var htmlText: String? {
        didSet {
            guard let htmlText = self.htmlText else { return }
            webView.loadHTMLString(htmlText, baseURL: nil)
            webView.scrollView.delegate = self
        }
    }
    
    private var coverImageView: UIImageView = UIImageView()
    
    private var webView: WKWebView!
    
    private var scrollView = UIScrollView()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    // MARK: - Initialization
    private func commonInit() {
        setupCoverImageView()
        
        setupWebView()
    }
    
    private func setupCoverImageView() {
        addSubview(coverImageView)
    }
    
    private func setupWebView() {
        webView = WKWebView()
        addSubview(webView)
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        layoutCoverImage()
        layoutWebView()
    }
    
    private func layoutCoverImage() {
        
        coverImageView.frame = CGRect(
            x: 0,
            y: 0,
            width: frame.width,
            height: frame.width)
    }
    
    private func layoutWebView() {
        webView.frame = CGRect(
            x: 0,
            y: frame.width - 50,
            width: frame.width,
            height: frame.height
        )
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: webView.bounds, cornerRadius: 15).cgPath
        webView.layer.mask = maskLayer
    }
}

// MARK: - UIScrollViewDelegate
extension ArticleView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
}
