//
//  AlbumContentModel.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/13/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import Foundation

struct AlbumOrPlaylistObj: Codable {
    var data: [CommonContent_V1]
    var image: String?
    var isPaid: Bool?
}

struct SingleTrackDetailsObj: Codable {
    var data: CommonContent_V2
}

struct ReleaseResponse: Decodable {
    let success: Bool?
    let responseCode: Int?
    let title: String?
    let message: String?
    let data: ReleaseDataModel?
    let error: String?
}

struct ReleaseDataModel: Decodable {
    var parentContents: [ReleaseContent]
    var contents: [ReleaseContent]
}

struct ArtistAlbum: Codable {
    let id: Int?
    let name: String?
    let image: String?
    let showCount: Int?
}

struct ReleaseContent: Decodable, CommonContentProtocol {

    // MARK: - Extra API Fields
    var templateFlag: Bool?
    var rbtOperators: [String]?
    var newBannerImg: String?
    var artist: String?
    var artistId: String?
    var albumId: String?
    var artistImage: String?
    var fav: String?
    var playCount: Int?
    var trackType: String?
    var copyright: String?
    var labelname: String?
    var releaseDate: String?
    var hasRBT: Bool?
    var teaserUrl: String?
    var followers: String?
    var likeCount: Int?
    var streamingCount: Int?
    var sort: Int?
    var createdAtEpoch: Int?
    var imageWebUrl: String?
    var imageModes: [String]?
    var genres: [Genre]?
    var moods: [Mood]?
    var artists: [ArtistAlbum]?
    var track: Track?
    var ownership: HomeV3Ownership?
    var release: Release?

    // MARK: - CommonContentProtocol
    var contentID: String?
    var contentType: String?
    var image: String?
    var title: String?
    var playUrl: String?
    var isPaid: Bool?
    var duration: String?
    var releaseId: String? {
           get { return release?.id != nil ? "\(release!.id!)" : nil }
           set { }
       }
    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case contentID = "contentId"
        case contentType
        case title = "titleEn"
        case image = "imageUrl"
        case imageWebUrl
        case imageModes
        case isPaid

        case templateFlag
        case rbtOperators
        case newBannerImg
        case artist
        case artistId
        case albumId
        case artistImage
        case fav
        case playCount
        case trackType
        case copyright
        case labelname
        case releaseDate
        case hasRBT
        case teaserUrl
        case followers
        case likeCount
        case streamingCount
        case sort
        case createdAtEpoch

        case genres
        case moods
        case artists
        case track
        case ownership
        case release
    }

    enum TrackKeys: String, CodingKey {
        case streamingUrl
        case duration
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let id = try container.decodeIfPresent(Int.self, forKey: .contentID) {
            contentID = String(id)
        } else {
            contentID = try container.decodeIfPresent(String.self, forKey: .contentID)
        }

        contentType = try container.decodeIfPresent(String.self, forKey: .contentType)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        isPaid = try container.decodeIfPresent(Bool.self, forKey: .isPaid)

        templateFlag = try container.decodeIfPresent(Bool.self, forKey: .templateFlag)
        rbtOperators = try container.decodeIfPresent([String].self, forKey: .rbtOperators)
        newBannerImg = try container.decodeIfPresent(String.self, forKey: .newBannerImg)
        artist = try container.decodeIfPresent(String.self, forKey: .artist)
        artistId = try container.decodeIfPresent(String.self, forKey: .artistId)
        albumId = try container.decodeIfPresent(String.self, forKey: .albumId)
        artistImage = try container.decodeIfPresent(String.self, forKey: .artistImage)
        fav = try container.decodeIfPresent(String.self, forKey: .fav)
        playCount = try container.decodeIfPresent(Int.self, forKey: .playCount)
        trackType = try container.decodeIfPresent(String.self, forKey: .trackType)
        copyright = try container.decodeIfPresent(String.self, forKey: .copyright)
        labelname = try container.decodeIfPresent(String.self, forKey: .labelname)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        hasRBT = try container.decodeIfPresent(Bool.self, forKey: .hasRBT)
        teaserUrl = try container.decodeIfPresent(String.self, forKey: .teaserUrl)
        followers = try container.decodeIfPresent(String.self, forKey: .followers)

        likeCount = try container.decodeIfPresent(Int.self, forKey: .likeCount)
        streamingCount = try container.decodeIfPresent(Int.self, forKey: .streamingCount)
        sort = try container.decodeIfPresent(Int.self, forKey: .sort)
        createdAtEpoch = try container.decodeIfPresent(Int.self, forKey: .createdAtEpoch)

        image = try container.decodeIfPresent(String.self, forKey: .image)
        imageWebUrl = try container.decodeIfPresent(String.self, forKey: .imageWebUrl)
        imageModes = try container.decodeIfPresent([String].self, forKey: .imageModes)

        genres = try container.decodeIfPresent([Genre].self, forKey: .genres)
        moods = try container.decodeIfPresent([Mood].self, forKey: .moods)
        artists = try container.decodeIfPresent([ArtistAlbum].self, forKey: .artists)

        track = try container.decodeIfPresent(Track.self, forKey: .track)
        ownership = try container.decodeIfPresent(HomeV3Ownership.self, forKey: .ownership)
        release = try container.decodeIfPresent(Release.self, forKey: .release)

        playUrl = track?.streamingUrl
        if let d = track?.duration {
            duration = String(d)
        }
    }
}
