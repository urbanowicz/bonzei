//
//  ArticlesCollectionHeaderView.swift
//  Bonzei
//
//  Created by Tomasz on 03/07/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class ArticlesCollectionHeaderView: UICollectionReusableView {
    
    @IBOutlet var contentView: UIView!
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ArticlesCollectionHeaderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    override func layoutSubviews() {
        contentView.frame = self.bounds
    }
}
