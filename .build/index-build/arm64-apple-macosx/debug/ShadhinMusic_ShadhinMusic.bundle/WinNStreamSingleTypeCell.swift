//
//  WinNStreamSingleTypeCell.swift
//  Shadhin
//
//  Created by Joy on 22/2/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class WinNStreamSingleTypeCell: UICollectionViewCell {
    
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    @IBOutlet weak var robiLogoIV: UIImageView!
    @IBOutlet weak var logoIV: UIImageView!
    
    @IBOutlet weak var rightArrowIV: UIImageView!
    @IBOutlet weak var particpateORLeaderboardLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var pORlButton: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func bind(with payment : PaymentMethod,obj : ParticipentObj?,isLeaderboard : Bool){
        guard let obj = obj else {return}
        if isLeaderboard{
            robiLogoIV.isHidden = true
        }else{
            if let type = PaymentGetwayType(rawValue: payment.name.uppercased()), type == .ROBI{
                robiLogoIV.isHidden = false
            }else{
                robiLogoIV.isHidden = true
            }
            
        }
        logoIV.image = obj.icon.uiImage
        titleLabel.text = obj.title
        subtitleLabel.text = obj.subtitle
        particpateORLeaderboardLabel.text = obj.buttonTitle
        
        particpateORLeaderboardLabel.textColor = obj.tintColor
        rightArrowIV.tintColor = obj.tintColor
        pORlButton.borderColor = obj.tintColor
        
    }
}
