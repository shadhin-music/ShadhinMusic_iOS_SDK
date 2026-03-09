//
//  ReviewCommentCell.swift
//  Shadhin
//
//  Created by Maruf on 17/11/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class ReviewCommentCell: UICollectionViewCell {
    
    @IBOutlet weak var likeBtn: UILabel!
    @IBOutlet weak var reactionBtn: UIButton!
    @IBOutlet weak var replybtnAlwasy: UIButton!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    var isReactionEnable: Bool = false
    @IBOutlet weak var reactionCountLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var proPicImg: UIImageView!
    @IBOutlet var starImages: [UIImageView]!
    
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static func size(textHeight: CGFloat) -> CGSize {
        let aspectRatio = 328.0/(223.0 - 120.0)
        let width = SCREEN_WIDTH
        let height = width/aspectRatio + textHeight
        return CGSize(width: width, height: height)
    }
    static func sizeForNoReplies() -> CGSize {
        let aspectRatio = 328.0/100.0
        let width = SCREEN_WIDTH
        let height = width/aspectRatio
        return CGSize(width: width, height: height)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func bindData(data: AudioBookReview) {
        reviewLabel.text = data.description
        userNameLabel.text = data.fullName
        timeLabel.text = data.createdDate?.toDate()?.timeAgoDisplay()
        drawRating(rating: Int(data.rating ?? 0.0))
        reactionCountLabel.text = String(data.reactionCount ?? 0)
        
        if (data.replyCount ?? 0) > 0 {
            replyButton.isHidden = false
            replyButton.setTitle("(\(data.replyCount ?? 0)) replies", for: .normal)
            
        } else {
            replyButton.isHidden = true
        }
    }
    func drawRating(rating: Int) {
        for (index, imageView) in starImages.enumerated() {
            if index > rating-1 {
                let originalImage = UIImage(named: "star-empty",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                let templateImage = originalImage?.withRenderingMode(.alwaysTemplate)
                imageView.image = templateImage
                imageView.tintColor = UIColor.primaryBlack
            }
        }
    }
    
}
