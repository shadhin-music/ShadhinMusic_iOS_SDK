//
//  ImageRatioCell.swift
//  Shadhin
//
//  Created by Rezwan on 8/4/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class SquareBigCell: UICollectionViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size : CGSize{
        return CGSize(width: 136, height: 136)
    }
    
    
    

    
    @IBOutlet weak var img: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
