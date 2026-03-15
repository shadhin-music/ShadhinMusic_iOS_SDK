//
//  MoreMenuMusciV4Cell.swift
//  Shadhin
//
//  Created by Joy on 15/3/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class MoreMenuMusciV4Cell: UITableViewCell {
    
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }

    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
