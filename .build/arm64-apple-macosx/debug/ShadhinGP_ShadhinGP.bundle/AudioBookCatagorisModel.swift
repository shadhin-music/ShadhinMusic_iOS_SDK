//
//  AudioBookCatagorisModel.swift
//  Shadhin
//
//  Created by Maruf on 9/10/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import Foundation

 struct AudioBookCatagoriesResponseModel: Codable {
    let success: Bool
    let responseCode: Int
    let title: String
    let data: AudioBookCatagoriesResponseData?
    let error: String?
}

// MARK: - Response Data
struct AudioBookCatagoriesResponseData: Codable {
    let contents: [AudioBookCatagoriesContent]?
}


// MARK: - Content Model
struct AudioBookCatagoriesContent: Codable {
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
    let audioBook: AudioBookCatagoriesAudioBook?
    let ownership: String?
    let playlist: String?
    let podcast: String?
    let release: String?
    let track: String?
    let artists: [AudioBookCatagoriesArtist]
    let genres: [String]
    let moods: [String]
}

struct AudioBookCatagoriesAudioBook: Codable {
    let contentSubType: String
    let duration: Int
    let isCommentPaid: Bool
    let rating: Double
    let reviewsCount: Int
    let catagories: [AudioBookCatagoriesCatagories]? // Made optional
    let authors: [AudioBookCatagoriesAuthor]
    let narrators: [AudioBookCatagoriesNarrator]
    let voiceArtists: [AudioBookCatagoriesVoiceArtist]
}


// MARK: - Catagories Model
struct AudioBookCatagoriesCatagories: Codable {
    let id: Int
    let name: String
}

// MARK: - Author Model
struct AudioBookCatagoriesAuthor: Codable {
    let id: Int
    let name: String
    let image: String
    let role: String
    let booksCount: Int
}

// MARK: - Narrator Model
struct AudioBookCatagoriesNarrator: Codable {
    let id: Int
    let name: String
    let image: String
    let role: String
    let booksCount: Int
}

// MARK: - VoiceArtist Model
struct AudioBookCatagoriesVoiceArtist: Codable {
    let id: Int
    let name: String
    let image: String
    let role: String
    let booksCount: Int
}

// MARK: - Artist Model
struct AudioBookCatagoriesArtist: Codable {
    let id: Int
    let name: String
    let image: String
}

