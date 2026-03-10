//
//  PaymentOptionCell.swift
//  Shadhin
//
//  Created by Maruf on 14/2/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit


class PaymentOptionCell: UICollectionViewCell {

    @IBOutlet weak var paymentMethodImage: UIImageView!
    @IBOutlet weak var paymentType: UILabel!
    @IBOutlet weak var paymentMethodName: UILabel!
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bind(data: Item) {
        paymentMethodName.text = data.operatorName
        let imageUrl = URL(string: data.icon ?? "")
        paymentMethodImage.kf.setImage(with: imageUrl)
        paymentType.text = data.subscriptionType == "subscription" ? "Auto-renewal" : "One-time"
    }

}
