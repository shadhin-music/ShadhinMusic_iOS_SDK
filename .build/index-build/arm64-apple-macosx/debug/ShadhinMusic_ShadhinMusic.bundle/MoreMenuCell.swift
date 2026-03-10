//
//  MoreMenuCell.swift
//  Shadhin
//
//  Created by Joy on 13/7/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

struct MoreMenuModel {
    var title : String
    var icon : AppImage
    var type : MoreMenuItemType
}

class MoreMenuCell: UITableViewCell {
    //MARK: Create identifier name for cell
    static var identifier: String {
        return String(describing: self)
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ivIcon: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    //MARK: create nib for access this view
    static func nib()-> UINib{
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    func setDataWith(model obj: MoreMenuModel){
        titleLabel.text = obj.title
        ivIcon.image = obj.icon.uiImage
    }
}
