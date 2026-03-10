//
//  GenreAndFeaturePlaylistCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/10/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class GenreAndFeaturePlaylistCell: UICollectionViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var sizePlayList: CGSize {
        return CGSize(width: 120, height: 120)
    }
    
    static var sizePDPS: CGSize {
        //return CGSize(width: 164 * 1.78, height: 164)
        return CGSize(width: 164, height: 164)
    }

    @IBOutlet weak var genreAndFeaturePlaylistImgView: UIImageView!

    
    func configureCell(model: CommonContent_V0) {
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        genreAndFeaturePlaylistImgView.kf.indicatorType = .activity
        genreAndFeaturePlaylistImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_playlist",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
    }

    func configureCellPD(model: CommonContent_V0) {
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        genreAndFeaturePlaylistImgView.kf.indicatorType = .activity
        genreAndFeaturePlaylistImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_playlist",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
    }

}
