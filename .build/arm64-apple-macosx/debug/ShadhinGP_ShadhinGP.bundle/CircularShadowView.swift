//
//  UIViewCustom.swift
//  CustomView
//
//  Created by Joy on 25/7/22.
//

import UIKit

@IBDesignable
class CircularShadowView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupView() {
        if isCircular{
            cornerRadius = bounds.height / 2
        }
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = shadowOpacity
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.layer.masksToBounds = false
        layer.rasterizationScale = UIScreen.main.scale
        layer.allowsEdgeAntialiasing = true
        layer.shouldRasterize = true
    }

    @IBInspectable
    var isCircular : Bool = false {
        didSet{
            if isCircular{
                cornerRadius = bounds.height / 2
            }
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor = .black {
        didSet {
            self.layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat = 0 {
        didSet {
            self.layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float = 0 {
        didSet {
            self.layer.shadowOpacity = shadowOpacity
        }
    }
    
    
    @IBInspectable
    var shadowOffset : CGSize = .zero {
        didSet{
            self.layer.shadowOffset = shadowOffset
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
    
}
