//
//  GeneratedVC.swift
//  Shadhin
//
//  Created by Maruf on 14/5/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class GeneratedVC: UIViewController,NIBVCProtocol {
    var isDark = false
    @IBOutlet weak var progressLbl: UILabel!
    @IBOutlet weak var generateImgView: UIView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressImgView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        rotateView(view: progressImgView)
        progreesViewSetup()
    //     progressView.backgroundColor =  UIColor(named: "selectModeBgColor",in:Bundle.ShadhinMusicSdk,compatibleWith:nil)
//        generateImgView.layer.backgroundColor = UIColor(named:"selectModeBgColor")?.cgColor
    }
    private func progreesViewSetup() {
        if isDark {
            generateImgView.backgroundColor = UIColor(named: "circle_imgBg",in:Bundle.ShadhinMusicSdk,compatibleWith:nil)
            progressView.backgroundColor = UIColor.black
            progressLbl.textColor = .white
        } else {
            generateImgView.backgroundColor = UIColor.white
            progressView.backgroundColor = UIColor(named: "procressViewBgWhite")
        }
    }
    func rotateView(view: UIView) {
        // Create a rotation animation
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        
        // Set the start and end values for the rotation animation
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = CGFloat(Double.pi * 2.0) // Full rotation (360 degrees)
        
        // Set the duration of the rotation (adjust as needed)
        rotationAnimation.duration = 2.0 // 5 seconds for one full rotation
        
        // Set the repeat count to infinity for unlimited rotation
        rotationAnimation.repeatCount = .infinity
        
        // Add the rotation animation to the image view's layer
        view.layer.add(rotationAnimation, forKey: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
          super.traitCollectionDidChange(previousTraitCollection)
          
      }

}

