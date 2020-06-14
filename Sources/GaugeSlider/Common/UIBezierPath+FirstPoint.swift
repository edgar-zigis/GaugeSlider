//
//  UIBezierPath+FirstPoint.swift
//  GaugeSlider
//
//  Created by Edgar Žigis on 23/08/2019.
//  Copyright © 2019 Edgar Žigis. All rights reserved.
//

import UIKit

extension UIBezierPath {
    
    func firstPoint() -> CGPoint? {
        var firstPoint: CGPoint? = nil
        cgPath.forEach { element in
            guard firstPoint == nil else { return }
            assert(element.type == .moveToPoint, "Expected the first point to be a move")
            firstPoint = element.points.pointee
        }
        return firstPoint
    }
}
