//
//  PodcastEpisodeItem.swift
//  Shadhin
//
//  Created by Rezwan on 2/12/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//


import UIKit

class PodcastEpisodeItem: UICollectionViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size_pd: CGSize {
        return CGSize(width: 138, height: 162)
    }
    
    static var size_vd: CGSize {
        return CGSize(width: 246, height: 162)
    }
    

    @IBOutlet weak var episodeImg: UIImageView!
    @IBOutlet weak var episodeTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.episodeTitle.text = ""
    }
}
