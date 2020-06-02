//
//  WraparoundPickerView.swift
//  PickerView
//
//  Created by Tomasz on 29/05/2020.
//  Copyright © 2020 urbanowicz. All rights reserved.
//

import Foundation
import UIKit

class WraparoundPickerView: UIView, UIScrollViewDelegate {
    
    public var data: [String] = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10" ,"11", "12"] {
        didSet {
            cleanUp()
            commonInit()
        }
    }
    
    public var paddingRight = 0.0
    
    public var paddingLeft = 0.0
    
    public var numberOfVisibleRows = 3
    
    public var font: UIFont?
    
    public var textColor: UIColor = UIColor.systemGray
    
    public var textColorSelected: UIColor = UIColor.darkText
    
    // This version of the picker always wraps around.
    public let wrapsAround: Bool = true
    
    public var delegate: PickerViewDelegate?
    
    private var labels = [UILabel]()
    
    private var scrollView = UIScrollView()
    
    private var hapticFeedbackGenerator = UISelectionFeedbackGenerator()
    
    // To make the picker wrap around we store the contents three times.
    // Each copy is called a page.
    // Pages are arranged from top to bottom.
    // When the picker scrolls into the top or bottom page we immedietaly
    // move it back to the center page. This way the picker appears to be wrapping around.
    // TODO: By setting wrapAround = false, and numberOfPages = 1 the picker should
    // work without wrapping around
    private let numberOfPages = 3
    
    /// Index of the currently picked item
    private var currentItemIndex: Int = 0
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    // MARK:- Common Init
    
    private func commonInit() {
        
        for _ in 1...numberOfPages {
            setupLabels()
        }
        
        setupScrollView()
        
        for label in labels {
            scrollView.addSubview(label)
        }
        
        addSubview(scrollView)
    }

    private func setupLabels() {
        for text in data {
            let label = UILabel()
            label.text = text
            setupLabel(label)
            labels.append(label)
        }
    }
    
    private func setupLabel(_ label: UILabel) {
        label.textColor = textColor
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        if let font = font {
            label.font = font
        }
    }
    
    private func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = .normal
        
        scrollView.backgroundColor = UIColor.yellow
        
        scrollView.delegate = self
    }
    
    private func cleanUp() {
        for label in labels {
            label.removeFromSuperview()
        }
        labels = [UILabel]()
        
        scrollView.removeFromSuperview()
        scrollView = UIScrollView()
    }
    
    // MARK:- Laying out subviews and drawing
    
    override func layoutSubviews() {
        scrollView.frame = bounds
        
        scrollView.contentSize = CGSize(
            width: bounds.width,
            height: CGFloat(data.count) * CGFloat(numberOfPages) * CGFloat(rowHeight())
        )
        
        var i = 0
        for label in labels {
            label.frame = CGRect(
                x: 0.0,
                y: 0.0,
                width: bounds.width - (paddingLeft + paddingRight),
                height: rowHeight())
            
            label.frame.origin = CGPoint(x: paddingLeft, y: i * rowHeight())
            
            i += 1
        }
        
        var contentOffsetY = calculateOffsetForItem(withIndex: currentItemIndex)
        if wrapsAround {
            contentOffsetY += data.count * rowHeight()
        }
        
        scrollView.contentOffset = CGPoint(x: 0, y: contentOffsetY)
        
    }
    
    // MARK:- Acting as UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hapticFeedbackGenerator.prepare()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let i = calculateCurrentItemIndex()
        
        if i != currentItemIndex {
            hapticFeedbackGenerator.selectionChanged()
            
            updateLabel(forItemIndex: currentItemIndex, isActive: false)
            updateLabel(forItemIndex: i, isActive: true)
            
            currentItemIndex = i
            
            delegate?.valueChanged()
            
        }
        
        if wrapsAround {
            rebalanceScrollView()
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapToNearestValue()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            snapToNearestValue()
        }
    }
    
    // MARK:- Private API
    
    private func rowHeight() -> Double {
        return Double(bounds.height) / Double(numberOfVisibleRows)
    }
    
    private func index() -> Int {
        var yOffset = Double(scrollView.contentOffset.y)
        
        if yOffset < 0 {
            yOffset = 0
        }
        
            if yOffset + Double(bounds.height) > data.count * numberOfPages * rowHeight() {
            yOffset = (data.count * numberOfPages - 1) * rowHeight()
        }
        
        let i = round(yOffset / rowHeight())
        
        return Int(i)
    }
    
    private func calculateCurrentItemIndex() -> Int {
        let di = Int(numberOfVisibleRows / 2)
        return (index() + di) % data.count
    }
    
    private func calculateOffsetForItem(withIndex itemIndex: Int) -> Double {
        let di = Int(numberOfVisibleRows / 2)
        let i = ((itemIndex + data.count) - di ) % data.count
        return i * rowHeight()
    }
    
    // Returns the currently picked item
    private func currentlyPickedItem() -> String {
        let i = calculateCurrentItemIndex()
        return data[i]
    }
    
    private func updateLabel(forItemIndex itemIndex: Int, isActive: Bool) {
        var textColor = self.textColor
        
        if isActive {
            textColor = textColorSelected
        }
        
        for i in 0..<numberOfPages {
            let label = labels[itemIndex + i *  data.count]
            label.textColor = textColor
        }
    }
    
    private func rebalanceScrollView() {
        let deltaY = data.count * rowHeight()
        let offsetY = scrollView.contentOffset.y
        
        if offsetY < CGFloat(data.count * rowHeight()) {
            moveContentOffset(by: deltaY)
            return
        }
        
        if offsetY > CGFloat(2 * data.count * rowHeight()) {
            moveContentOffset(by: -deltaY)
        }
    }
    
    private func moveContentOffset(by deltaY: Double) {
        let offsetY = scrollView.contentOffset.y
        scrollView.contentOffset = CGPoint(x: 0, y: offsetY + CGFloat(deltaY))
    }
    
    private func snapToNearestValue() {
        let visibleRect = CGRect(x: 0, y: CGFloat(index() * rowHeight()), width: bounds.width, height: bounds.height)
        
        scrollView.scrollRectToVisible(visibleRect, animated: true)
    }
    
    private func scrollToItem(withIndex itemIndex: Int, animated: Bool) {
        let offset = CGFloat(calculateOffsetForItem(withIndex: itemIndex))
        let visibleRect = CGRect(x: 0, y: offset, width: bounds.width, height: bounds.height)
        
        scrollView.scrollRectToVisible(visibleRect, animated: animated)
    }
    
    //MARK:- Public API
    
    ///- Returns: the currently selected item
    public func getPickedItem() -> String {
        return currentlyPickedItem()
    }
    
    ///- Returns: index of the currently selected item
    public func getIndexOfCurrentlyPickedItem() -> Int {
        return currentItemIndex
    }
    
    ///- Returns: item at position `index`
    public func getItem(withIndex itemIndex: Int) -> String {
        return data[itemIndex]
    }
    
    /// Selects the item with the given index
    public func selectItem(withIndex itemIndex: Int) {
        guard itemIndex >= 0 && itemIndex < data.count  else { return }
        
        updateLabel(forItemIndex: currentItemIndex, isActive: false)
        updateLabel(forItemIndex: itemIndex, isActive: true)
        
        currentItemIndex = itemIndex
        setNeedsLayout()
        //scrollToItem(withIndex: itemIndex, animated: false)
    }
}
