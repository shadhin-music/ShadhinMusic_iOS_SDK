//
//  ChoosePlanCell.swift
//  Shadhin
//
//  Created by Maruf on 13/2/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class ChoosePlanCell: UICollectionViewCell {

    @IBOutlet weak var mostPopularView: UIView!
    
    @IBOutlet weak var planNameLabel: UILabel!
    
    @IBOutlet weak var durationInDaysLabel: UILabel!
    @IBOutlet weak var planInPriceLabel: UILabel!
    var isMostPopular = false
    
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mostPopularView.roundCorners([.bottomLeft, .bottomRight], radius: 6)
        
    }
    
    func bindData(data: Plan) {
        planNameLabel.text = data.planName
        durationInDaysLabel.text = "/\(data.durationInDays) \(data.durationInDays>1 ? "days" : "day")"
        planInPriceLabel.text = getPlanPrice(plan: data)
        isMostPopular = getIsPopular(plan: data)
        mostPopularView.isHidden = !isMostPopular
    }
    
    func getPlanPrice(plan: Plan)->String {
        "\(plan.currencySymbol)\((plan.items.first?.planPrice ?? 0.0).getPriceDecidingDecimalPart)"
    }
    
    func getIsPopular(plan: Plan) -> Bool {
        plan.items.first?.isMostPopular == 1
    }
    
}

extension Double {
    var getPriceDecidingDecimalPart: String {
        var result = ""
        let decimalPart:Double = self.truncatingRemainder(dividingBy: 1)
        if decimalPart == 0 {
            result = String(format: "%.0f", self)
        } else {
            result = String(format: "%.2f", self)
        }
        return result
    }
}

let apple = "ios"
let google = "google"
let stripe = "stripe"
