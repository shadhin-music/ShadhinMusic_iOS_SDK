//
//  CommentHeaderCell.swift
//  Shadhin
//
//  Created by Rezwan on 6/10/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class CommentHeaderCell: UITableViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var height: CGFloat {
        return 112
    }

    
    @IBOutlet weak var totalCommentsLabel: UILabel!
    @IBOutlet weak var commentRefreshBtn: UIButton!
    @IBOutlet weak var addCommentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
