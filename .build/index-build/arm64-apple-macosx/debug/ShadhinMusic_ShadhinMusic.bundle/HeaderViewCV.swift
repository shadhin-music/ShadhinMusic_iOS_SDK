//
//  HeaderViewCV.swift
//  Shadhin
//
//  Created by Maruf on 12/2/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class HeaderViewCV: UICollectionReusableView {
    
    @IBOutlet weak var headerTitle: UILabel!
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    static var HEIGHT : CGFloat{
        let h = (SCREEN_WIDTH - 32) * 33/360
        return h
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
