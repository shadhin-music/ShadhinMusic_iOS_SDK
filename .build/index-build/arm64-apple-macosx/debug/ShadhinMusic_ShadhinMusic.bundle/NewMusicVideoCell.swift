//
//  NewMusicVideoCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/10/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class NewMusicVideoCell: UICollectionViewCell {

    @IBOutlet weak var musicVideoImgView: UIImageView!
    @IBOutlet weak var musicVideoTitleLbl: UILabel!
    @IBOutlet weak var musicVideoArtistLbl: UILabel!
    
    @IBOutlet weak var playBtn: UIImageView!
    @IBOutlet weak var threeDotBtn: UIButton!
    
    private var threeDotMenuClick: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        musicVideoTitleLbl.textColor = .customLabelColor(color: #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1))
        
        playBtn.isHidden = true
        threeDotBtn.isHidden = true
        
    }
    
    func configureCell(model: CommonContentProtocol) {
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "1280") ?? ""
        musicVideoImgView.kf.indicatorType = .activity
        musicVideoImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_video",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)) { result in
            self.playBtn.isHidden = false
        }
//        musicVideoImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_video"),options: SDWebImageOptions(rawValue: 0), completed: { image, error, cacheType, imageURL in
//            self.playBtn.isHidden = false
//        })
        musicVideoTitleLbl.text = model.title ?? ""
        musicVideoArtistLbl.text = model.artist ?? ""
    }

    @IBAction func threeDotMenuAction(_ sender: Any) {
        threeDotMenuClick?()
    }
    
    func didThreeDotMenuTapped(completion: @escaping (()->())) {
        threeDotMenuClick = completion
    }
}
