//
//  BonzeiTabBar.swift
//  Bonzei
//
//  Created by Tomasz on 19/07/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import UIKit

class BonzeiTabBar: UIView {
    
    var itemTapped: ((_ tab: Int) -> Void)?
    var activeItem: Int = 0
    
    private var tabBarItemViews = [UIView]()
    
    private var selectionView = CircleSelectionView()
    
    private var roundedRectBackgroundView = UIView()
    
    private var borderLayer = CAShapeLayer()
    
    private var tabBarColor = BonzeiColors.offWhite
    
    private var iconColorActive = UIColor.white
    
    private var iconColorInactive = UIColor(red: 0.42, green: 0.42, blue: 0.42, alpha: 0.5)
    
    private var borderColor = UIColor(red: 0.42, green: 0.42, blue: 0.42, alpha: 0.15)
    
    private var labelFont = UIFont(name: "Muli-SemiBold", size: 10.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(menuItems: [TabItem], frame: CGRect) {
        self.init(frame: frame)
        
        roundedRectBackgroundView.backgroundColor = tabBarColor
        
        self.backgroundColor = UIColor.clear
        
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(borderLayer)
        
        self.addSubview(roundedRectBackgroundView)
        
        selectionView.borderColor = borderColor
        insertSubview(selectionView, aboveSubview: roundedRectBackgroundView)
        
        for i in 0 ..< menuItems.count {
            let itemWidth = frame.width / CGFloat(menuItems.count)
            let leadingAnchor = itemWidth * CGFloat(i)
            
            let tabBarItem = createTabBarItem(item: menuItems[i])
            tabBarItem.tag = i
            
            addSubview(tabBarItem)
            tabBarItemViews.append(tabBarItem)
            
            tabBarItem.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                tabBarItem.heightAnchor.constraint(equalTo: self.heightAnchor),
                tabBarItem.widthAnchor.constraint(equalToConstant: itemWidth),
                tabBarItem.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leadingAnchor),
                tabBarItem.topAnchor.constraint(equalTo: self.topAnchor)
            ])
        }
        

        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        layer.shadowRadius = 50
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.activateTab(atPosition: 0)
        
    }
    
    private func createTabBarItem(item: TabItem) -> UIView {
        let tabBarItem = UIView(frame: CGRect.zero)
        let label = UILabel(frame: CGRect.zero)
        let iconView = UIImageView(frame: CGRect.zero)
        
        //label.text = item.displayTitle
        let attributes: [NSAttributedString.Key: Any] = [
            .font: labelFont!,
            .foregroundColor: iconColorInactive,
            .kern: 0.9
        ]
        label.attributedText = NSAttributedString(string: item.displayTitle, attributes: attributes)
        //label.font = labelFont
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.textColor = iconColorInactive
        
        iconView.image = item.icon!.withTintColor(iconColorInactive, renderingMode: .automatic)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        tabBarItem.addSubview(iconView)
        tabBarItem.addSubview(label)
        tabBarItem.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
    
            // Icon height
            iconView.heightAnchor.constraint(equalTo: tabBarItem.heightAnchor, multiplier: 0.317),
            
            // Icon width
            iconView.widthAnchor.constraint(equalTo: tabBarItem.heightAnchor, multiplier: 0.317),
            
            // Icon center x
            iconView.centerXAnchor.constraint(equalTo: tabBarItem.centerXAnchor),
            
            // Icon's distance from the top of the bar
            iconView.topAnchor.constraint(equalTo: tabBarItem.topAnchor, constant: 14),
            
            //itemIconView.leadingAnchor.constraint(,
            
            // Height of the title label
            label.heightAnchor.constraint(equalToConstant: 14),
            
            // Label width
            label.widthAnchor.constraint(equalTo: tabBarItem.widthAnchor),
            
            // Label's distance from the bottom of the icon
            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 8),
        
            
            ])
        tabBarItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap))) // Each item should be able to trigger and action on tap
        return tabBarItem
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Rounded rect background
        roundedRectBackgroundView.frame = bounds
        
        let cornerRadius = CGFloat(20.0)
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath.init(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        roundedRectBackgroundView.layer.mask = maskLayer
        
        // Selection View
        let activeTab = tabBarItemViews[activeItem]
        let iconView = activeTab.subviews[0]
        
        let w = 0.95 * frame.height
        let circleBounds = CGRect(
            x: iconView.frame.origin.x + iconView.frame.width/2.0 - w/2.0,
            y: iconView.frame.origin.y + iconView.frame.width/2.0 - w/2.0,
            width: w,
            height: w)
        self.selectionView.frame = activeTab.convert(circleBounds, to: self)
        
        // Border path
        borderLayer.frame = bounds
        
        let border = UIBezierPath()
        border.move(to: CGPoint(x: 0, y: cornerRadius))
        border.addArc(
            withCenter: CGPoint(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .pi,
            endAngle: 1.5 * .pi ,
            clockwise: true)
        
        border.addLine(to: CGPoint(x:bounds.width - cornerRadius, y:0))
        
        border.addArc(
            withCenter: CGPoint(x:bounds.width - cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: 1.5 * .pi,
            endAngle: 0.0,
            clockwise: true)
        
        borderLayer.path = border.cgPath
    }
    
    @objc func handleTap(_ sender: UIGestureRecognizer) {
        self.switchTab(from: self.activeItem, to: sender.view!.tag)
    }
    
    func switchTab(from: Int, to: Int) {
        self.deactivateTab(atPosition: from)
        self.activateTab(atPosition: to)
        setNeedsLayout()
    }
    
    func activateTab(atPosition tabIndex: Int) {
        
        let tabToActivate = tabBarItemViews[tabIndex]
        
        let label = tabToActivate.subviews[1]
        label.isHidden = true
        
        let iconView = tabToActivate.subviews[0] as! UIImageView
        iconView.image = iconView.image?.withTintColor(iconColorActive)
        
        DispatchQueue.main.async {
            self.itemTapped?(tabIndex)
        }

        activeItem = tabIndex
    }
    
    func deactivateTab(atPosition tabIndex: Int) {
        let tabToDeactivate = tabBarItemViews[tabIndex]
        
        let label = tabToDeactivate.subviews[1]
        label.isHidden = false
        
        let iconView = tabToDeactivate.subviews[0] as! UIImageView
        iconView.image = iconView.image?.withTintColor(iconColorInactive)
    }
}

private class CircleSelectionView: UIView {
    
    private let innerCircleToBoundsRatio = CGFloat(0.7142)
    
    private var innerCircleView = GradientView()
    
    private var borderLayer = CAShapeLayer()
    
    var innerCircleTopColor = UIColor(red: 0.01, green: 0.36, blue: 0.27, alpha: 1.00)
    
    var innerCircleBottomColor = UIColor(red: 0.14, green: 0.24, blue: 0.21, alpha: 1.00)
    
    var outerCircleColor = BonzeiColors.offWhite
    
    var borderColor = UIColor.red {
        didSet {
            borderLayer.strokeColor = borderColor.cgColor
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = outerCircleColor
        
        innerCircleView.topColor = innerCircleTopColor
        innerCircleView.bottomColor = innerCircleBottomColor
        addSubview(innerCircleView)
        
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(borderLayer)
    }
    
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = CGRect(x: 0 , y: 0, width: bounds.width, height: bounds.height)
        maskLayer.path = UIBezierPath.init(ovalIn: maskLayer.frame).cgPath
        layer.mask = maskLayer
        
        innerCircleView.frame = calculateInnerCircleFrame()
        let innerCircleMask = CAShapeLayer()
        innerCircleMask.path = UIBezierPath.init(
            ovalIn: CGRect(
                x: 0,
                y: 0,
                width: innerCircleView.frame.width,
                height: innerCircleView.frame.height)).cgPath
        innerCircleView.layer.mask = innerCircleMask
        
        // Border
        let border = UIBezierPath()
        
        let cosAngle = (bounds.width/2.0 + frame.origin.y) / (bounds.width / 2.0 )
        let angle = acos(cosAngle)
        
        border.addArc(
            withCenter: CGPoint(x: bounds.width / 2.0, y: bounds.width / 2.0),
            radius: bounds.width / 2.0,
            startAngle: 1.5 * .pi - angle,
            endAngle: 1.5 * .pi + angle,
            clockwise: true)
        
        borderLayer.path = border.cgPath
    }
    
    private func calculateInnerCircleFrame() -> CGRect {
        let innerCircleWidth = innerCircleToBoundsRatio * bounds.width
        let innerCircleHeight = innerCircleToBoundsRatio * bounds.height
        let innerCircleFrame = CGRect(
            x: bounds.width/2.0 - innerCircleWidth/2.0,
            y: bounds.height/2.0 - innerCircleHeight/2.0,
            width: innerCircleWidth,
            height: innerCircleHeight)
        
        return innerCircleFrame
    }
}
