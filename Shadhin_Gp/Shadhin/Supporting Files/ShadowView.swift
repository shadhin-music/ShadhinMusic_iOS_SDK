//
//  UIShadow.swift
//  Lollipop
//
//  Created by Rezwan on 11/5/19.
//  Copyright © 2019 Gakk Media. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class ShadowView: UIView {
    
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    @IBInspectable var isCircular: Bool = true {
        didSet {
            updateLocations()
        }
    }

    
    func updateLocations() {
        if isCircular{
            layer.cornerRadius = self.frame.size.height / 2
        }else{
            layer.cornerRadius = 0
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        updateLocations()
    }
}

