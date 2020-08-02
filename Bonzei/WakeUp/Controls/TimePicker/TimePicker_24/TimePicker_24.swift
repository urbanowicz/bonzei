//
//  TimePicker_24.swift
//  Bonzei
//
//  Created by Tomasz on 24/06/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class TimePicker_24: UIView, TimePicker, PickerViewDelegate {
    
    public var delegate: TimePickerDelegate?
    
    private var date: Date = Date()
    
    private var fontName: String = "Muli-Regular"
    
    private var textColor: UIColor = UIColor(red: 0.42, green: 0.42, blue: 0.42, alpha: 0.5)
    
    private var textColorSelected: UIColor = BonzeiColors.jungleGreen
    
    private var font: UIFont = UIFont.systemFont(ofSize: 24)
    
    private let fontSize = 24
    
    private let labelPadding = 16.0
    
    private var scrollPadding = 30.0
    
    private var xOffset = 0.0
    
    private let numberOfVisibleRows = 3
    
    private var hourPicker: WraparoundPickerView!
    
    private var minutePicker: WraparoundPickerView!
    
    private var colonLabel: UILabel!
    
    private var selectionRectangleColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.00)
    
    private var selectionRectangleCornerRadiusRatio = 0.15
    
    private var selectionRectangleBorderWidth = 1.0
    
    private var selectionRectangle: UIView!

    private var topBorder: GradientView!
    
    private var bottomBorder: GradientView!
    
    private var borderGradientColor_1: UIColor = UIColor.white.withAlphaComponent(0.8)
    
    private var borderGradientColor_2: UIColor = UIColor(red: 1.00, green: 0.99, blue: 0.99, alpha: 0.2)
    
    private var borderSizeRatio = 0.23
    
    //MARK:- Common Init
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    private func commonInit() {
        //TODO. backgroundcolor should be customizable and should propagate to Pickers
        backgroundColor = UIColor.clear
        
        loadCustomFont()
        
        setupHourPicker()
        
        setupColonLabel()
        
        setupMinutePicker()
        
        setupSelectionRectangle()
        
        setupTopAndBottomBorders()
    }
    
    private func setupTopAndBottomBorders() {
        topBorder = GradientView(frame: frame)
        topBorder.topColor = borderGradientColor_1
        topBorder.bottomColor = borderGradientColor_2
        topBorder.isUserInteractionEnabled = false
        
        addSubview(topBorder)
        
        bottomBorder = GradientView(frame: frame)
        bottomBorder.topColor = borderGradientColor_2
        bottomBorder.bottomColor = borderGradientColor_1
        bottomBorder.isUserInteractionEnabled = false
        
        addSubview(bottomBorder)
    }
    
    private func setupSelectionRectangle() {
        selectionRectangle = UIView()
        selectionRectangle.isUserInteractionEnabled = false
        selectionRectangle.layer.borderColor = selectionRectangleColor.cgColor
        selectionRectangle.layer.borderWidth = CGFloat(selectionRectangleBorderWidth)
        selectionRectangle.backgroundColor = UIColor.clear
        
        addSubview(selectionRectangle)
    }
    
    private func setupHourPicker() {
        hourPicker = WraparoundPickerView()
        
        hourPicker.id = "hourPicker"
        hourPicker.font = font
        hourPicker.textColor = textColor
        hourPicker.backgroundColor = backgroundColor
        
        hourPicker.data = [String]()
        
        for hour in 0...23 {
            var hourString = String(hour)
            if hour < 10 {
                hourString = "0" + hourString
            }
            hourPicker.data.append(hourString)
        }
        
        hourPicker.selectItem(withIndex: 0) //12 o'clock
        
        hourPicker.delegate = self
        
        addSubview(hourPicker)
    }
    
    private func setupColonLabel() {
        colonLabel = UILabel()
        
        colonLabel.font = font
        colonLabel.textColor = textColor
        colonLabel.text = ":"
        colonLabel.backgroundColor = backgroundColor
        
        addSubview(colonLabel)
    }
    
    private func setupMinutePicker() {
        minutePicker = WraparoundPickerView()
        
        minutePicker.id = "minutePicker"
        minutePicker.font = font
        minutePicker.textColor = textColor
        minutePicker.backgroundColor = backgroundColor
        
        minutePicker.data = [String]()
        
        for minute in 0...59 {
            var minuteString = String(minute)
            if minute < 10 {
                minuteString = "0" + minuteString
            }
            minutePicker.data.append(minuteString)
        }
        
        minutePicker.selectItem(withIndex: 0) // 0 minutes
        
        minutePicker.delegate = self
        
        addSubview(minutePicker)
    }
    
    //MARK:- Laying out subviews and drawing
    
    override func layoutSubviews() {
        //Calculate xOffset
        xOffset = (bounds.width - calculateMinimumFrameWidth()) / 2.0
        
        layoutHourPicker()
        
        layoutColonLabel()
        
        layoutMinutePicker()
        
        layoutSelectionRectangle()
        
        layoutTopAndBottomBorders()
    }
    
    private func layoutHourPicker() {
        
        // 1.
        let x = xOffset - scrollPadding
        
        // 2.
        let y = 0.0
        
        // 3.
        let frameHeight = Double(bounds.height)
        
        // 4. Calculate the frame width
        let frameWidth = scrollPadding + 2.0 * labelPadding + calculateLabelWidth(forText: "00")
        
        let frame = CGRect(x: x, y: y, width: frameWidth, height: frameHeight)
        
        hourPicker.paddingLeft = scrollPadding
        hourPicker.frame = frame
    }
    
    private func layoutMinutePicker() {
        
        // 1. Calculate the frame width
        let frameWidth = 2.0 * labelPadding + calculateLabelWidth(forText: "00") + scrollPadding
        
        // 2.
        let frameHeight = Double(bounds.height)
        
        // 3.
        let x = xOffset
            + 2.0 * labelPadding + calculateLabelWidth(forText: "00") //hourPicker
            + calculateLabelWidth(forText: ":")
        
        // 4.
        let y = 0.0
        
        let frame = CGRect(x: x, y: y, width: frameWidth, height: frameHeight)
        
        minutePicker.paddingRight = scrollPadding
        
        minutePicker.frame = frame
    }
    
    private func layoutColonLabel() {
        // 1.
        colonLabel.sizeToFit()
        
        let frameWidth = colonLabel.frame.width
        
        // 2.
        let frameHeight = bounds.height
        
        // 3.
        let y = CGFloat(0.0)
        
        // 4.
        let x = CGFloat(xOffset + 2.0 * labelPadding + calculateLabelWidth(forText: "00"))
        
        let frame = CGRect(x: x, y: y, width: frameWidth, height: frameHeight)
        
        colonLabel.frame = frame
    }
    
    private func layoutSelectionRectangle() {
        let frameWidth = 2.0 * labelPadding + calculateLabelWidth(forText: "00")
            + calculateLabelWidth(forText: ":")
            + 2.0 * labelPadding + calculateLabelWidth(forText: "00")
        
        let frameHeight = Double(bounds.height) / Double(numberOfVisibleRows)
        
        let x = xOffset
        
        let y = Int(numberOfVisibleRows / 2) * frameHeight
        selectionRectangle.frame  = CGRect(x: x, y: y, width: frameWidth, height: frameHeight)
        
        selectionRectangle.layer.cornerRadius = CGFloat(frameHeight * selectionRectangleCornerRadiusRatio)
    }
    
    private func layoutTopAndBottomBorders() {
        let frameWidth = Double(bounds.width)
        
        let frameHeight = borderSizeRatio * bounds.height
        
        let x = 0.0
        
        var y = 0.0
        
        topBorder.frame = CGRect(x: x, y: y, width: frameWidth, height: frameHeight)
        
        y = bounds.height - frameHeight
        
        bottomBorder.frame = CGRect(x: x, y: y, width: frameWidth, height: frameHeight)
    }
    
    
    //MARK:- Private API
    
    private func loadCustomFont() {
        guard let customFont = UIFont(name: fontName , size: CGFloat(self.fontSize)) else {
            fatalError("Failed to load custom font: \(fontName)")
        }
        
        self.font = UIFontMetrics.default.scaledFont(for: customFont)
    }
    
    private func calculateLabelWidth(forText text: String) -> Double {
        let label = UILabel()
        label.font = font
        label.text = text
        label.sizeToFit()
        return Double(label.frame.width)
    }
    
    private func calculateMinimumFrameWidth() -> Double {
        let minimumFrameWidth = 2.0 * labelPadding + calculateLabelWidth(forText: "00")
            + calculateLabelWidth(forText: ":")
            + 2.0 * labelPadding + calculateLabelWidth(forText: "00")
        
        return minimumFrameWidth
    }
    
    //MARK:- Acting as PickerViewDelegate
    
    func pickerDidScroll(sender: UIView) {
        if let picker = sender as? WraparoundPickerView {
            
            if picker.id! == "hourPicker" {
                delegate?.hourPickerDidScroll(picker: picker)
            }
            
            if picker.id! == "minutePicker" {
                delegate?.minutePickerDidScroll(picker: picker)
            }
        }
    }
    
    func valueChanged() {
        let hour =  Int(hourPicker.getPickedItem()) ?? 0
        let minute = Int(minutePicker.getPickedItem()) ?? 0
        
        self.date = Date()
            .new(bySetting: .hour, to: hour)
            .new(bySetting: .minute, to: minute)

        delegate?.valueChanged(sender: self)
    }
    
    //MARK:- Public API
    
    public func getDate() -> Date {
        return date
    }
    
    public func setDate(to date: Date) {
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        hourPicker.selectItem(withIndex: dateComponents.hour!)
        minutePicker.selectItem(withIndex: dateComponents.minute!)

        self.date = date
    }
    
    func setDelegate(_ delegate: TimePickerDelegate) {
        self.delegate = delegate
    }
}
