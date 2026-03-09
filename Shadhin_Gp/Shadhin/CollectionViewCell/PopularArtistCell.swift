//
//  PopularArtistCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/10/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class PopularArtistCell: UICollectionViewCell {
    
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size: CGSize {
        return CGSize(width: 120, height: 166)
    }
    

    @IBOutlet weak var artistImgView: UIImageView!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var artistNameLbl: UILabel!
    
    func configureCell(model: CommonContentProtocol) {
        artistNameLbl.text = model.artist ?? ""
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        artistImgView.kf.indicatorType = .activity
        artistImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_artist",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
    }

    @IBAction func followAction(_ sender: Any) {
        
    }
}
