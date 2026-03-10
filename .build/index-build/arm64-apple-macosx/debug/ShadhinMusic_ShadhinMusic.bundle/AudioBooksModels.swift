//
//  AudioBooksModels.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 12/6/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import Foundation

// MARK: - AuthorDetailsModel
struct AuthorDetailsModel: Codable {
    let success: Bool?
    let responseCode: Int?
    let title: String?
    let data: BookData?
    let error: String?
}

// MARK: - AudioBookResponseModel
struct AudiobBookResponseModel: Codable {
    let success: Bool?
    let responseCode: Int?
    let title: String?
    let data: BookData?
    let error: String?
}

// MARK: - BookData
struct BookData: Codable {
    let parentContents: [ParentContent]?
    let contents: [AudioBookContent]?
}

// MARK: - ParentContent
struct ParentContent: Codable {
    let contentId: Int?
    let contentType: String?
    let titleBn: String?
    let titleEn: String?
    let details: String?
    let imageUrl: String?
    let imageWebUrl: String?
    let isPaid: Bool?
    let likeCount: Int?
    let sort: Int?
    let audioBook: AudioBook?
    let ownership: AudioBookOwnership?
    let playlist: String?
    let podcast: String?
    let release: String?
    let track: Track?
    let artists: [Artist]?
    let authors: [Author]?
    let narrators: [Narrator]?
    let genres: [Genre]?
    let moods: [Mood]?
    
    func toCommonContent() -> CommonContent_V4 {
        return CommonContent_V4(
            artistId: self.artists?.first?.id.description, artistImage: self.artists?.first?.image,
            hasRBT: false, contentID: "\(self.contentId ?? 0)",
            contentType: self.contentType ?? "",
            image: self.imageUrl ?? "",
            newBannerImg: nil, // This field isn't available in AudioBookContent
            title: self.titleEn ?? "",
            playUrl: self.track?.streamingUrl,
            artist: self.audioBook?.authors?.compactMap({$0.name}).joined(separator: ", "),
            albumId: nil, // This field isn't available in AudioBookContent
            duration: self.track?.duration?.description,
            fav: nil, // This field isn't available in AudioBookContent
            playCount: nil, // This field isn't available in AudioBookContent
            isPaid: self.isPaid,
            trackType: self.audioBook?.contentSubType,
            copyright: nil, // This maps to the ownership property
            labelname: nil, // This field isn't available in AudioBookContent
            releaseDate: self.release, // Set to false as default
            teaserUrl: nil, // This field isn't available in AudioBookContent
            followers: nil // This field isn't available in AudioBookContent
        )
    }
}

// MARK: - AudioBookContent
struct AudioBookContent: Codable {
    let contentId: Int?
    let contentType: String?
    let titleBn: String?
    let titleEn: String?
    let details: String?
    let imageUrl: String?
    let imageWebUrl: String?
    let isPaid: Bool?
    let likeCount: Int?
    let sort: Int?
    let audioBook: AudioBook?
    let ownership: String?
    let playlist: String?
    let podcast: String?
    let release: String?
    let track: Track?
    let artists: [Artist]?
    let genres: [Genre]?
    let moods: [Mood]?

    func toCommonContent() -> CommonContent_V4 {
        return CommonContent_V4(
            artistId: self.artists?.first?.id.description, artistImage: self.artists?.first?.image,
            hasRBT: false, contentID: "\(self.contentId ?? 0)",
            contentType: self.contentType ?? "",
            image: self.imageUrl ?? "",
            newBannerImg: nil, // This field isn't available in AudioBookContent
            title: self.titleEn ?? "",
            playUrl: self.track?.streamingUrl,
            artist: self.audioBook?.authors?.compactMap({$0.name}).joined(separator: ", "),
            albumId: nil, // This field isn't available in AudioBookContent
            duration: self.track?.duration?.description,
            fav: nil, // This field isn't available in AudioBookContent
            playCount: nil, // This field isn't available in AudioBookContent
            isPaid: self.isPaid,
            trackType: self.audioBook?.contentSubType,
            copyright: nil, // This maps to the ownership property
            labelname: nil, // This field isn't available in AudioBookContent
            releaseDate: self.release, // Set to false as default
            teaserUrl: nil, // This field isn't available in AudioBookContent
            followers: nil // This field isn't available in AudioBookContent
        )
    }
}

// MARK: - AudioBook
struct AudioBook: Codable {
    let contentSubType: String?
    let authorDisplayName: String?
    let duration: Int?
    let isCommentPaid: Bool?
    let rating: Double?
    let reviewsCount: Int?
    let categories: [Category]?
    var authors: [Author]?
    let narrators: [Narrator]?
    let voiceArtists: [VoiceArtist]?
}

// MARK: - Author
struct Author: Codable {
    let id: Int?
    let name: String?
    let image: String?
    let role: String?
    let booksCount: Int?
}

// MARK: - Narrator
struct Narrator: Codable {
    let id: Int?
    let name: String?
    let image: String?
    let role: String?
    let booksCount: Int?
}

// MARK: - VoiceArtist
struct VoiceArtist: Codable {
    let id: Int?
    let name: String?
    let image: String?
    let role: String?
    let booksCount: Int?
}

// MARK: - Category
struct Category: Codable {
    let id: Int
    let name: Name
}

// MARK: - AudioBookReviewsResponse
struct AudioBookReviewsResponse: Codable {
    let success: Bool?
    let responseCode: Int?
    let title: String?
    let data: AudioBookReviewData?
    let error: String?
}

// MARK: - AudioBookReviewData
struct AudioBookReviewData: Codable {
    let reviewRatingCount: ReviewRatingCount?
    let review: [AudioBookReview]?
}

// MARK: - ReviewRatingCount
struct ReviewRatingCount: Codable {
    let reviewCount: Int?
    let ratingAverage: Double?
}

// MARK: - AudioBookReview
struct AudioBookReview: Codable {
    let reviewId: Int?
    let description: String?
    let rating: Double?
    var reactionCount: Int?
    let replyCount: Int?
    var isFavorite: Bool
    let isMyReview: Bool?
    let fullName: String?
    let imageUrl: String?
    let createdDate: String?
    let updatedDate: String?
}

// MARK: - Ownership Model
struct AudioBookOwnership: Codable {
    let label: String?
    let copyright: String?
    let productBy: String?
    let publication: String?
}
