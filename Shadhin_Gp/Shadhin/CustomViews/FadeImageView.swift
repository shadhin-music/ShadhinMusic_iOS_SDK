//
//  FadeImageView.swift
//  Shadhin
//
//  Created by Joy on 23/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class FadeImageView: UIImageView
{
    @IBInspectable
    var fadeDuration: Double = 0.13

    override var image: UIImage?{
        get {
            return super.image
        }
        set(newImage){
            if let img = newImage{
                CATransaction.begin()
                CATransaction.setAnimationDuration(self.fadeDuration)

                let transition = CATransition()
                transition.type = CATransitionType.fade
                    
                super.layer.add(transition, forKey: kCATransition)
                super.image = img

                CATransaction.commit()
               
            }else {
                super.image = nil
            }
        }
    }
}
