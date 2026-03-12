//
//  RepliesCell.swift
//  Shadhin
//
//  Created by Maruf on 3/11/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class RepliesCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet var reviewImgCount: [UIImageView]!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var proPicImgView: UIImageView!
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var size: CGSize {
        let aspectRatio = 328.0/85.0
        let width = SCREEN_WIDTH - 64
        let height = width/aspectRatio
        return CGSize(width: width, height: height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func dataBind(data:Reply) {
        userNameLbl.text = data.fullName
        descriptionLbl.text = data.description
        timeLbl.text = data.createdDate.toDate()?.timeAgoDisplay()
    }
     func drawRating(rating: Int) {
        for (index, imageView) in reviewImgCount.enumerated() {
            if index > rating-1 {
                let originalImage = UIImage(named: "star-empty",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                let templateImage = originalImage?.withRenderingMode(.alwaysTemplate)
                imageView.image = templateImage
                imageView.tintColor = UIColor.primaryBlack
            }
        }
    }
}
