//
//  PodcastFooterViewCell.swift
//  Shadhin
//
//  Created by Rezwan on 2/11/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class PodcastFooterViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var seeAllBtn: UIButton!
    
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var height: CGFloat {
        return 220
        
    }
    
    override func awakeFromNib() {
        
    }
}
