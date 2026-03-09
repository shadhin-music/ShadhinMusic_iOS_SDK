//
//  RadioCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/10/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class RadioCell: UICollectionViewCell {

    @IBOutlet weak var radioImgView: UIImageView!
    @IBOutlet weak var radioTitleLbl: UILabel!
    @IBOutlet weak var radioSongCountLbl: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        radioImgView.cornerRadius = radioImgView.bounds.height / 2
    }
    
    func configureCell(model: CommonContent_V0) {
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        radioImgView.kf.indicatorType = .activity
        radioImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_radio",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        radioTitleLbl.text = model.title ?? ""
        mainView.backgroundColor = .clear
    }
    
    func configureCell(model: CommonContentProtocol) {
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        radioImgView.kf.indicatorType = .activity
        radioImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_radio",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        radioTitleLbl.text = model.title ?? ""
        mainView.backgroundColor = .clear
    }

}
