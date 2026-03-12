//
//  LBIndicator.swift
//  LoadingButtons
//
//  Created by Ho, Tsung Wei on 8/7/19.
//  Copyright © 2019 Ho, Tsungwei. All rights reserved.
//

import UIKit

 class LBIndicator: UIView, IndicatorProtocol {
     var isAnimating: Bool = false
     var radius: CGFloat = 18.0
     var color: UIColor = .lightGray
    
     convenience init(radius: CGFloat = 18.0, color: UIColor = .gray) {
        self.init()
        self.radius = radius
        self.color = color
    }
    
     func startAnimating() {
        guard !isAnimating else { return }
        isHidden = false
        isAnimating = true
        layer.speed = 1
        setupAnimation(in: self.layer, size: CGSize(width: 2*radius, height: 2*radius))
    }
    
     func stopAnimating() {
        guard isAnimating else { return }
        isHidden = true
        isAnimating = false
        layer.sublayers?.removeAll()
    }
    
     func setupAnimation(in layer: CALayer, size: CGSize) {
        fatalError("Need to be implemented")
    }
}
