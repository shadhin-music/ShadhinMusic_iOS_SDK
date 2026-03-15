//
//  PrizeCell.swift
//  Shadhin
//
//  Created by Joy on 22/2/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class PrizeCell: UICollectionViewCell {

    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    @IBOutlet weak var shadowView: UIView!
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var prizeIV: UIImageView!
    
    @IBOutlet weak var prizeTitleLabel: UILabel!
    @IBOutlet weak var prizeSubtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 12
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 1, height: 2)
        
        shadowView.layer.cornerRadius = 12
        shadowView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.03).cgColor
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowRadius = 2
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        self.prizeIV.borderWidth = 1
        self.prizeIV.borderColor = .gray.withAlphaComponent(0.5)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.prizeIV.cornerRadius = self.prizeIV.width / 2
    }
    
    func bind(with obj : Prize?) {
        guard let obj = obj else {return}
        self.prizeTitleLabel.text = obj.title
        self.prizeSubtitleLabel.text = obj.description
        self.prizeIV.kf.setImage(with: URL(string: obj.imageUrl))
        
    }
}
