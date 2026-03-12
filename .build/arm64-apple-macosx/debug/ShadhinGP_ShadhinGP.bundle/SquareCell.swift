//
//  ImageRatioCell.swift
//  Shadhin
//
//  Created by Rezwan on 8/4/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class SquareCell: UICollectionViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size : CGSize{
          return CGSize(width: 136, height: 136 + 48)
    }
    
//    static func size(_ cellType: PodcastCollectionCell.CellType)-> CGSize {
//        switch cellType {
//        case .SquareBig:
//            return CGSize(width: 136, height: 136)
//        case .SquareSmall:
//            return CGSize(width: 96, height: 96)
//        case .Portrait:
//            return CGSize(width: 136, height: 204 + 48)
//        case .LandscapeWithLabel:
//            return CGSize(width: 280, height: 158)
//        case .SquareSmallWithLabel:
//            return CGSize(width: 136, height: 136 + 48)
//        case .VideoPortrait:
//            return VideoPortraitCell.size
//        }
//    }
//    
//    static func size(_ patchType: String)-> CGSize {
//        switch patchType.lowercased() {
//        case "le":
//            return CGSize(width: 136, height: 136 + 48)
//        case "pp":
//            return CGSize(width: 136, height: 136)
//        case "ps":
//            return CGSize(width: 280, height: 158)
//        case "ss":
//            return CGSize(width: 136, height: 204 + 48)
//        case "tn":
//            return CGSize.zero
//        default:
//            return CGSize.zero
//        }
//    }
//    

    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var labelHolderHeight: NSLayoutConstraint! // 0||48
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
