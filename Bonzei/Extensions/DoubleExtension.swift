//
//  DoubleExtension.swift
//  Bonzei
//
//  Created by Tomasz on 27/05/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import Foundation
import UIKit

extension Double {
    var cgFloat: CGFloat {
        get {
            return CGFloat(self)
        }
    }
}

extension CGFloat {
    var asDouble: Double {
        get {
            return Double(self)
        }
    }
}

func *(lhs: Int, rhs: Double) -> Double {
    return Double(lhs) * rhs
}

func *(lhs: Double, rhs: Int) -> Double {
    return lhs * Double(rhs)
}
func *(lhs: CGFloat, rhs: Double) -> Double {
    return Double(lhs) * rhs
}

func *(lhs: Double, rhs: CGFloat) -> Double {
    return lhs * Double(rhs)
}

func +(lhs: Int, rhs: Double) -> Double {
    return Double(lhs) + rhs
}

func +(lhs: Double, rhs: Int) -> Double {
    return lhs + Double(rhs)
}

func +(lhs: CGFloat, rhs: Double) -> Double {
    return Double(lhs) + rhs
}

func +(lhs: Double, rhs: CGFloat) -> Double {
    return lhs + Double(rhs)
}

func -(lhs: Int, rhs: Double) -> Double {
    return Double(lhs) - rhs
}

func -(lhs: Double, rhs: Int) -> Double {
    return lhs - Double(rhs)
}

func -(lhs: CGFloat, rhs: Double) -> Double {
    return Double(lhs) - rhs
}

func -(lhs: Double, rhs: CGFloat) -> Double {
    return lhs - Double(rhs)
}
