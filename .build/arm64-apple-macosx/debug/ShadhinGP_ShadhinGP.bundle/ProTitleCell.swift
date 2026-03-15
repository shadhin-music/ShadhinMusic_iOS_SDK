//
//  ProTitleCell.swift
//  Shadhin
//
//  Created by Maruf on 13/2/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class ProTitleCell: UICollectionViewCell {

    static var SIZE : CGSize{
        let width = (SCREEN_WIDTH - 32)
        let height = (width * 255 / 328)
        return .init(width: width, height: height)
    }
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
