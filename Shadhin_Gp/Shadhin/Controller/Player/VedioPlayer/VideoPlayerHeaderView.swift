//
//  VideoPlayerHeaderView.swift
//  Shadhin
//
//  Created by Gakk Alpha on 11/25/21.
//  Copyright © 2021 Cloud 7 Limited. All rights reserved.
//

import UIKit

class VideoPlayerHeaderView: UICollectionReusableView {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }

    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var viewModeBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
