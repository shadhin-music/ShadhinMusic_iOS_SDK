//
//  NarratorMultipleImgCell.swift
//  Shadhin
//
//  Created by Maruf on 20/10/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class NarratorMultipleImgCell: UICollectionViewCell {
    @IBOutlet var narratorImg: [UIImageView]!
    @IBOutlet weak var narratorsBookCountLbl: UILabel!
    @IBOutlet weak var narratorLbl: UILabel!
    @IBOutlet weak var bgView: UIView!
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var size: CGSize {
        //let aspectRatio = 360.0/140.0
        let width = SCREEN_WIDTH
        let height = 90.0
        return CGSize(width: width, height: height)
    }
    static var sizeNoNarrtor: CGSize {
        //let aspectRatio = 360.0/140.0
        let width = SCREEN_WIDTH
        let height = 10.0
        return CGSize(width: width, height: height)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12)

    }
    override func awakeFromNib() {
        super.awakeFromNib()
        for imageView in narratorImg {
            imageView.layer.cornerRadius = imageView.frame.size.width / 2 // Example for circular images
            imageView.clipsToBounds = true // Ensure the corners are clipped
        }
        // Initialization code
    }
    func narratorsBindData(narrators: [Narrator]) {
        narratorLbl.text = narrators.compactMap({$0.name}).joined(separator: ", ")
        ///authors book count
        let narratorBookCount = narrators.reduce(0) { $0 + ($1.booksCount ?? 0)}
        narratorsBookCountLbl.text = "\(narratorBookCount) audiobook\(narratorBookCount > 1 ? "s" : "")"
        narratorPopulateImages(narrators: narrators)
    }
    func narratorPopulateImages(narrators: [Narrator]) {
        // Populate author images
        for (index, imageView) in narratorImg.prefix(3).enumerated() {
            if index < narrators.count, let imageUrl = URL(string: (narrators[index].image ?? "").image300) {
                imageView.kf.setImage(with: imageUrl)
                // Check if more than 3 authors exist and add a plus overlay to the last image view
                if index == 0 && narrators.count > 3 {
                    addPlusOverlay(to: imageView, totalItem: narrators.count)
                } else {
                    removePlusOverlay(from: imageView)
                }
            } else {
                imageView.image = nil // Clear the image if no more authors
            }
        }
    }
    
    func addPlusOverlay(to imageView: UIImageView, totalItem: Int) {
        let plusLabel = UILabel()
        plusLabel.text = "+\(totalItem - 3)"
        plusLabel.textColor = .white
        plusLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        plusLabel.textAlignment = .center
        plusLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        plusLabel.frame = imageView.bounds
        imageView.addSubview(plusLabel)
    }
    
    func removePlusOverlay(from imageView: UIImageView) {
        for subview in imageView.subviews {
            if subview is UILabel {
                subview.removeFromSuperview()
            }
        }
    }
}
