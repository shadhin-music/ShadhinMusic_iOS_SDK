//
//  AuthorCell.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 26/6/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class AuthorAndNarratorCell: UICollectionViewCell {
    
    @IBOutlet weak var numberOfBooks: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    weak var vc: AudioBookDetailsVC?
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var size: CGSize {
        let aspectRatio = 295.0/48.0
        let width = SCREEN_WIDTH - 64.0
        let height = width / aspectRatio
        return CGSize(width: width, height: height)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bindAuthorList(authors: [Author]) {
        let authorsBookCount = authors.reduce(0) { $0 + ($1.booksCount ?? 0)}
        numberOfBooks.text = "\(authorsBookCount) audiobook\(authorsBookCount > 1 ? "s" : "")"
       // numberOfBooks.text = "\(authors.booksCount ?? 0) audiobooks"
        if let imageURL = URL(string: authors.first?.image?.image300 ?? "") {
            imageView.kf.setImage(with: imageURL)
        }
        name.text = authors.compactMap({$0.name}).joined(separator: " ")
    }
    
    func bindNarratorList(narrators:[Narrator]) {
        let authorsBookCount = narrators.reduce(0) { $0 + ($1.booksCount ?? 0)}
        numberOfBooks.text = "\(authorsBookCount) audiobook\(authorsBookCount > 1 ? "s" : "")"
       // numberOfBooks.text = "\(authors.booksCount ?? 0) audiobooks"
        if let imageURL = URL(string: narrators.first?.image?.image300 ?? "") {
            imageView.kf.setImage(with: imageURL)
        }
        name.text = narrators.compactMap({$0.name}).joined(separator: " ")
    }
}
