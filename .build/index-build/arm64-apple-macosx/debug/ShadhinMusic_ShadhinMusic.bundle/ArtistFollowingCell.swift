//
//  ArtistFollowingCell.swift
//  Shadhin
//
//  Created by Gakk Alpha on 6/14/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class ArtistFollowingCell: UICollectionViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var unfollowBtn: UIButton!
    @IBOutlet weak var checkListWise: UIButton!
    @IBOutlet weak var checkGridWise: UIButton!
    
    
    
    func configureCell(model: CommonContentProtocol) {
        mainTitle.text = model.title ?? model.title ?? ""
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        mainImg.kf.indicatorType = .activity
        mainImg.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_artist",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
    }
    

}
