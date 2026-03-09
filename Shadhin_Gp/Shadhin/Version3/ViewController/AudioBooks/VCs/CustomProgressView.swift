//
//  CustomProgressView.swift
//  Shadhin
//
//  Created by Maruf on 31/10/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class CustomProgressView: UIView {

    private let circleLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let percentageLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        let radius = (min(bounds.width, bounds.height) - 4) / 2 // Adjust radius for smaller size
        
        // Set up the circular path
        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: 3 * CGFloat.pi / 2,
            clockwise: true
        )
        
        // Configure the background circle layer
        circleLayer.path = circularPath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.lightGray.cgColor
        circleLayer.lineWidth = 1.5
        circleLayer.lineCap = .round
        layer.addSublayer(circleLayer)
        
        // Configure the progress layer
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor(named: "tintColor")?.cgColor
        progressLayer.lineWidth = 1.5
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0 // Start with no progress
        layer.addSublayer(progressLayer)
        
        // Configure percentage label
        percentageLabel.textAlignment = .center
        percentageLabel.font = UIFont.systemFont(ofSize: 6)
        if #available(iOS 13.0, *) {
            percentageLabel.textColor = UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? .white : .black
            }
        } else {
            // Fallback on earlier versions
        }
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(percentageLabel)
        
        // Center label within the circular progress view
        NSLayoutConstraint.activate([
            percentageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            percentageLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // Set progress percentage (0 to 100)
    func setProgress(percentage: Int) {
        let clampedPercentage = max(0, min(100, percentage))
        
        // Set the percentage label text directly
        percentageLabel.text = "\(percentage)%"
        
        // Optionally, set the `strokeEnd` for the progress layer without animation, if desired
        let progress = CGFloat(clampedPercentage) / 100.0
        progressLayer.strokeEnd = progress
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = progress
        animation.duration = 1.0
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: "progressAnim")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
}
