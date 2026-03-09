//
//  ShuffleAndDownloadTableViewCell.swift
//  Shadhin
//
//  Created by Joy on 24/9/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class ShuffleAndDownloadTableViewCell: UITableViewCell {
    @IBOutlet var  shuffleButton: UIButton!
    @IBOutlet var  downloadButton: UIButton!
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
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
