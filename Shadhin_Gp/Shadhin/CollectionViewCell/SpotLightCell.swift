//
//  SpotLightCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 10/24/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class SpotLightCell: UICollectionViewCell {

    @IBOutlet weak var imgView: UIImageView!
    
    func configureCell(model: CommonContent_V0) {
        let imgUrl = model.bannerImg?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        imgView.kf.indicatorType = .activity
        imgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: ""))
    }

}
