//
//  ChooseAPlanCell.swift
//  Shadhin
//
//  Created by Maruf on 14/2/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class ChooseAPlanCell: UICollectionViewCell {


    @IBOutlet weak var mostPopularView: UIView!
    
    @IBOutlet weak var planNameLabel: UILabel!
    
    @IBOutlet weak var planInPriceLabel: UILabel!
    @IBOutlet weak var durationInDaysLabel: UILabel!
    
    var isMostPopular = false
    
    static var SIZE : CGSize{
        let width = (SCREEN_WIDTH - 32)
        let height = (width * 124 / 328)
        return .init(width: width, height: height)
    }
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        mostPopularView.roundCorners([.bottomLeft, .bottomRight], radius: 6)
        // Initialization code
    }
    
    func bindData(data: Plan, index: Int) {
        planNameLabel.text = data.planName
        durationInDaysLabel.text = "/\(data.durationInDays) \(data.durationInDays>1 ? "days" : "day")"
        planInPriceLabel.text = "\(data.currencySymbol)\(data.items[index].planPrice)"
        isMostPopular = data.items.first?.isMostPopular == 1
        mostPopularView.layer.opacity = isMostPopular ? 1 : 0
    }

}
