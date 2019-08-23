//
//  CgPath+Elements.swift
//  GaugeSlider
//
//  Created by Edgar Žigis on 23/08/2019.
//  Copyright © 2019 Edgar Žigis. All rights reserved.
//

import UIKit

extension CGPath {
    
    func forEach(body: @escaping @convention(block) (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        func callback(info: UnsafeMutableRawPointer?, element: UnsafePointer<CGPathElement>) {
            let body = unsafeBitCast(info, to: Body.self)
            body(element.pointee)
        }
        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        self.apply(info: unsafeBody, function: callback)
    }
}
