//
//  PodcastVersionTwoModels.swift
//  Shadhin_Gp
//
//  Fully cleaned and refactored for API Version Two
//

import Foundation

var selectedParentContentID = -1

// MARK: - PodcastVersionTwoResponse
struct PodcastVersionTwoResponse: Codable {
    let message: String?
    let success: Bool
    let responseCode: Int
    let title: String
    let data: [PodcastSectionVersionTwo]
    let pagination: PaginationVersionTwo
    let error: String?
}

// MARK: - PodcastSectionVersionTwo
struct PodcastSectionVersionTwo: Codable {
    let patch: PatchVersionTwo
    let contents: [PodcastContentVersionTwo]
}

// MARK: - PodcastContentVersionTwo
struct PodcastContentVersionTwo: Codable {
    var contentId: Int = 0
    let contentType: String
    let templateFlag: Bool
    let titleBn: String?
    let titleEn: String?
    let details: String?
    let imageUrl: String?
    let imageWebUrl: String?
    let imageModes: [String]?
    var isPaid: Bool = false
    var likeCount: Int = 0
    var sort: Int = 0

    let podcast: PodcastDetailVersionTwo?
    let artists: [HomeV3Artist]?

    // Optional fields (for API safety)
    let audioBook: AudioBook?
    let ownership: HomeV3Ownership?
    let playlist: Playlist?
    let release: Release?
    let track: Track?
    let genres: [Genre]?
    let moods: [Mood]?

    enum CodingKeys: String, CodingKey {
        case contentId, contentType, templateFlag, titleBn, titleEn, details
        case imageUrl, imageWebUrl, imageModes, isPaid, likeCount, sort
        case audioBook, ownership, playlist, podcast, release, track, artists, genres, moods
    }
}

// MARK: - ArtistVersionTwo
struct ArtistVersionTwo: Codable {
    let id: Int
    let name: String
    let image: String
    let showCount: Int?
}

// MARK: - PodcastDetailVersionTwo
struct PodcastDetailVersionTwo: Codable {
    let contentSubType: String?
    let rating: Int
    let reviewsCount: Int
    let duration: Int
    let isComingSoon: Bool
    let isCommentPaid: Bool
}

// MARK: - PatchVersionTwo
struct PatchVersionTwo: Codable {
    let id: Int
    let code: String
    let title: String
    let description: String
    let imageUrl: String
    let designType: Int?
    let isSeeAllActive: Bool
    let isShuffle: Bool
    let sort: Int

    func getDesignPodcast() -> PodcastUpdateDesignType {
        return PodcastUpdateDesignType(rawValue: designType ?? -1) ?? .UNKNOWN
    }
}

// MARK: - PaginationVersionTwo
struct PaginationVersionTwo: Codable {
    let pageNumber: Int
    let pageSize: Int
    let totalItems: Int
    let totalPages: Int
}


// MARK: - Root Model
struct CommentResponse: Codable {
    let status: Bool
    let message: String
    let data: [CommentData]
    let totalData: Int
    let totalPage: Int

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case data = "Data"
        case totalData = "TotalData"
        case totalPage = "TotalPage"
    }
}

// MARK: - Comment Data
struct CommentData: Codable {
    let commentId: Int
    let contentId: String
    let contentType: String
    let contentTitle: String
    let message: String
    let createDate: String
    let userName: String
    let userPic: String
    let commentLike: Bool
    let totalCommentLike: Int
    let commentFavorite: Bool
    let totalCommentFavorite: Int
    let isPin: Bool
    let total: Int
    let totalPage: Int
    let totalReply: Int
    let totalComment: Int
    let adminUserType: String
    let currentPage: Int
    let isSubscriber: Bool

    enum CodingKeys: String, CodingKey {
        case commentId = "CommentId"
        case contentId = "ContentId"
        case contentType = "ContentType"
        case contentTitle = "ContentTitle"
        case message = "Message"
        case createDate = "CreateDate"
        case userName = "UserName"
        case userPic = "UserPic"
        case commentLike = "CommentLike"
        case totalCommentLike = "TotalCommentLike"
        case commentFavorite = "CommentFavorite"
        case totalCommentFavorite = "TotalCommentFavorite"
        case isPin = "IsPin"
        case total = "Total"
        case totalPage = "TotalPage"
        case totalReply = "TotalReply"
        case totalComment = "TotalComment"
        case adminUserType = "AdminUserType"
        case currentPage = "CurrentPage"
        case isSubscriber = "IsSubscriber"
    }
}

// MARK: - PodcastVersionTwoResponseNew
struct PodcastVersionTwoResponseNew: Codable {
    let message: String?
    let success: Bool?
    let responseCode: Int?
    let title: String?
    let data: PodcastData?
    let error: String?
}

// MARK: - PodcastData
struct PodcastData: Codable {
    let parentContents: [PodcastContent]
    let contents: [PodcastContent]
}

