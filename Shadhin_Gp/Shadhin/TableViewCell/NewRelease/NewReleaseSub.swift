//
//  NewReleaseSub.swift
//  Shadhin
//
//  Created by Rezwan on 20/6/21.
//  Copyright © 2021 Cloud 7 Limited. All rights reserved.
//

import UIKit


class NewReleaseSub: FSPagerViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size: CGSize {
        return CGSize(width: 146, height: 216)
    }
    
    @IBOutlet weak var artistImg: UIImageView!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var trackImg: UIImageView!
    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var trackPlayCount: UILabel!
    @IBOutlet weak var playPauseImg: UIImageView!
    
    
}
