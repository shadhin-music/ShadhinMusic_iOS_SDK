//
//  MusicCommentsV4.swift
//  Shadhin
//
//  Created by Gakk Alpha on 3/28/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class MusicCommentsV4: UICollectionViewCell {

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }

//    static var size: CGSize {
//        return .init(width: SCREEN_WIDTH - 84, height: 10)
//    }
    
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var timeAgo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.widthAnchor.constraint(equalToConstant: SCREEN_WIDTH - 84).isActive = true
    }
}
