//
//  MusicCatagoryCollectionViewCell.swift
//  Shadhin
//
//  Created by Maruf on 7/2/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit


class GenreCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var playListTitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func bindData(data:NewSearchPlaylist) {
        let imgUrlString = data.imageUrl.replacingOccurrences(of: "<$size$>", with: "300")
        let imgUrl = URL(string: imgUrlString)
        imageView.kf.setImage(with: imgUrl)
        playListTitleLabel.text = data.title
    }
}
