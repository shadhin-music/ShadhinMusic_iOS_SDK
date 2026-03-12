//
//  SettingSubDetailsTVCell.swift
//  Shadhin_Gp
//
//  Created by MD Murad Hossain  on 5/11/25.
//

import UIKit

class SettingSubDetailsTVCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView! {
        didSet {
            self.bgView.layer.cornerRadius = 12
        }
    }
    @IBOutlet weak var textLbl: UILabel!
    
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib {
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func dataBindCell(_ data: FAQSubCategory) {
        self.selectionStyle = .none
        if ShadhinCore.instance.isBangla {
            self.textLbl.text = data.titleBn
        } else {
            self.textLbl.text = data.titleEn
        }
    }
}
