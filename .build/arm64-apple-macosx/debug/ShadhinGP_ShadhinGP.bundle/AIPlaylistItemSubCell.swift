//
//  AIPlaylistItemSubCell.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 14/5/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit


class AIPlaylistItemSubCell: UICollectionViewCell {
    
    static var identifier : String{
        return String(describing: self)
    }
    
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var musicNameLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var size : CGSize{
        return .init(width:136, height: 180)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bind(data: NewContent){
        musicNameLabel.text = data.titleEn
        artistNameLabel.text = data.artists.first?.name
        let url = URL(string: data.imageUrl)
        image.kf.setImage(with: url)
    }

}
