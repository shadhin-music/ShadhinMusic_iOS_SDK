//
//  GamesCCell.swift
//  Shadhin
//
//  Created by Gakk Alpha on 10/18/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class GamesCCell: UICollectionViewCell {

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size: CGSize {
        return CGSize(width: 288, height: 226)
    }
    

}
