//
//  BookSubCell.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 5/6/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit


class BookSubCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var bookNameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var bookAmountLabel: UILabel!

    static var identifier: String {
        String(describing: self)
    }
    var reviews = [AudioBookReview]()
    var averageReview: ReviewRatingCount?
    var authors: Author?
    var parentBook: ParentContent?

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
        let _: CGFloat = 10 // Space between rows
        let totalHorizontalSpacing = horizontalSpacing * (itemsPerRow - 1)
        let availableWidth = SCREEN_WIDTH - 48 - totalHorizontalSpacing
        let width = availableWidth / itemsPerRow
        let height = width / aspectRatio
        return CGSize(width: width, height: height)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func getAudioBookReviews(episodeId: String) {
        guard !episodeId.isEmpty else {return}
        ShadhinCore.instance.api.getAudioBookReviews(userCode: ShadhinCore.instance.defaults.userIdentity, episodeId: episodeId) {[weak self] responseModel in
            guard let self = self else {return}
            switch responseModel {
            case .success(let success):
                DispatchQueue.main.async {
                    self.reviews = success.data?.review ?? []
                    self.averageReview = success.data?.reviewRatingCount
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }

    func getAudioBookDetailsData(episodeId: String, indexPath: IndexPath) {
        guard !episodeId.isEmpty else { return }
        ShadhinCore.instance.api.getAudioBookData(episodeId: episodeId) { [weak self] responseModel in
            guard let self = self else { return }
            switch responseModel {
            case .success(let data):
                DispatchQueue.main.async {
                    self.authors = data.data?.contents?.first?.audioBook?.authors?.first
                    self.authorLabel.text = self.authors?.name
                }
            case .failure(let failure):
                print("Error fetching audiobook details: \(failure)")
            }
        }
    }

    func bindDataHomv3AudioBook(content: CommonContentProtocol) {
        if let imageUrl = content.image {
            let url = URL(string: imageUrl.image450)
            image.kf.setImage(with: url)
        }

        image.layer.cornerRadius = 12
        bookNameLabel.text = content.title

        if let rating = averageReview?.ratingAverage {
            ratingLabel.text = String(rating)
        } else {
            ratingLabel.text = "No Rating Yet"
        }
        if let bookCount = averageReview?.reviewCount {
            bookAmountLabel.text = "(\(bookCount))"
        } else {
            bookAmountLabel.text = ""
        }
    }

    func bindDataHomv3Recommended(contentV3: HomeV3Content) {
        if let imageUrl = contentV3.image {
            let url = URL(string: imageUrl.image450)
            image.kf.setImage(with: url)
        }

        image.layer.cornerRadius = 12
        bookNameLabel.text = contentV3.title

        if let rating = averageReview?.ratingAverage {
            ratingLabel.text = String(rating)
        } else {
            ratingLabel.text = "No Rating Yet"
        }
        if let bookCount = averageReview?.reviewCount {
            bookAmountLabel.text = "(\(bookCount))"
        } else {
            bookAmountLabel.text = ""
        }
    }

    func bindAuthorDetailsAudioBookData(content: AuthorDetailsContent){
        let url = URL(string: (content.imageUrl).image450)
        image.kf.setImage(with: url)
        image.layer.cornerRadius = 12
        bookNameLabel.text = content.titleEn
        authorLabel.text = content.titleEn
        ratingLabel.text = String(content.audioBook.rating)
        bookAmountLabel.text = "(\(content.audioBook.reviewsCount))"
    }
    func bindAudioCatagoriesData(content:AudioBookCatagoriesContent) {
        let url = URL(string: (content.imageUrl).image450)
        image.kf.setImage(with: url)
        image.layer.cornerRadius = 12
        bookNameLabel.text = content.titleEn
        authorLabel.text = content.titleEn
        ratingLabel.text = String(content.audioBook?.rating ?? 0.0)
        bookAmountLabel.text = "(\(content.audioBook?.reviewsCount ?? 0))"
    }
    func bindStreamingHistoryData(content:StreamingHistoryContent) {
        let url = URL(string: (content.imageUrl).image450)
        image.kf.setImage(with: url)
        image.layer.cornerRadius = 12
        bookNameLabel.text = content.titleEn
        authorLabel.text = content.titleEn
        ratingLabel.text = String(content.audioBook.rating)
        bookAmountLabel.text = "(\(content.audioBook.reviewsCount))"
    }
    func bindData(content: AudioPatchContent){
        let url = URL(string: (content.imageURL ?? "").image450)
        image.kf.setImage(with: url)
        image.layer.cornerRadius = 12
        bookNameLabel.text = content.titleEn
        authorLabel.text = content.genres.first?.name
        ratingLabel.text = String(content.audioBook.rating)
        bookAmountLabel.text = "(\(content.audioBook.reviewsCount))"

    }
    func bindDataSimileData(content:SimilerBooksContent) {
        let url = URL(string: (content.imageUrl).image450)
        image.kf.setImage(with: url)
        image.layer.cornerRadius = 12
        bookNameLabel.text = content.titleEn
        authorLabel.text = content.genres.first?.name
        ratingLabel.text = String(content.audioBook.rating)
        bookAmountLabel.text = "(\(content.audioBook.reviewsCount))"
    }
    func bindDataRecomnmendedBooks(content: AudioPatchContent) {
        let url = URL(string: (content.imageURL ?? "").image450)
        image.kf.setImage(with: url)
        image.layer.cornerRadius = 12
        bookNameLabel.text = content.titleEn
        authorLabel.text = content.genres.first?.name
        ratingLabel.text = String(content.audioBook.rating)
        bookAmountLabel.text = "(\(content.audioBook.reviewsCount))"
    }

    func bindDataArtAndEntertainment(content:AudioPatchContent) {
        let url = URL(string: (content.imageURL ?? "").image450)
        image.kf.setImage(with: url)
        image.layer.cornerRadius = 12
        bookNameLabel.text = content.titleEn
        authorLabel.text = content.genres.first?.name
        ratingLabel.text = String(content.audioBook.rating)
        bookAmountLabel.text = "(\(content.audioBook.reviewsCount))"
    }

}
