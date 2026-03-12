//
//  GetAuthorDetailsModel.swift
//  Shadhin
//
//  Created by Maruf on 23/10/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import Foundation

// MARK: - RootResponse
struct AuthorDetailsRootResponse: Codable {
    let success: Bool
    let responseCode: Int
    let title: String
    let data: AuthorDetailsDataClass
    let error: String?
}

// MARK: - DataClass
struct AuthorDetailsDataClass: Codable {
    let parentContents: [AuthorDetailsParentContent]
    let contents: [AuthorDetailsContent]
}

// MARK: - ParentContent
struct AuthorDetailsParentContent: Codable {
    let contentId: Int
    let contentType: String
    let titleBn: String
    let titleEn: String
    let details: String
    let imageUrl: String
    let imageWebUrl: String
    let imageModes: [String]
    let isPaid: Bool
    let likeCount: Int
    let streamingCount: Int
    let sort: Int
    let audioBook: AuthorDetailsAudioBook
    let ownership: String?
    let playlist: String?
    let podcast: String?
    let release: String?
    let track: Track?
    let artists: [String]
    let genres: [String]
    let moods: [String]
    
    func toCommonContent() -> CommonContent_V4 {
        return CommonContent_V4(
            artistId: nil, artistImage: nil, // No direct mapping available
            hasRBT: false, contentID: "\(contentId)",
            contentType: contentType,
            image: imageUrl,
            newBannerImg: nil, // No field for this
            title: titleEn,
            playUrl: track?.streamingURL, // Assuming `streamingURL` exists in `Track`
            artist: audioBook.authors.compactMap({ $0.name }).joined(separator: ", "), // `artists` doesn't provide ID directly
            albumId: nil, // No mapping available
            duration: track?.duration?.description,
            fav: nil, // No mapping available
            playCount: nil, // No mapping available
            isPaid: isPaid,
            trackType: audioBook.contentSubType,
            copyright: ownership,
            labelname: nil, // No mapping available
            releaseDate: release, // Default to false
            teaserUrl: nil, // No mapping available
            followers: nil // No mapping available
        )
    }
    struct Track: Codable {
        let streamingURL: String?
        let duration: Int?
    }
}


// MARK: - AudioBook
struct AuthorDetailsAudioBook: Codable {
    let contentSubType: String
    let duration: Int
    let isCommentPaid: Bool
    let rating: Double
    let reviewsCount: Int
    let categories: [String]
    let authors: [AuthorDetailsAuthor]
    let narrators: [Narrator]?
    let voiceArtists: [AuthorDetailsVoiceArtist]
}

// MARK: - Author
struct AuthorDetailsAuthor: Codable {
    let id: Int
    let name: String
    let image: String
    let role: String
    let booksCount: Int
}

// MARK: - VoiceArtist
struct AuthorDetailsVoiceArtist: Codable {
    let id: Int
    let name: String
    let image: String
    let role: String
    let booksCount: Int
}

// MARK: - Content
struct AuthorDetailsContent: Codable {
    let contentId: Int
    let contentType: String
    let titleBn: String
    let titleEn: String
    let details: String
    let imageUrl: String
    let imageWebUrl: String
    let imageModes: [String]
    let isPaid: Bool
    let likeCount: Int
    let streamingCount: Int
    let sort: Int
    let audioBook: AuthorDetailsAudioBook
    let ownership: String?
    let playlist: String?
    let podcast: String?
    let release: String?
    let track: String?
    let artists: [String]
    let genres: [String]
    let moods: [String]
}
