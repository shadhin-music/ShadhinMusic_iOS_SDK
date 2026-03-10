//
//  YouMightLikeCell.swift
//  Shadhin
//
//  Created by Maruf on 23/10/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class YouMightLikeSubCell: UICollectionViewCell {

    @IBOutlet weak var bookAmountLbl: UILabel!
    @IBOutlet weak var reviewCount: UILabel!
    @IBOutlet weak var bookNameLbl: UILabel!
    
    @IBOutlet weak var authorNameLbl: UILabel!
    @IBOutlet weak var image: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var size: CGSize {
        let aspectRatio = 136.0/272.0
        let width = (SCREEN_WIDTH - 32)/2.5
        let height = width/aspectRatio
        return CGSize(width: width, height: height)
    }
    static var sizeSeeAll: CGSize {
        let aspectRatio = 136.0 / 272.0
        let itemsPerRow: CGFloat = 2
        let horizontalSpacing: CGFloat = 10 // Space between columns
      //  let _: CGFloat = 10 // Space between rows
        let totalHorizontalSpacing = horizontalSpacing * (itemsPerRow - 1)
        let availableWidth = SCREEN_WIDTH - 48 - totalHorizontalSpacing
        let width = availableWidth / itemsPerRow
        let height = width / aspectRatio
        return CGSize(width: width, height: height)
    }
    func bindDataSimileData(content:SimilerBooksContent) {
        let url = URL(string: (content.imageUrl).image450)
        image.kf.setImage(with: url)
        image.layer.cornerRadius = 12
        bookNameLbl.text = content.titleEn
        authorNameLbl.text = content.genres.first?.name
        reviewCount.text = String(content.audioBook.rating)
        bookAmountLbl.text = "(\(content.audioBook.reviewsCount))"
    }
}
