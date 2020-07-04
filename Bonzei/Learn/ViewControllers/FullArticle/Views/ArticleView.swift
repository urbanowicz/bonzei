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
    
    public var htmlText: String?
    
    private var coverImageView: UIImageView = UIImageView()
    
    private var coverImageWidth = 773.0 // This value comes from the designer
    
    private var coverImageHeight = 359.0 // This value comes from the designer
    
    
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
    }
    
    private func setupCoverImageView() {
        coverImageView.image = UIImage(named: "default-article-cover")
        addSubview(coverImageView)
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        layoutCoverImage()
    }
    
    private func layoutCoverImage() {
        coverImageView.frame = CGRect(
            x: self.bounds.width - coverImageWidth.cgFloat + 10, // this setting comes from the designer
            y: 0,
            width: coverImageWidth.cgFloat,
            height: coverImageHeight.cgFloat)
        
//        coverImageView.frame = CGRect(
//            x: 0,
//            y: 0,
//            width: frame.width,
//            height: frame.width)
    }
}
