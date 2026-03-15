//
//  ReviewCell.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 9/6/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class ReviewCell: UICollectionViewCell {
    
    @IBOutlet weak var totalRatings: UILabel!
    @IBOutlet weak var averageRating: UILabel!
    @IBOutlet weak var reviewView: UIView!
    var reviws: AudioBookReview?
    weak var audioVC: AudioBookDetailsVC!
    weak var reviewvC: ReviewPopUpVC!
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var size: CGSize {
        let aspectRatio = 360.0/90.0
        let width = SCREEN_WIDTH
        let height = width/aspectRatio
        return CGSize(width: width, height: height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reviewView.layer.borderColor  = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        reviewView.layer.borderWidth = 1
        reviewView.setClickListener {
            if ConnectionManager.shared.isNetworkAvailable {
                if ShadhinCore.instance.isUserLoggedIn && ShadhinCore.instance.isUserPro {
                    self.showReviewVC()
                } else if !ShadhinCore.instance.isUserPro {
                    SubscriptionPopUpVC.show(self.audioVC)
                }
            }
        }
    }
    
    func bindData(data: ReviewRatingCount) {
        totalRatings.text = "(\(String(data.reviewCount ?? 0)))"
        averageRating.text = String(data.ratingAverage ?? 0)
    }
    func bindDataNoRevies() {
        totalRatings.text = "(0)"
        averageRating.text = "Not Enough Ratings"
    }
     func showReviewVC() {
             let vc =  AddABookReviewVC()
             vc.reviews = reviws
             vc.reviewVC = reviewvC
             vc.vc = audioVC
             let height: CGFloat = 350.0
             var attributes = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 8)
             attributes.entryBackground = .color(color: .clear)
             attributes.border = .none
        
             let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 16, screenEdgeResistance: 20)
             let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
             attributes.positionConstraints.keyboardRelation = keyboardRelation
             SwiftEntryKit.dismiss()
             SwiftEntryKit.display(entry: vc, using: attributes)
    }

}
