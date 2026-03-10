//
//  CheckBox.swift
//  Shadhin
//
//  Created by Rezwan on 8/20/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class CheckBox: UIImageView {
    
    var mainImg : UIImage? = nil
    
    override var isHighlighted: Bool{
        didSet{
            if mainImg == nil{
                mainImg = image
            }
            if isHighlighted{
                image = highlightedImage
            }else{
                image = mainImg
            }
        }
    }
    
}
