//
//  LyricsV4.swift
//  Shadhin
//
//  Created by Gakk Alpha on 1/5/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class LyricsV4: UICollectionViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }

    static var size: CGSize {
        return .init(width: SCREEN_WIDTH - 84, height: 56)
    }
    
    @IBOutlet weak var lyricsLbl: UILabel!
    @IBOutlet weak var sideBar: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        //self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.widthAnchor.constraint(equalToConstant: SCREEN_WIDTH - 84).isActive = true
    }

}
