//
//  ReelsResponseObject.swift
//  Shadhin_Gp_Examaple
//
//  Created by MD Murad Hossain on 25/11/25.
//


import Foundation

// MARK: - ReelsResponseObject
struct ReelsResponseObject: Codable {
    let message: String?
    let success: Bool?
    let responseCode: Int?
    let title: String?
    var data: [DataModel]?
    let error: String?
}

// MARK: - DataModel
struct DataModel: Codable {
    let id: Int?
    let code: String?
    let title: String?
    let imageURL: String?
    let designType: Int?
    let isSeeAll: Bool?
    let isShuffle: Bool?
    let sort: Int?
    var contents: [ReelsContent]?
    
    enum CodingKeys: String, CodingKey {
        case id, code, title
        case imageURL = "imageUrl"
        case designType, isSeeAll, isShuffle, sort, contents
    }
}

// MARK: - Content
struct ReelsContent: Codable {
    let id: Int?
    let contentType: ContentContentType?
    let title: String?
    let description: String?
    let imageURL: String?
    let duration: Int?
    let streamingURL: String?
    var analytics: ShortsAnalytics?
    let baseContent: BaseContent?
    let owners: [ShortsOwners]?
    let artists: [ShortsArtist]?
    let socialMediaLinks: [SocialMediaLink]?
    let hashtags: [Hashtag]?
    let genres: [String]?
    var isActive: Bool?
    var createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, contentType, title, description
        case imageURL = "imageUrl"
        case duration
        case streamingURL = "streamingUrl"
        case analytics, baseContent, owners, artists, socialMediaLinks, hashtags, genres, isActive, createdAt
    }
}

// MARK: - Analytics
struct ShortsAnalytics: Codable {
    var reelsCount: Int?
    var favoritesCount: Int?
    var followersCount: Int?
    var followingsCount: Int?
    var viewsCount: Int?
    var commentsCount: Int?
    var sharesCount: Int?
    var contributorsCount: Int?
}

// MARK: - Artist
struct ShortsArtist: Codable {
    let id: Int?
    let name: String?
    let image: String?
}

// MARK: - BaseContent
struct BaseContent: Codable {
    let baseContentID: Int?
    let contentType: BaseContentContentType?
    let title: String?
    let imageURL: String?
    let audio: MediaAsset?
    let video: MediaAsset?
    let duration: Int?
    let startCursor: Int?
    let endCursor: Int?
    let reelsCount: Int?
    let routingContentID: Int?
    let routingContentType: RoutingContentType?
    let routingContentSubType: String?
    
    enum CodingKeys: String, CodingKey {
        case baseContentID = "baseContentId"
        case contentType, title
        case imageURL = "imageUrl"
        case audio, video
        case duration, startCursor, endCursor, reelsCount
        case routingContentID = "routingContentId"
        case routingContentType, routingContentSubType
    }
}

enum BaseContentContentType: String, Codable {
    case empty = ""
    case s = "S"
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = (try? container.decode(String.self)) ?? ""
        self = BaseContentContentType(rawValue: raw) ?? .unknown
    }
}

// MARK: - Audio/Video Asset
struct MediaAsset: Codable {
    let contentType: String
    let streamingUrl: String
    let duration: Int
}

enum RoutingContentType: String, Codable {
    case empty = ""
    case r = "R"
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = (try? container.decode(String.self)) ?? ""
        self = RoutingContentType(rawValue: raw) ?? .unknown
    }
}

enum ContentContentType: String, Codable {
    case sa = "SA"
    case sp = "SP"
    case sv = "SV"
    case c = "C"
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = (try? container.decode(String.self)) ?? ""
        self = ContentContentType(rawValue: raw) ?? .unknown
    }
}

// MARK: - Hashtag
struct Hashtag: Codable {
    let id: Int?
    let tagKey: String?
    let displayName: String?
    let reelsCount: Int?
    let viewsCount: Int?
    let contributorsCount: Int?
}

// MARK: - Owner
struct ShortsOwners: Codable {
    let id: Int?
    let isVerified: Bool?
    let type: String?
    let name: String?
    let usercode: String?
    let imageURL: String?
    let analytics: ShortsAnalytics?
    
    enum CodingKeys: String, CodingKey {
        case id, isVerified, type, name, usercode
        case imageURL = "imageUrl"
        case analytics
    }
}

// MARK: - SocialMediaLink
struct SocialMediaLink: Codable {
    let socialMediaName: String
    let externalAccLink: String
}


// MARK: - AnalyticsResponse
struct AnalyticsResponse: Codable {
    let message: String
    let success: Bool
    let responseCode: Int
    let title: String
    let data: [ContentData]
    let error: String?
}

struct ContentData: Codable {
    let id: Int
    let contentType: String
    let analytics: ShortsAnalytics
}

// MARK: - Get FavoriteResponse

struct FavoriteResponse: Codable {
    let message: String
    let success: Bool
    let responseCode: Int
    let title: String
    let data: [Favorite]?
    let error: String?
}

struct Favorite: Codable {
    let contentId: Int?
    let contentType: String?
    let createdAt: Int?
}

struct FavoriteDeleteOrAddResponse: Codable {
    let message: String
    let success: Bool
    let responseCode: Int
    let title: String
    let data: String?
    let error: APIErrorDetail
}

struct APIErrorDetail: Codable {
    let source: String
    let message: String
    let details: String
    let errorCode: String
}

struct ShareActivityResponse: Codable {
    let message: String
    let success: Bool
    let responseCode: Int
    let title: String
    let data: String?
    let error: String?
}
