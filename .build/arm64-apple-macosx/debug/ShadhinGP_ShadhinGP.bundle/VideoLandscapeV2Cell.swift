//
//  VideoLandscapeV2Cell.swift
//  Shadhin
//
//  Created by Gakk Alpha on 1/3/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class VideoLandscapeV2Cell: UICollectionViewCell {

    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size : CGSize{
        return CGSize(width: 280, height: 158)
    }
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var imgBg: UIImageView!
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!

}
