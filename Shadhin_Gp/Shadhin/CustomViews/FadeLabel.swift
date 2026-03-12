//
//  FadeLabel.swift
//  Shadhin
//
//  Created by Joy on 23/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class FadeLabel: UILabel {
    @IBInspectable
    var fadeDuration: Double = 0.13
    override var text: String?{
        get{
            return super.text
        }
        set(newText){
            if let txt = newText{
                CATransaction.begin()
                CATransaction.setAnimationDuration(self.fadeDuration)

                let transition = CATransition()
                transition.type = CATransitionType.fade
                    
                super.layer.add(transition, forKey: kCATransition)
                super.text = txt

                CATransaction.commit()
               
            }else {
                super.text = nil
            }
        }
    }
}
