//
//  CircularImageView.swift
//  CustomView
//
//  Created by Joy on 25/7/22.
//

import UIKit
import AVFoundation
import SwiftUI
@IBDesignable
class CircularImageView: UIImageView {
    @IBInspectable
    var boderWidth : CGFloat = 0 {
        didSet{
            self.layer.borderWidth = boderWidth
        }
    }
    @IBInspectable
    var boderColor : UIColor = .clear{
        didSet{
            self.layer.borderColor = boderColor.cgColor
        }
    }
    
    @IBInspectable
    var cornarRadius : CGFloat = 0.0 {
        didSet{
            self.layer.cornerRadius = cornarRadius
        }
    }
    
    @IBInspectable
    var  isCircular : Bool = false {
        didSet{
            if isCircular{
                self.cornarRadius = bounds.height / 2
            }
        }
    }
    @IBInspectable
    var shadowOffset : CGSize = .zero {
        didSet{
            self.layer.shadowOffset = shadowOffset
        }
    }
    @IBInspectable
    var shadowRadius : CGFloat = 0.0{
        didSet{
            self.layer.shadowRadius = shadowRadius
        }
    }
    @IBInspectable
    var shadowColor : UIColor = .clear{
        didSet{
            self.layer.shadowColor = shadowColor.cgColor
        }
    }
    @IBInspectable
    var shadowOpacity : Float = 0.5{
        didSet{
            self.layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable
    override var image : UIImage?{
        set{
            super.image = circularImagemake(image: newValue)
        }
        get{
            return super.image
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForInterfaceBuilder() {
        setupView()
    }
    
    private func setupView(){
        clipsToBounds = false
        if isCircular{
            cornarRadius = bounds.height / 2
        }
        layer.borderWidth = boderWidth
        layer.borderColor = boderColor.cgColor
        layer.cornerRadius = cornarRadius
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.masksToBounds = false
        layer.rasterizationScale = UIScreen.main.scale
        layer.allowsEdgeAntialiasing = true
        layer.shouldRasterize = true
        super.image = circularImagemake(image: image)
    }
    
    private func circularImagemake(image: UIImage?)-> UIImage?{
        guard let circularImage = image else {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0);
        // Add a clip before drawing anything, in the shape of an rounded rect
        UIBezierPath(roundedRect: bounds, cornerRadius:cornarRadius).addClip()
        
        let rec = cgSizeAspectFill(aspectRatio: circularImage.size, minimumSize: bounds.size)
        circularImage.draw(in: rec)
       
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
    
//    override func draw(_ rect: CGRect) {
//        super.image = circularImagemake(image: originalImage)
//        super.draw(rect)
//    }
    
 //   private var originalImage: UIImage?
    func cgSizeAspectFill( aspectRatio: CGSize, minimumSize: CGSize) -> CGRect{
        var aspectFillSize = CGSize(width: minimumSize.width, height: minimumSize.height)
        let mW = minimumSize.width / aspectRatio.width;
        let mH = minimumSize.height / aspectRatio.height
        var adjustX : CGFloat = 0
        var adjustY : CGFloat = 0
        if mH > mW {
            aspectFillSize.width = mH * aspectRatio.width
            adjustX = -(aspectFillSize.width - minimumSize.width) / 2
        }else if mW > mH {
            aspectFillSize.height = mW * aspectRatio.height
            adjustY = -(aspectFillSize.height - minimumSize.height) / 2
        }
        return CGRect(origin: .init(x: adjustX, y: adjustY), size: aspectFillSize)
    }
}
