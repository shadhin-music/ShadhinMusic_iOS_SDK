//
//  HeaderViewCV.swift
//  Shadhin
//
//  Created by Maruf on 13/2/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class HeaderViewCVSubscription: UICollectionReusableView {

    @IBOutlet weak var planTitleLbl: UILabel!
    static var HEIGHT : CGFloat{
          let h = (SCREEN_WIDTH - 32) * 17/95
          return h
      }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
