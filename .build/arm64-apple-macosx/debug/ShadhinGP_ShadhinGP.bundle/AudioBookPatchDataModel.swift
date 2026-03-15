//
//  AudioBookPatchDataModel.swift
//  Shadhin
//
//  Created by Maruf on 2/10/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import Foundation

struct AudioPatchHomeModel: Codable {
    let success: Bool
    let responseCode: Int
    let title: String
    let data: [AudioPatchHome]
    let error: String?
}

// MARK: - AudioPatchHome
struct AudioPatchHome: Codable {
    let patch: AudioPatch
    let contents: [AudioPatchContent]
}

// MARK: - AudioPatchContent
struct AudioPatchContent: Codable {
    let contentID: Int
    let contentType: AudioPatchContentType
    let titleBn: String?
    let titleEn: String?
    let details: String?
    let imageURL: String? // Allow null values
    let imageWebURL: String
    let imageModes: [AudioPatchImageMode]
    let isPaid: Bool
    let likeCount, streamingCount, sort: Int
    let audioBook: AudioPatchAudioBook
    let ownership: AudioPatchOwnership?
    let playlist, podcast, release, track: String?
    let artists: [String]
    let genres: [AudioPatchGenre]
    let moods: [String]
    
    enum CodingKeys: String, CodingKey {
        case contentID = "contentId"
        case contentType, titleBn, titleEn, details
        case imageURL = "imageUrl"
        case imageWebURL = "imageWebUrl"
        case imageModes, isPaid, likeCount, streamingCount, sort, audioBook, ownership, playlist, podcast, release, track, artists, genres, moods
    }
}

// MARK: - AudioPatch
struct AudioPatch: Codable {
    let id: Int
    let code, title: String
    let description: String?
    let imageURL: String? // Allow null values
    var designType: Int?
    let isSeeAllActive, isShuffle: Bool
    let sort: Int
    
    enum CodingKeys: String, CodingKey {
        case id, code, title, description
        case imageURL = "imageUrl"
        case designType, isSeeAllActive, isShuffle, sort
    }
    
    func getDesignAudioBook() -> AudioBookHomePatchType {
        return AudioBookHomePatchType(rawValue: designType ?? -1) ?? .UNKNOWN
    }
}

// MARK: - AudioPatchAudioBook
struct AudioPatchAudioBook: Codable {
    let contentSubType: AudioPatchContentSubType
    let duration: Int
    let isCommentPaid: Bool
    let rating: Double
    let reviewsCount, completionPercentage: Int
    let categories: [AudioPatchCategory]
    let authors, narrators, voiceArtists: [AudioPatchGenre]
}

// MARK: - AudioPatchGenre
struct AudioPatchGenre: Codable {
    let id: Int
    let name: String
    let image: String?
    let role: AudioPatchRole?
}

enum AudioPatchRole: String, Codable {
    case author = "AUTHOR"
    case narrator = "NARRATOR"
    case voiceArtist = "VOICE_ARTIST"
}

// MARK: - AudioPatchCategory
struct AudioPatchCategory: Codable {
    let id: Int
    let name: AudioPatchName
}

enum AudioPatchName: String, Codable {
    case history = "History"
    case selfHelp = "Self-Help"
    case story = "Story"
    case unknown // Catch-all case for unexpected values
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = AudioPatchName(rawValue: rawValue) ?? .unknown
    }
}

enum AudioPatchContentSubType: String, Codable {
    case category = "CATEGORY"
    case episode = "EPISODE"
}

enum AudioPatchContentType: String, Codable {
    case bk = "BK"
}

// MARK: - AudioPatchImageMode
struct AudioPatchImageMode: Codable {
    let darkModeImage, lightModeImage: String
}

// MARK: - AudioPatchOwnership
struct AudioPatchOwnership: Codable {
    let label: String?
    let copyright: String?
    let productBy: AudioPatchCopyright
    let publication: String?
}

// MARK: - AudioPatchCopyright
enum AudioPatchCopyright: String, Codable {
    case esoGolpoKori = "Eso Golpo Kori"
    case shadhinMusic = "Shadhin Music"
    case talkTheatre = "Talk Theatre"
    case unknown
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = AudioPatchCopyright(rawValue: rawValue) ?? .unknown
    }
}


