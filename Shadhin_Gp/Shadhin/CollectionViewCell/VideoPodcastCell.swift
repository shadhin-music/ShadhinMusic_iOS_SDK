//
//  VideoPodcastCell.swift
//  Shadhin
//
//  Created by Gakk Alpha on 4/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class VideoPodcastCell: UICollectionViewCell {
    
    static var size: CGSize {
        return CGSize(width: 290, height: 210)
    }
    
    @IBOutlet weak var trendingVideoImgView: UIImageView!
    @IBOutlet weak var mTitle: UILabel!
    
    func configureCell(model: CommonContent_V0) {
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "1280") ?? ""
        trendingVideoImgView.kf.indicatorType = .activity
        trendingVideoImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_video",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        mTitle.text = model.title
    }
    
}
