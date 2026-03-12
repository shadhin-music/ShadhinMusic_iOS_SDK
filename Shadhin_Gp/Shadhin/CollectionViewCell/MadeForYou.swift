//
//  PopularArtistCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/10/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class MadeForYou: UICollectionViewCell {
    
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size: CGSize {
        return CGSize(width: 218, height: 246)
    }
    

    @IBOutlet weak var Overlay: UIImageView!
    @IBOutlet weak var artistImgView: UIImageView!
    @IBOutlet weak var artistNameLbl: UILabel!
    
    func configureCell(model: CommonContentProtocol) {
        artistNameLbl.text = model.title ?? ""
        Overlay.isHidden = true
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        artistImgView.kf.indicatorType = .activity
        artistImgView.kf.setImage(with: URL(string: imgUrl),placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func initZeroCell(){
        if ShadhinCore.instance.defaults.userProPicUrl.isEmpty{
            artistImgView.image = #imageLiteral(resourceName: "made_for_you_default")
        }else{
            Overlay.isHidden = false
            artistImgView.kf.indicatorType = .activity
            artistImgView.kf.setImage(with: URL(string: ShadhinCore.instance.defaults.userProPicUrl.safeUrl()),placeholder: UIImage(named: "default_artist",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        }
        artistNameLbl.text = ""
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(initZeroCell), name: .facebookProfileUpdated, object: nil)
    }

    
}
