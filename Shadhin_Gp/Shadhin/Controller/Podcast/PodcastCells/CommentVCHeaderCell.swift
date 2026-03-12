//
//  CommentVCHeaderCell.swift
//  Shadhin
//
//  Created by Rezwan on 6/14/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class CommentVCHeaderCell: UITableViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var height: CGFloat {
        return 56
    }
    
    @IBOutlet weak var _title: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
