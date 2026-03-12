//
//  ArtistsInPlaylistCC.swift
//  Shadhin
//
//  Created by Gakk Alpha on 7/28/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class ArtistsInPlaylistCC: UICollectionViewCell {

    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size: CGSize {
        return CGSize(width: 120, height: 200)
    }
    
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var artistFollowCount: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
}


