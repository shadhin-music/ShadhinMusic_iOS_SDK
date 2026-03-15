//
//  TrendingVideoCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/10/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class TrendingVideoCell: UICollectionViewCell {

    @IBOutlet weak var trendingVideoImgView: UIImageView!
    
    func configureCell(model: CommonContent_V0) {
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "1280") ?? ""
        trendingVideoImgView.kf.indicatorType = .activity
        trendingVideoImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_video",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
    }
    
}
