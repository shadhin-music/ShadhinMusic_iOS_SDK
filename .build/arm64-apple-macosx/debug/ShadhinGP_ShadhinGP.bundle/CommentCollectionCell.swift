//
//  CommentCollectionCell.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 10/6/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class CommentCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var reactionBtn: UIButton!
    @IBOutlet weak var proPicImg: UIImageView!
    @IBOutlet weak var replybtnAlwasy: UIButton!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    var isReactionEnable: Bool = false
    @IBOutlet weak var reactionCountLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet var starImages: [UIImageView]!
    var onTap: (() -> Void)?
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static func size(textHeight: CGFloat) -> CGSize {
        let aspectRatio = 328.0/(223.0 - 110.0)
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
        reactionBtn.setClickListener {
            self.onTap?()
        }
        // if player open from audiobook this view is enblem
        // else everything is normal
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
            if index < rating { // Filled stars for indexes less than the rating
                let filledImage = UIImage(named: "star-filled-blue",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                let templateImage = filledImage?.withRenderingMode(
                    .alwaysOriginal)
                imageView.image = templateImage
                imageView.tintColor = UIColor.systemYellow // Example color for filled stars
            } else { // Empty stars for indexes greater than or equal to the rating
                let emptyImage = UIImage(named: "star-empty",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                let templateImage = emptyImage?.withRenderingMode(.alwaysTemplate)
                imageView.image = templateImage
                imageView.tintColor = UIColor.primaryBlack
            }
        }
    }
}
extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 30 * day
        let year = 365 * day
        
        let quotient: Int
        let unit: String
        
        if secondsAgo < minute {
            return "Just now" // Skip seconds entirely
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "minute"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "hour"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "day"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "week"
        } else if secondsAgo < year {
            quotient = secondsAgo / month
            unit = "month"
        } else {
            quotient = secondsAgo / year
            unit = "year"
        }
        
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "s") ago"
    }
}


extension String {
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.date(from: self)
    }
}
extension String {
    func toDateReplies() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.date(from: self)
    }
}

