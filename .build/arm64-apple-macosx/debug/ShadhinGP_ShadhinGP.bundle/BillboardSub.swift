//
//  BillboardPagerCellV3.swift
//  Shadhin
//
//  Created by Maruf on 5/12/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit


class BillboardSub: FSPagerViewCell {
    
    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var billboarsSubLbl: UILabel!
    @IBOutlet weak var bilboardLblName: UILabel!
    @IBOutlet weak var billboardImage: UIImageView!
    @IBOutlet weak var videoHolder: UIView!
    @IBOutlet weak var muteButton: UIButton!
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
