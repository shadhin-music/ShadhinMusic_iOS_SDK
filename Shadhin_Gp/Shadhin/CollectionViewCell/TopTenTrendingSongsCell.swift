//
//  TopTenTrendingSongsCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 1/16/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class TopTenTrendingSongsCell: UICollectionViewCell {

    @IBOutlet weak var trendingSongsImgView: UIImageView!
    @IBOutlet weak var trendingSongsNameLbl: UILabel!
    @IBOutlet weak var trendingSongsArtistLbl: UILabel!
    @IBOutlet weak var trendingPlayedCountLbl: UILabel!
    @IBOutlet weak var trendingRankingLbl: UILabel!
    
    func configureCell(model: CommonContent_V0) {
        trendingSongsNameLbl.text = model.title ?? ""
        trendingSongsArtistLbl.text = model.artist ?? ""
        trendingPlayedCountLbl.text = "\(model.totalStream ?? "0") Plays"
        
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        trendingSongsImgView.kf.indicatorType = .activity
        trendingSongsImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        
    }

}
