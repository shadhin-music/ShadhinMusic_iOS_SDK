//
//  DiscoverBillboardCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/10/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class DiscoverBillboardCell: UICollectionViewCell {

    @IBOutlet weak var discoverImgView: UIImageView!
    
    
    func configureCell(model: CommonContent_V0) {
        let imgUrl = model.newBannerImg ?? model.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        discoverImgView.kf.indicatorType = .activity
        discoverImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_billboard",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
    }

}