// MARK: - PodcastContent
struct PodcastContent: Codable {
    let contentId: Int
    let contentType: String
    let templateFlag: Bool
    let rbtOperators: [String]
    let titleBn, titleEn, details: String
    let imageUrl, imageWebUrl: String
    let imageModes: [String]
    let isPaid: Bool
    let likeCount, streamingCount, sort: Int
    let createdAtEpoch: Int
    let audioBook, ownership, playlist: StringOrObject?
    
    let podcast: PodcastDetails
    let release: ReleaseInfo?
    let track: TrackInfo?
    let trailer: String?
    var artists: [ArtistInfo]?
    let genres: [GenreNew]?
    let moods: [MoodNew]?
    
    func toCommonContent() -> CommonContentProtocol {
        var contentItem = CommonContent_V1()
        
        contentItem.contentID = "\(contentId)"
        contentItem.contentType = contentType
        contentItem.image = imageUrl
        contentItem.title = titleBn.isEmpty ? titleEn : titleBn
        contentItem.albumId = "\(selectedParentContentID)"
        if let artists {
            contentItem.artistId = artists.first?.id.map { "\($0)" }
            contentItem.artist = artists.first?.name
            contentItem.artistImage = artists.first?.name
        }
        
        if let track {
            contentItem.trackType = "EPISODE"
            contentItem.playUrl = track.streamingUrl
        } else if podcast != nil {
            contentItem.trackType = "SHOW"
        }
        
        return contentItem
    }
}


// MARK: - PodcastDetails
struct PodcastDetails: Codable {
    let contentSubType: String
    let rating, reviewsCount, duration: Int
    let isComingSoon, isCommentPaid: Bool
}

// MARK: - ReleaseInfo
struct ReleaseInfo: Codable {
    let id: Int
    let name, date: String
}

// MARK: - TrackInfo
struct TrackInfo: Codable {
    let streamingUrl: String
    let duration, currentDurationCursor: Int
    let lyrics, trackType: String
    let isLive: Bool
}

// MARK: - ArtistInfo
struct ArtistInfo: Codable {
    var id: Int?
    var name: String?
    var image: String?
    var showCount: Int?
}

// MARK: - Genre
struct GenreNew: Codable {
    let id: Int
    let name: String
}

// MARK: - Mood
struct MoodNew: Codable {
    let id: Int
    let name: String
}

// MARK: - StringOrObject
enum StringOrObject: Codable {
    case string(String)
    case object([String: Any])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let str = try? container.decode(String.self) {
            self = .string(str)
        } else if let dict = try? container.decode([String: AnyDecodable].self) {
            self = .object(dict.mapValues { $0.value })
        } else {
            self = .string("") // fallback empty string
        }
    }

    func encode(to encoder: Encoder) throws {
        // decode-only; no encoding needed
    }
}

// MARK: - AnyDecodable
struct AnyDecodable: Codable {
    let value: Any

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let dictValue = try? container.decode([String: AnyDecodable].self) {
            value = dictValue.mapValues { $0.value }
        } else if let arrayValue = try? container.decode([AnyDecodable].self) {
            value = arrayValue.map { $0.value }
        } else {
            value = "" // fallback
        }
    }

    func encode(to encoder: Encoder) throws {
        // decode-only; no encoding needed
    }
}


class PodcastContentAdapter: CommonContentProtocol {
    private let episode: PodcastContent
    private let trackInfo: TrackInfo

    init(episode: PodcastContent, track: TrackInfo) {
        self.episode = episode
        self.trackInfo = track
    }

    // MARK: - CommonContentProtocol
    var contentID: String?      { get { String(episode.contentId) }  set {} }
    var image: String?          { get { episode.imageUrl }            set {} }
    var newBannerImg: String?   { get { episode.imageWebUrl }         set {} }
    var title: String?          { get { episode.titleEn }             set {} }
    var playUrl: String?        { get { trackInfo.streamingUrl }      set {} }
    var artist: String?         { get { episode.artists?.first?.name } set {} }
    var artistId: String?       { get { episode.artists?.first.map { String($0.id ?? 0) } } set {} }
    var albumId: String?        { get { String(episode.contentId) }   set {} }
    var artistImage: String?    { get { episode.artists?.first?.image } set {} }
    var duration: String?       { get { String(trackInfo.duration) }  set {} }
    var contentType: String?    { get { episode.contentType }         set {} }
    var fav: String?            { get { nil }                         set {} }
    var playCount: Int?         { get { episode.streamingCount }      set {} }
    var trackType: String?      { get { trackInfo.trackType }         set {} }
    var isPaid: Bool?           { get { episode.isPaid }              set {} }
    var copyright: String?      { get { nil }                         set {} }
    var labelname: String?      { get { nil }                         set {} }
    var releaseDate: String?    { get { episode.release?.date }       set {} }
    var hasRBT: Bool?           { get { !episode.rbtOperators.isEmpty } set {} }
    var teaserUrl: String?      { get { episode.trailer }             set {} }
    var followers: String?      { get { nil }                         set {} }
    var templateFlag: Bool?     { get { episode.templateFlag }        set {} }
    var rbtOperators: [String]? { get { episode.rbtOperators }        set {} }
}
