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
        }
    }
    
    public var delegate: ArticleViewDelegate?
    
    private var coverImageView: UIImageView = UIImageView()
    
    private var darkOverlayView = UIView()
    
    private var webView: WKWebView!
    
    private var webViewCurrentContentSize = CGFloat(0.0)
    
    private var spacer = UIView()
    
    private var overlapBy = CGFloat(50.0)
    
    private var containerScrollView = UIScrollView()
    
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
        self.backgroundColor = superview?.backgroundColor
        
        coverImageView.backgroundColor = backgroundColor
        coverImageView.isUserInteractionEnabled = false
        addSubview(coverImageView)
        
        darkOverlayView.backgroundColor = UIColor.black
        darkOverlayView.alpha = 0.0
        addSubview(darkOverlayView)
        
        spacer.backgroundColor = UIColor.clear
        containerScrollView.addSubview(spacer)
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.backgroundColor = backgroundColor
        containerScrollView.addSubview(webView)
        
        containerScrollView.isPagingEnabled = false
        containerScrollView.bounces = false
        containerScrollView.contentInsetAdjustmentBehavior = .never
        containerScrollView.showsVerticalScrollIndicator = false 
        containerScrollView.delegate = self
        containerScrollView.backgroundColor = UIColor.clear
        addSubview(containerScrollView)
    }
    
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let k = bounds.width - overlapBy
        let h = bounds.height
        let w = bounds.width
        
        coverImageView.frame = CGRect( x: 0, y: 0, width: w, height: w)
        darkOverlayView.frame = coverImageView.frame
        
        containerScrollView.frame = CGRect(x: 0, y: 0, width: w, height: h)
        containerScrollView.contentSize = CGSize(width: w, height: h + k)
        
        spacer.frame = CGRect(x: 0, y: 0, width: w, height: k)
        
        webView.frame = CGRect(x: 0, y: k, width: w, height: h)
        addRoundedCornersToWebView()
    }
    
    private func addRoundedCornersToWebView() {
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: webView.bounds, cornerRadius: 15).cgPath
        webView.layer.mask = maskLayer
    }
}

// MARK: - UIScrollViewDelegate
extension ArticleView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let k = bounds.width - overlapBy
        let h = max(bounds.height, webViewCurrentContentSize)
        let w = bounds.width
        
        if webView.scrollView.contentSize.height != webViewCurrentContentSize {
            webViewCurrentContentSize = webView.scrollView.contentSize.height
            
            webView.frame = CGRect(x: 0, y: k, width: w, height: h)
            addRoundedCornersToWebView()
            containerScrollView.contentSize = CGSize(width: w, height: h + k)
        }
        
        let dy = min(scrollView.contentOffset.y, k)
        self.darkOverlayView.alpha = dy/k
        
        delegate?.scrollViewDidScroll(scrollView)
    }
}

protocol ArticleViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}
