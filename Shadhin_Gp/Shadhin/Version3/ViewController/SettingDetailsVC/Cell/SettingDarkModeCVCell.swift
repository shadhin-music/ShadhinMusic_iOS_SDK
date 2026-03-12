//
//  SettingDarkModeCVCell.swift
//  Shadhin_Gp
//
//  Created by MD Murad Hossain  on 14/10/25.
//

import UIKit

class SettingDarkModeCVCell: UICollectionViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var switchImgView: UIImageView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var imgviewHeight: NSLayoutConstraint!
    @IBOutlet weak var imgviewWidth: NSLayoutConstraint!
    @IBOutlet weak var imgViewTrailing: NSLayoutConstraint!
    
    override var isSelected: Bool {
        didSet {
            let img = isSelected ? "switch_select_icon" : "switch_unselect_icon"
            self.switchImgView.image = UIImage(named: img, in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
            self.switchImgView.tintColor = isSelected ? .appTint : .textColorSecoundery
            self.imgviewHeight.constant = isSelected ? 28 : 24
            self.imgviewWidth.constant = isSelected ? 28 : 24
            self.imgViewTrailing.constant = isSelected ? 12.5 : 15
        }
    }
    
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib {
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func dataBindCell(data: DarkModeData) {
        self.titleLabel.text = data.title
        self.subTitleLabel.text = data.subTitle
        self.subTitleLabel.isHidden = !data.isSystemMode
        self.lineView.isHidden = data.isSystemMode
    }
}
