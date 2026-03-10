//
//  AISearchModels.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 15/5/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import Foundation

// MARK: - Response
struct AIMoodlistModel: Codable {
    let success: Bool
    let responseCode: Int
    let title: String
    let data: [MoodCategory]
    let error: String?
}

// MARK: - Category
struct MoodCategory: Codable {
    let id: Int
    let name: String
    let image: String
    let gif: String
    let sort: Int
}

// MARK: - Response
struct AIPlaylistResponseModel: Codable {
    let success: Bool
    let responseCode: Int
    let title: String
    let data: AIPlaylistData
    let error: String?
}

// MARK: - DataClass
struct AIPlaylistData: Codable {
    let parentContents: [NewContent]
    let contents: [NewContent]
}

// MARK: - Content
struct NewContent: Codable {
    let contentId: Int
    let contentType: String
    let titleBn, titleEn, details: String
    let imageUrl, imageWebUrl: String
    let track: Track?
    let isPaid: Bool
    let likeCount: Int
    let sort: Int
    let release: Release?
    let playlist: Playlist?
    let artists: [Artist]
    let genres: [Genre]
    let moods: [Mood]
    let audioBook: JSONNull?
    let ownership: Ownership?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.contentId = try container.decode(Int.self, forKey: .contentId)
        self.contentType = try container.decode(String.self, forKey: .contentType)
        self.titleBn = try container.decode(String.self, forKey: .titleBn)
        self.titleEn = try container.decode(String.self, forKey: .titleEn)
        self.details = try container.decode(String.self, forKey: .details)
        self.imageUrl = try container.decode(String.self, forKey: .imageUrl)
        self.imageWebUrl = try container.decode(String.self, forKey: .imageWebUrl)
        self.track = try container.decodeIfPresent(Track.self, forKey: .track)
        self.isPaid = try container.decode(Bool.self, forKey: .isPaid)
        self.likeCount = try container.decode(Int.self, forKey: .likeCount)
        self.sort = try container.decode(Int.self, forKey: .sort)
        self.release = try container.decodeIfPresent(Release.self, forKey: .release)
        self.playlist = try container.decodeIfPresent(Playlist.self, forKey: .playlist)
        self.artists = try container.decode([Artist].self, forKey: .artists)
        self.genres = try container.decode([Genre].self, forKey: .genres)
        self.moods = try container.decode([Mood].self, forKey: .moods)
        self.audioBook = try container.decodeIfPresent(JSONNull.self, forKey: .audioBook)
        self.ownership = try container.decodeIfPresent(Ownership.self, forKey: .ownership)
    }
}

extension NewContent {
    func toCommonContentProtocol() -> CommonContent_V4 {
        var contentItem = CommonContent_V4()
        contentItem.contentID = String(self.contentId)
        contentItem.contentType = self.contentType
        contentItem.image = self.imageUrl
        contentItem.title = self.titleEn
        contentItem.artist = self.artists.first?.name ?? ""
        contentItem.playUrl = self.track?.streamingUrl
        return contentItem
    }
}


// MARK: - Ownership
struct Ownership: Codable {
    let label, copyright, productBy, publication: String
}

// MARK: - Genre
struct Genre: Codable {
    let id: Int?
    let name: String?
    let image: String?
}

// MARK: - Mood
struct Mood: Codable {
    let id: Int?
    let name: String?
    let image: String?
}


// MARK: - Release
struct Release: Codable {
    let id: Int?
    let name: String?
    let date: String?
}


// MARK: - Track

struct Track: Codable {
    let streamingUrl: String?
    let duration: Int?
    let currentDurationCursor: Int?
    let lyrics: String?
    let trackType: String?
    let isLive: Bool?
}


/*
// MARK: - ParentContent
struct AIParentContent: Codable {
    let contentId: Int
    let contentType, titleBn, titleEn, details: String
    let imageUrl, imageWebUrl, playUrl: String
    let durationSeconds: Int
    let trackType: String
    let isPaid: Bool
    let likeCount: Int
    let label, copyright: String
    let sort: Int
    let release: String?
    let playlist: Playlist?
    let artists: [Artist]
    let genres: [Genre]
    let moods: [Mood]
    
    func toCommonContentProtocol()->CommonContentProtocol{
        var contentItem = CommonContent_V1()
        contentItem.contentID  = String(self.contentId)
        contentItem.contentType = self.contentType
        contentItem.image = self.imageUrl
        contentItem.title = self.moods.first?.name
        contentItem.artist = self.artists.first?.name ?? ""
        return contentItem

    }
}
*/

