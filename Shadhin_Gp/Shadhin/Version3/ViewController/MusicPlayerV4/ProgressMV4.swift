//
//  ProgressMV4.swift
//  Shadhin
//
//  Created by Joy on 4/4/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class ProgressMV4: UIView {
    fileprivate var imageView = UIImageView()
    fileprivate var progressLayer = CAShapeLayer()
    fileprivate var trackLayer = CAShapeLayer()
    fileprivate var squareShape = CAShapeLayer()
    fileprivate var didConfigureLabel = false
    fileprivate var rounded: Bool
    fileprivate var filled: Bool

    private var timeToFill = 3.43
    
    var progressColor : UIColor = .appTintColor{
        didSet{
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    var trackColor = #colorLiteral(red: 0.7910822034, green: 0.7910822034, blue: 0.7910822034, alpha: 1){
        didSet{
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    private var lineWidth : CGFloat = 2{
        didSet{
            progressLayer.lineWidth = lineWidth
        }
    }
    var progress: Float {
        didSet{
            var pathMoved = progress - oldValue
            if pathMoved < 0{
                pathMoved = 0 - pathMoved
            }
            
            setProgress(duration: timeToFill * Double(pathMoved), to: progress)
        }
    }
    override init(frame: CGRect){
        progress = 0
        rounded = true
        filled = false
        super.init(frame: frame)
        filled = false
        createProgressView()
    }

    required init?(coder: NSCoder) {
        progress = 0
        rounded = true
        filled = false
        super.init(coder: coder)
        createProgressView()
        
    }


    fileprivate func createProgressView(){
        
        self.backgroundColor = .clear
        self.layer.cornerRadius = frame.size.width / 2
        let circularPath = UIBezierPath(arcCenter: center, radius: frame.width / 3, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        trackLayer.fillColor = UIColor.blue.cgColor
        
        
        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = .none
        trackLayer.strokeColor = trackColor.cgColor
        if filled {
            trackLayer.lineCap = .butt
            trackLayer.lineWidth = frame.width
        }else{
            trackLayer.lineWidth = lineWidth
        }
        trackLayer.strokeEnd = 1
        layer.addSublayer(trackLayer)
        
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = .none
        progressLayer.strokeColor = progressColor.cgColor
        if filled {
            progressLayer.lineCap = .butt
            progressLayer.lineWidth = frame.width
        }else{
            progressLayer.lineWidth = lineWidth
        }
        progressLayer.strokeEnd = 0
        if rounded{
            progressLayer.lineCap = .round
        }
        
        layer.addSublayer(progressLayer)
        //square make
        squareShape.path = UIBezierPath(roundedRect: .init(x: 0, y: 0, width: bounds.width / 3, height: bounds.height / 3), cornerRadius: 4).cgPath
        squareShape.frame = .init(x: bounds.width / 3, y: bounds.height / 3, width: bounds.width / 3, height: bounds.height / 3)
        squareShape.fillColor = progressColor.cgColor
        layer.addSublayer(squareShape)
        
        imageView.frame = bounds
        imageView.image = UIImage(named: "circel",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        addSubview(imageView)
    }
    func trackColorToProgressColor() -> Void{
        trackColor = progressColor
        trackColor = UIColor(red: progressColor.cgColor.components![0], green: progressColor.cgColor.components![1], blue: progressColor.cgColor.components![2], alpha: 0.2)
    }
    func setProgress(duration: TimeInterval = 3, to newProgress: Float) -> Void{
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = newProgress
        
        progressLayer.strokeEnd = CGFloat(newProgress)
        
        progressLayer.add(animation, forKey: "animationProgress")
        
    }
}
