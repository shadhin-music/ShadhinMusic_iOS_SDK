//
//  AuthorsSubCell.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 9/6/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class AuthorsSubCell: UICollectionViewCell {
    
    @IBOutlet weak var naratorAudioBooksLabel: UILabel!
    @IBOutlet weak var naratorLabel: UILabel!
    @IBOutlet weak var audioBooksCountLabel: UILabel!
    @IBOutlet weak var authorsLabel: UILabel!
    
    @IBOutlet var authorImages: [UIImageView]!
    @IBOutlet var narattorImages: [UIImageView]!
    
    
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var size: CGSize {
        //let aspectRatio = 360.0/140.0
        let width = SCREEN_WIDTH
        let height = 160.0
        return CGSize(width: width, height: height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func bindData(authors: [Author], narattors: [Narrator]) {
        authorsLabel.text = authors.compactMap({$0.name}).joined(separator: ", ")
        naratorLabel.text = narattors.compactMap({$0.name}).joined(separator: ", ")
        ///authors book count
        let authorsBookCount = authors.reduce(0) { $0 + ($1.booksCount ?? 0)}
        let narratorsBookCount = narattors.reduce(0) { $0 + ($1.booksCount ?? 0)}
        audioBooksCountLabel.text = "\(authorsBookCount) audiobook\(authorsBookCount > 1 ? "s" : "")"
        naratorAudioBooksLabel.text = "\(narratorsBookCount) audiobook\(narratorsBookCount > 1 ? "s" : "")"
        populateImages(authors: authors, narrators: narattors)
    }
    
    func populateImages(authors: [Author], narrators: [Narrator]) {
        // Populate author images
        for (index, imageView) in authorImages.prefix(3).enumerated() {
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

        // Populate narrator images
        for (index, imageView) in narattorImages.prefix(3).enumerated() {
            if index < narrators.count, let imageUrl = URL(string: (narrators[index].image ?? "").image300) {
                imageView.kf.setImage(with: imageUrl)
                // Check if more than 3 narrators exist and add a plus overlay to the last image view
                if index == 0 && narrators.count > 3 {
                    addPlusOverlay(to: imageView, totalItem: narrators.count)
                } else {
                    removePlusOverlay(from: imageView)
                }
            } else {
                imageView.image = nil // Clear the image if no more narrators
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
