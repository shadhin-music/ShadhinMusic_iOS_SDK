//
//  AuthorDetailsHeaderCell.swift
//  Shadhin
//
//  Created by Maruf on 17/10/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class AuthorDetailsHeaderCell: UICollectionViewCell {
    var followTapped: (() -> Void)?
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var bookCountLbl: UILabel!
    @IBOutlet weak var bookNameLbl: UILabel!
    @IBOutlet weak var followersCountLbl: UILabel!
    @IBOutlet weak var aboutAuthorAndNarratorLbl: UILabel!
    @IBOutlet weak var blurImg: UIImageView!
    @IBOutlet weak var readmoreView: UIStackView!
    @IBOutlet weak var summaryLbl: UILabel!
    @IBOutlet weak var readMoreIcon: UIImageView!
    @IBOutlet weak var readMoreLbl: UILabel!
    @IBOutlet weak var summeryHeight: NSLayoutConstraint!
    @IBOutlet weak var followImgView: UIImageView!
    @IBOutlet weak var dotView: UIView!
    static var isExpanded = false
    var isAuhtorOrNarrator = false
    var isFollow = false
    var onItemCliked:()->Void  = {}
    unowned var vc: AuthorAndNarratorDetailsVC?
    var dismiss: ()-> Void = {}
    static var extraHeight = 0.0
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        viewSetup()
        readmoreView.setClickListener { [weak self] in 
            self?.resizeReadMore()
        }
        followBtn.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)
    }
    
    @objc private func didTapFollowButton() {
        followTapped?() // Call the closure
    }
    
    private func viewSetup(){
        dotView.layer.cornerRadius = 3
        followImgView.layer.cornerRadius = 172/2
       // followImgView.backgroundColor = .gray
     
    }
    
    func dataBindAuthor(authors: AuthorDetailsParentContent) {
        let url = URL(string: (authors.audioBook.authors.first?.image ?? "").image300)
        blurImg.kf.setImage(with: url)
        followImgView.kf.setImage(with: url)
        aboutAuthorAndNarratorLbl.text = "About Author"
        
        // Get total book count from narrators
        let bookCount = authors.audioBook.authors.compactMap { $0.booksCount }.reduce(0, +)
        bookCountLbl.text = "\(bookCount) AudioBooks"
        
        bookNameLbl.text = authors.audioBook.authors.compactMap({ $0.name }).joined(separator: " ")
        summaryLbl.text = authors.details
        followersCountLbl.text = "\(authors.likeCount) Followers"
    }

    
    func dataBindNarrator(narrators: AuthorDetailsParentContent) {
        let url = URL(string: (narrators.audioBook.narrators?.first?.image ?? "").image300)
        blurImg.kf.setImage(with: url)
        followImgView.kf.setImage(with: url)
        aboutAuthorAndNarratorLbl.text = "About Narrator"
        
        // Get total book count from all narrators
        let bookCount = narrators.audioBook.narrators?.compactMap { $0.booksCount }.reduce(0, +) ?? 0
        bookCountLbl.text = "\(bookCount) AudioBooks"
        bookNameLbl.text = narrators.audioBook.narrators?
            .compactMap({ $0.name })
            .joined(separator: " ")
        summaryLbl.text = narrators.details
        
        print("\(narrators.details)")
        
        followersCountLbl.text = "\(narrators.likeCount) Followers"
    }

    
    static var size: CGSize {
        let aspectRatio = 360.0 / 455.0
        let width = SCREEN_WIDTH
        let height = width / aspectRatio
        return CGSize(width: width, height: height)
    }

    static var sizeExpanded: CGSize {
        let aspectRatio = 360.0 / 480.0
        let width = SCREEN_WIDTH
        let baseHeight = width / aspectRatio
        let height = baseHeight + extraHeight - 30
        return CGSize(width: width, height: height)
    }

    private func resizeReadMore(){
        AuthorDetailsHeaderCell.isExpanded.toggle()
        if AuthorDetailsHeaderCell.isExpanded {
            AuthorDetailsHeaderCell.extraHeight = getHeightOfSummary()
            vc?.isSummaryExpanded = true
            vc?.collectionView.reloadSections(.init(arrayLiteral: 0))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                self.summeryHeight.constant = AuthorDetailsHeaderCell.extraHeight
                self.summeryHeight.isActive = true
                self.readMoreLbl.text = "Read Less"
                self.readMoreIcon.transform = self.readMoreIcon.transform.rotated(by: .pi)
                self.vc?.collectionView.reloadSections(.init(arrayLiteral: 0))
            })
        }else {
            vc?.isSummaryExpanded = false
            vc?.collectionView.reloadSections(.init(arrayLiteral: 0))
            self.summeryHeight.constant = 35
            self.summeryHeight.isActive = true
            self.readMoreLbl.text = "Read More"
            self.readMoreIcon.transform = self.readMoreIcon.transform.rotated(by: .pi)
                
        }
    }
    
    func getHeightOfSummary()->CGFloat {
        let attributedString = NSAttributedString(
            string: summaryLbl.text ?? "",
            attributes: [
                .font: UIFont(name: "OpenSans-Regular", size: 12.0)!, // Customize your font and other attributes here
                .foregroundColor: UIColor.black // Customize your color and other attributes here
            ]
        )
        
        // Step 2: Define the maximum width
        let maxWidth = CGFloat(SCREEN_WIDTH - 32) // Set the width of your container

        // Step 3: Calculate the bounding rect
        let size = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let boundingRect = attributedString.boundingRect(with: size, options: options, context: nil)

        // The height of the bounding rect is the height needed to display the attributed string
        return ceil(boundingRect.height)
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss()
    }
}
