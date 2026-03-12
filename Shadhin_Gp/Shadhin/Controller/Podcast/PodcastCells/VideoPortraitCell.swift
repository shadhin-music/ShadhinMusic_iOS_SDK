//
//  VideoPortraitCell.swift
//  Shadhin
//
//  Created by Rezwan on 23/6/21.
//  Copyright © 2021 Cloud 7 Limited. All rights reserved.
//

import UIKit

class VideoPortraitCell: UICollectionViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size : CGSize{
        return CGSize(width: 136, height: 204)
    }
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var imgBg: UIImageView!
    @IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!



}
