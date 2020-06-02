//
//  BonzeiClockFace.swift
//  ProjectName
//
//  Created by Tomasz Urbanowic on 01/06/2020.
//  Copyright © 2020 Bonzei.app. All rights reserved.
//
//  Generated by PaintCode
//  http://www.paintcodeapp.com
//



import UIKit

public class BonzeiClockFace : NSObject {

    //// Drawing Methods

    @objc dynamic public class func drawCanvas1(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 279, height: 238), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 279, height: 238), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 279, y: resizedFrame.height / 238)


        //// Color Declarations
        let gradientColor = UIColor(red: 0.231, green: 0.553, blue: 0.949, alpha: 1.000)
        let gradientColor2 = UIColor(red: 0.231, green: 0.263, blue: 0.949, alpha: 1.000)
        let gradientColor3 = UIColor(red: 0.988, green: 0.859, blue: 0.839, alpha: 1.000)
        let gradientColor4 = UIColor(red: 0.875, green: 0.906, blue: 0.976, alpha: 1.000)

        //// Gradient Declarations
        let linearGradient4 = CGGradient(colorsSpace: nil, colors: [gradientColor.cgColor, gradientColor2.cgColor] as CFArray, locations: [0, 1])!
        let linearGradient1 = CGGradient(colorsSpace: nil, colors: [gradientColor3.cgColor, gradientColor4.cgColor] as CFArray, locations: [0, 1])!

        //// 💎-UI-Designs
        //// Wake-up:-Set-alarm
        //// Clock-illu
        //// Group 6
        context.saveGState()
        context.beginTransparencyLayer(auxiliaryInfo: nil)


        //// path- Drawing
        let pathPath = UIBezierPath(ovalIn: CGRect(x: 0.37, y: -0.07, width: 172.69, height: 172.69))
        context.saveGState()
        pathPath.addClip()
        context.drawLinearGradient(linearGradient1,
            start: CGPoint(x: 81.81, y: 62.85),
            end: CGPoint(x: 43.69, y: 178.69),
            options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        context.restoreGState()


        //// Oval 4 Drawing
        context.saveGState()
        context.setAlpha(0.4)
        context.setBlendMode(.screen)

        let oval4Path = UIBezierPath(ovalIn: CGRect(x: 96.41, y: 86.27, width: 110.65, height: 110.65))
        context.saveGState()
        oval4Path.addClip()
        context.drawLinearGradient(linearGradient4,
            start: CGPoint(x: 148.58, y: 126.59),
            end: CGPoint(x: 124.16, y: 200.81),
            options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        context.restoreGState()

        context.restoreGState()


        //// Oval-Copy Drawing
        context.saveGState()
        context.setAlpha(0.4)
        context.setBlendMode(.screen)

        let ovalCopyPath = UIBezierPath(ovalIn: CGRect(x: 92.88, y: 14.03, width: 169.26, height: 169.26))
        context.saveGState()
        ovalCopyPath.addClip()
        context.drawLinearGradient(linearGradient4,
            start: CGPoint(x: 172.7, y: 75.7),
            end: CGPoint(x: 135.34, y: 189.24),
            options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        context.restoreGState()

        context.restoreGState()


        //// Oval-Copy-2 Drawing
        context.saveGState()
        context.setAlpha(0.4)
        context.setBlendMode(.screen)

        let ovalCopy2Path = UIBezierPath(ovalIn: CGRect(x: -17.25, y: 60.72, width: 169.26, height: 169.26))
        context.saveGState()
        ovalCopy2Path.addClip()
        context.drawLinearGradient(linearGradient4,
            start: CGPoint(x: 62.57, y: 122.39),
            end: CGPoint(x: 25.21, y: 235.93),
            options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        context.restoreGState()

        context.restoreGState()


        context.endTransparencyLayer()
        context.restoreGState()
        
        context.restoreGState()

    }




    @objc(BonzeiClockFaceResizingBehavior)
    public enum ResizingBehavior: Int {
        case aspectFit /// The content is proportionally resized to fit into the target rectangle.
        case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
        case stretch /// The content is stretched to match the entire target rectangle.
        case center /// The content is centered in the target rectangle, but it is NOT resized.

        public func apply(rect: CGRect, target: CGRect) -> CGRect {
            if rect == target || target == CGRect.zero {
                return rect
            }

            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)

            switch self {
                case .aspectFit:
                    scales.width = min(scales.width, scales.height)
                    scales.height = scales.width
                case .aspectFill:
                    scales.width = max(scales.width, scales.height)
                    scales.height = scales.width
                case .stretch:
                    break
                case .center:
                    scales.width = 1
                    scales.height = 1
            }

            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }
}
