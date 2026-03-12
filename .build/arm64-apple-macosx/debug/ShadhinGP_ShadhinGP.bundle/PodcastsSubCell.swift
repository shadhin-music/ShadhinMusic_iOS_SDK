//
//  PodcastsSubCell.swift
//  Shadhin
//
//  Created by Maruf on 7/12/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class PodcastsSubCell: UICollectionViewCell {
    
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var size : CGSize{
        return .init(width: 136, height: 136)
    }
    
    
    @IBOutlet weak var podcastsImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
