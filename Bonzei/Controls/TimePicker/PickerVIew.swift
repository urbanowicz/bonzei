//
//  PickerVIew.swift
//  PickerView
//
//  Created by Tomasz on 30/05/2020.
//  Copyright © 2020 urbanowicz. All rights reserved.
//

import Foundation
import UIKit

class PickerView: UIView, UIScrollViewDelegate {
    
    public var data: [String] = ["A", "B", "C"] {
        didSet {
            cleanUp()
            commonInit()
        }
    }
    
    public var textColor: UIColor = UIColor.systemGray {
        didSet {
            updateAndDrawLabels()
        }
    }
    
    public var textColorSelected: UIColor = UIColor.darkText
    
    public var font:UIFont?
    
    // This version of the picker always shows three rows
    public let numberOfVisibleRows = 3
    
    public var delegate: PickerViewDelegate?
    
    private var labels = [UILabel]()
    
    private var scrollView = UIScrollView()
    
    private var hapticFeedbackGenerator = UISelectionFeedbackGenerator()
    
    /// Index of the currently picked item
    private var currentItemIndex: Int = 1
    
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
        setupLabels()
        
        setupScrollView()
        
        for label in labels {
            scrollView.addSubview(label)
        }
        
        addSubview(scrollView)
    }

    private func setupLabels() {
        // Add guards on both sides
        var guardLabel = UILabel()
        guardLabel.text = ""
        labels.append(guardLabel)
        
        for text in data {
            let label = UILabel()
            label.text = text
            setupLabel(label)
            labels.append(label)
        }
        
        guardLabel = UILabel()
        guardLabel.text = ""
        labels.append(guardLabel)
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
        scrollView.decelerationRate = .fast
    
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
            height: CGFloat(data.count + 2) * CGFloat(rowHeight()) // +2 because we added guards on both side of the content
        )
        
        var i = 0
        for label in labels {
            label.frame = CGRect(x: 0, y: 0, width: bounds.width, height: CGFloat(rowHeight()))
            label.frame.origin = CGPoint(x: 0, y: i * rowHeight())
            i += 1
        }
        
        let offsetY = calculateOffsetForItem(withIndex: currentItemIndex)
        scrollView.contentOffset = CGPoint(x: 0, y: offsetY)
        
    }
    
    private func updateAndDrawLabels() {
        for label in labels {
            setupLabel(label)
        }
        setNeedsDisplay()
    }
    
    // MARK:- Acting as UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hapticFeedbackGenerator.prepare()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let i = index()
        if i != currentItemIndex {
            hapticFeedbackGenerator.selectionChanged()
            
            updateLabel(forItemIndex: currentItemIndex, isActive: false)
            updateLabel(forItemIndex: i, isActive: true)
            
            currentItemIndex = i
            
            delegate?.valueChanged()
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
        var i = Int(round(scrollView.contentOffset.y / CGFloat(rowHeight())))
        
        if i < 0 {
            i = 0
        }
        
        if i > data.count - 1 {
            i = data.count - 1
        }
        
        return i
    }
    
    private func calculateOffsetForItem(withIndex itemIndex: Int) -> Double {
        return itemIndex * rowHeight()
    }
    
    private func updateLabel(forItemIndex itemIndex: Int, isActive: Bool) {
        var textColor = self.textColor
        
        if isActive {
            textColor = textColorSelected
        }
        
        let label = labels[itemIndex + 1] // +1 because we have an empty guard label at position 0!
        label.textColor = textColor
        
    }
    
    // Returns the currently picked item
    private func currentlyPickedItem() -> String {
        let i = index()
        return data[i]
    }
    
    private func snapToNearestValue() {
        let visibleRect = CGRect(x: 0, y: CGFloat(index() * rowHeight()), width: bounds.width, height: bounds.height)
        
        scrollView.scrollRectToVisible(visibleRect, animated: true)
    }
    
    //MARK:- Public API
    
    ///
    ///- Returns: the currently selected item
    public func getPickedItem() -> String {
        return currentlyPickedItem()
    }
    
    ///- Returns: the index of the currently picked item
    public func getIndexOfCurrentlyPickedItem() -> Int {
        return index()
    }
    
    ///- Returns: item at position `index`
    public func getItem(withIndex itemIndex: Int) -> String {
        return data[itemIndex]
    }
    
    /// Select the item given by `itemIndex`
    public func selectItem(withIndex itemIndex: Int) {
        guard itemIndex >= 0 && itemIndex < data.count  else { return }
        
        updateLabel(forItemIndex: currentItemIndex, isActive: false)
        updateLabel(forItemIndex: itemIndex, isActive: true)
        
        currentItemIndex = itemIndex
        setNeedsLayout()
        //scrollToItem(withIndex: itemIndex, animated: false)
    }
}
