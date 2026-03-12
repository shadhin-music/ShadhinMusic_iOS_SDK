//
//  WinNStreamTypeCell.swift
//  Shadhin
//
//  Created by Joy on 22/2/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class WinNStreamTypeCell: UICollectionViewCell {

    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var practiceLabel: UILabel!
    @IBOutlet weak var rightArrowIV: UIImageView!
    @IBOutlet weak var participateButton: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bind(with obj : ParticipentObj?){
        guard let obj = obj else {return}
        iconIV.image = obj.icon.uiImage
        titleLabel.text = obj.title
        subtitleLabel.text = obj.subtitle
        
        practiceLabel.textColor = obj.tintColor
        rightArrowIV.tintColor = obj.tintColor
        participateButton.borderColor = obj.tintColor
    }

}
