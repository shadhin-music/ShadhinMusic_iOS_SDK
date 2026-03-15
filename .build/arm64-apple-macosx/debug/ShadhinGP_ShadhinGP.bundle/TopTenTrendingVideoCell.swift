//
//  TopTenTrendingVideoCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 1/19/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class TopTenTrendingVideoCell: UICollectionViewCell {

    @IBOutlet weak var topTrendingVideoImgView: UIImageView!
    @IBOutlet weak var topTrendingVideoTitleLbl: UILabel!
    @IBOutlet weak var topTrendingVideoArtistNameLbl: UILabel!
    @IBOutlet weak var topTrendingVideoCountSteemLbl: UILabel!
    @IBOutlet weak var topTrendingVideoRankingLbl: UILabel!
    
    func configureCell(model: CommonContent_V0) {
        topTrendingVideoTitleLbl.text = model.title
        topTrendingVideoArtistNameLbl.text = model.artist
        topTrendingVideoCountSteemLbl.text = "\(model.totalStream ?? "0") \(model.totalStream == "1" ? "Play" : "Plays")"
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "1280") ?? ""
        topTrendingVideoImgView.kf.indicatorType = .activity
        topTrendingVideoImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_video",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
    }

}
