//
//  HelpCenterCVCell.swift
//  Shadhin_Gp
//
//  Created by MD Murad Hossain  on 16/10/25.
//

import UIKit

class HelpCenterCVCell: UICollectionViewCell {
    
    @IBOutlet weak var bgView: UIView! {
        didSet {
            self.bgView.layer.cornerRadius = 12
        }
    }
    @IBOutlet weak var messengerBtn: UIButton!
    @IBOutlet weak var emailBtn: UIButton!
    
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib {
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    var sendMessengerClick: (() ->Void)?
    var sendEmailClick: (() ->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func messengerBtnAction(_ sender: UIButton) {
        self.sendMessengerClick?()
    }
    
    @IBAction func emailBtnAction(_ sender: UIButton) {
        self.sendEmailClick?()
    }
    
}
