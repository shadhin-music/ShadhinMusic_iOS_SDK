//
//  SeeAllCell.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 13/6/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class SeeAllCell: UICollectionReusableView {
    
    var onSeeAllClick: ()->Void = {}
    @IBOutlet weak var seeAllImageView: UIImageView!
    @IBOutlet weak var seeAllLabel: UILabel!
    @IBOutlet weak var seeAllParentView: UIView!
    var isExpanded = false
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var size: CGSize {
        let aspectRatio = 328.0/38.0
        let width = SCREEN_WIDTH-32
        let height = width/aspectRatio
        return CGSize(width: width, height: height)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        seeAllParentView.setClickListener { [weak self]  in
            guard let self = self else {return}
            self.onSeeAllClick()
        }
    }
}
