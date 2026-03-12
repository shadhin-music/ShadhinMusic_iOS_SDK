//
//  CampaignDetailsCell.swift
//  Shadhin
//
//  Created by Joy on 20/2/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class CampaignDetailsCell: UICollectionViewCell {
    
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var HEIGHT : CGFloat {
        return 50
    }
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.cornerRadius = 8
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 1, height: 2)
        
    }
    

}
