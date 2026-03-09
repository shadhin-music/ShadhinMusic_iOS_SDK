//
//  WinAndStreamCell.swift
//  Shadhin
//
//  Created by Joy on 15/2/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class WinAndStreamCell: UICollectionViewCell {

    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var SIZE : CGSize{
        let width = (SCREEN_WIDTH - 32)
        let height = (width * 500 / 328)
        return .init(width: width, height: height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
