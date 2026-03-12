//
//  DashedLineView.swift
//  Shadhin
//
//  Created by Rezwan on 24/9/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//


import UIKit
@IBDesignable
class DashedLineView : UIView {
    @IBInspectable var perDashLength: CGFloat = 2.0
    @IBInspectable var spaceBetweenDash: CGFloat = 2.0
    @IBInspectable var dashColor: UIColor = UIColor.lightGray


    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let  path = UIBezierPath()
        if height > width {
            let  p0 = CGPoint(x: self.bounds.midX, y: self.bounds.minY)
            path.move(to: p0)

            let  p1 = CGPoint(x: self.bounds.midX, y: self.bounds.maxY)
            path.addLine(to: p1)
            path.lineWidth = width

        } else {
            let  p0 = CGPoint(x: self.bounds.minX, y: self.bounds.midY)
            path.move(to: p0)

            let  p1 = CGPoint(x: self.bounds.maxX, y: self.bounds.midY)
            path.addLine(to: p1)
            path.lineWidth = height
        }

        let  dashes: [ CGFloat ] = [ perDashLength, spaceBetweenDash ]
        path.setLineDash(dashes, count: dashes.count, phase: 0.0)

        path.lineCapStyle = .butt
        dashColor.set()
        path.stroke()
    }

}
