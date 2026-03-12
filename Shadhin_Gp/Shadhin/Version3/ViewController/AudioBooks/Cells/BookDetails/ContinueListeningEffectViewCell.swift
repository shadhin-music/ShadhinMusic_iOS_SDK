//
//  ContinueListeningEffectViewCell.swift
//  Shadhin
//
//  Created by Maruf on 29/10/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class ContinueListeningEffectViewCell: UICollectionViewCell {

    @IBOutlet weak var progressView: CustomProgressView!
    @IBOutlet weak var percentageBgView: UIView!
   // @IBOutlet weak var percentageImg: UIImageView!
    @IBOutlet weak var percentageLbl: UILabel!
    @IBOutlet weak var reviewCountLbl: UILabel!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var bookSubTitleLbl: UILabel!
    @IBOutlet weak var bookTitleLbl: UILabel!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var blurImgView: UIImageView!
    @IBOutlet weak var listeningBookImgView: UIImageView!
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var size: CGSize {
        let aspectRatio = 360.0/270.0
        let width = (SCREEN_WIDTH - 32)/1.15
        let height = width/aspectRatio
        return CGSize(width: width, height: height)
    }

    static var sizeSeeAll: CGSize {
        let aspectRatio = 180.0 / 328.0
        let horizontalSpacing: CGFloat = 0 // No space on sides if full width
        let width = SCREEN_WIDTH - (2 * horizontalSpacing) // Adjust for side padding if needed
        let height = width / aspectRatio
        return CGSize(width: width, height: height)
    }
  
    override func layoutSubviews() {
        super.layoutSubviews()
        listeningBookImgView.layer.cornerRadius = 12 // Adjust the corner radius aneeded
        listeningBookImgView.clipsToBounds = true
        percentageBgView.layer.cornerRadius = 12
        visualEffectView.layer.cornerRadius = 12
        blurImgView.layer.cornerRadius = 12
    }
    override func awakeFromNib() {
        super.awakeFromNib()
       // bookbgView.cornerRadius = 6
        // Initialization code
    }
    private func updateProgressView(with percentage: Int) {
        progressView.setProgress(percentage: percentage)
    }
    func bindStreamingData(content:StreamingHistoryContent) {
        listeningBookImgView.layer.cornerRadius = 12 // Adjust the corner radius as needed
        listeningBookImgView.clipsToBounds = true // Ensures the image respects the corner radius
     //   listeningBookImgView.contentMode = .scaleAspectFill
        let url = URL(string: (content.imageUrl).image450)
        listeningBookImgView.kf.setImage(with: url)
        blurImgView.kf.setImage(with: url)
        bookTitleLbl.text = content.titleEn
        bookSubTitleLbl.text = content.audioBook.authors.first?.name
        ratingLbl.text = String(content.audioBook.rating)
        reviewCountLbl.text = "(\(content.audioBook.reviewsCount))"
        updateProgressView(with:content.audioBook.completionPercentage)
    }
}
