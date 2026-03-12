//
//  AuthorMultipleImgCell.swift
//  Shadhin
//
//  Created by Maruf on 20/10/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class AuthorMultipleImgCell: UICollectionViewCell {
    
    @IBOutlet weak var authorBookCountLbl: UILabel!
    @IBOutlet weak var authorLbl: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet var authorImg: [UIImageView]!
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
        let width = 0.0
        let height = 0.0
        return CGSize(width: width, height: height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.roundCorners(corners: [.topLeft, .topRight], radius: 12)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        for imageView in authorImg {
            imageView.layer.cornerRadius = imageView.frame.size.width / 2 // Example for circular images
            imageView.clipsToBounds = true // Ensure the corners are clipped
        }
        // bgView.layer.cornerRadius = 12
        // Initialization code
    }
    
    func authorsBindData(authors: [Author]) {
        authorLbl.text = authors.compactMap({$0.name}).joined(separator: ", ")
        ///authors book count
        let narratorBookCount = authors.reduce(0) { $0 + ($1.booksCount ?? 0)}
        authorBookCountLbl.text = "\(narratorBookCount) audiobook\(narratorBookCount > 1 ? "s" : "")"
        authorsPopulateImages(authors: authors)
    }
    func authorsPopulateImages(authors: [Author]) {
        // Populate author images
        for (index, imageView) in authorImg.prefix(3).enumerated() {
            if index < authors.count, let imageUrl = URL(string: (authors[index].image ?? "").image300) {
                imageView.kf.setImage(with: imageUrl)
                // Check if more than 3 authors exist and add a plus overlay to the last image view
                if index == 0 && authors.count > 3 {
                    addPlusOverlay(to: imageView, totalItem: authors.count)
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
