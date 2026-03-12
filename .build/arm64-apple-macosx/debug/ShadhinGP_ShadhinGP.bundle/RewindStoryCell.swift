//
//  RewindStoryCell.swift
//  Shadhin
//
//  Created by Maruf on 27/12/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class RewindStoryCell: UITableViewCell {
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var HEIGHT : CGFloat{
        let h = (SCREEN_WIDTH - 32) * 184 / 328
        return h
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
