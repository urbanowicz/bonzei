//
//  DayOfWeekPicker.swift
//  Navigation
//
//  Created by Tomasz on 24/04/2020.
//  Copyright © 2020 Tomasz Urbanowicz. All rights reserved.
//

import UIKit

@IBDesignable
class DayOfWeekPicker: UIControl, UIGestureRecognizerDelegate {
    
    //Spacing between labels.
    @IBInspectable var spacing:Float = 15
    
    //Corner radius of the selection rectangle
    @IBInspectable var radius:Float = 15
    
    //Color of the selection rectangle
    @IBInspectable var color:UIColor = UIColor.systemGreen
    
    //Day of week labels 'M' 'T' 'W' 'T' 'F' 'S' 'S'
    private var labels = [DayOfWeekLabel]()
    
    //Represents a current selection.
    //For example:
    //selection == [0,1] means 'Monday' and 'Tuesday' are selected.
    //selection == [0,2,3,4] means 'Monday','Wednesday', Thursday' and 'Friday' are selected.
    //selection == [] means no day is selected.
    var selection = Set<Int>([0])
    
    //We will draw selection rectangles in this layer
    var selectionLayer = CAShapeLayer()
    
    //User selects/deselects a day with a tap gesture.
    var tapGestureRecognizer = UITapGestureRecognizer()
    
    //MARK: - Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder:coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    ///Called by other 'init' functions
    private func commonInit() {
        initSelectionLayer()
        initDayOfWeekLabels()
        initTapGestureRecognizer()
    }
    
    ///Perform initial setup for labels that represent day of weeks.
    private func initDayOfWeekLabels() {
        //'Day of week' labels
        let texts:[String] = ["M", "T", "W", "T", "F", "S", "S"]
        
        //Create labels and add them as subviews
        var index = 0
        for text in texts {
            let label = DayOfWeekLabel()
            label.index = index
            label.text = text
            label.isUserInteractionEnabled = false
            label.textAlignment = .center
            label.backgroundColor = UIColor.clear
            self.addSubview(label)
            labels.append(label)
            index += 1
        }
    }
    
    private func initSelectionLayer() {
        layer.addSublayer(selectionLayer)
    }
    
    private func initTapGestureRecognizer() {
        tapGestureRecognizer.addTarget(self,action:#selector(DayOfWeekPicker.handleTapGesture(recognizer:)))
        tapGestureRecognizer.delegate = self
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    //MARK: - Perform Layout
    
    override func layoutSubviews() {
        layoutSelectionLayer()
        layoutDayOfWeekLabels()
    }
    
    private func layoutSelectionLayer() {
        selectionLayer.backgroundColor = UIColor.clear.cgColor
        selectionLayer.fillColor = color.cgColor
        selectionLayer.frame = CGRect(origin: self.bounds.origin, size: self.bounds.size)
    }
    
    private func layoutDayOfWeekLabels() {
        //Spacing between the labels
        let spacing = CGFloat(self.spacing)
        
        //Width of a label
        let w = (bounds.width - 8*spacing) / 7.0
        
        //Height of a label
        let h = bounds.height
        
        //x coordinate of a label
        var x = bounds.origin.x
        
        //y coordinate of a label
        let y = bounds.origin.y
        
        for label in labels {
            x += spacing
            label.frame = CGRect(x: x, y: y, width: w, height: h)
            x += w
        }
    }
    
    //MARK: - Handle Gestures
    
    ///Handle a tap gesture. Users use a tap gesture to select or deselect a day of week
    @IBAction func handleTapGesture(recognizer:UITapGestureRecognizer) {
        let touchedLabels = labels.filter() { (x: UILabel) -> Bool in
                let touchCoordinates = tapGestureRecognizer.location(in: x)
            return x.point(inside: touchCoordinates, with: nil)
        }
        if let touchedLabel = touchedLabels.first {
            let i = touchedLabel.index
            if selection.contains(i) {
                selection.remove(i)
            } else {
                selection.insert(i)
            }
        }
        self.setNeedsDisplay()
    }
    
    //MARK: - Draw
    
    override func draw(_ rect: CGRect) {
        let selectionSegments = calculateSelectionSegments()
        let selectionPath = CGMutablePath()
        
        let x = bounds.origin.x
        
        let y = bounds.origin.y
        
        //Spacing between the labels
        let spacing = CGFloat(self.spacing)
        
        //Width of a label
        let w = (bounds.width - 8*spacing) / 7.0
        
        //corner radius of the rounded selection rectangle
        let radius = CGFloat(self.radius)
        
        for selectionSegment in selectionSegments {
            let index = CGFloat(selectionSegment.0)
            let numberOfDaysInSelection = CGFloat(selectionSegment.1)
            
            let rect = CGRect(
                x: x + index * (spacing + w),
                y: y,
                width: numberOfDaysInSelection * w + (numberOfDaysInSelection + 1) * spacing,
                height: bounds.height)
            
            selectionPath.addPath(UIBezierPath(roundedRect: rect, cornerRadius: radius).cgPath)
        }
        selectionLayer.path = selectionPath
    }
    
    private func calculateSelectionSegments() ->[(Int, Int)] {
        var s = [Int](selection)
        s = s.sorted()
        var selectionSegments = [(Int,Int)]()
        var rectX = 0
        var rectW = 1
        while(s.count > 0) {
            let x = s.removeFirst()
            rectX = x
            rectW = 1
            for i in 0..<s.count {
                if x + (i+1) == s[i]  {
                    rectW += 1
                } else {
                    break
                }
            }
            s.removeFirst(rectW - 1)
            selectionSegments.append((rectX, rectW))
        }
        return selectionSegments
    }
}

///A simple 'UILabel' subclass. We need it because we want to give each label an index.
///For example:
///'Monday' label has ndex = 0
///'Tuesday' label has index = 1
///... and so forth.
///Why it is that we need an index? Because when the 'tap' gesture occurs we will only get the UILabel instance underneath the touch.
///But which day of week does this instance represent? 'Index' field provides the answer to this question.
fileprivate class DayOfWeekLabel: UILabel {
    var index:Int = 0
}
