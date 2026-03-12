//
//  PodcastModel.swift
//  Shadhin
//
//  Created by Rezwan on 2/11/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let podcastModel = try? newJSONDecoder().decode(PodcastModel.self, from: jsonData)

import Foundation


class PodcastDetailsObj: Codable {
    let status, message: String
    let data: PodcastDetails
    
    init(status: String, message: String, data: PodcastDetails) {
        self.status = status
        self.message = message
        self.data = data
    }
    
    class PodcastDetails: Codable {
        let id: Int
        let code, name, imageURL, productBy: String
        let presenter, about, duration: String
        let episodeList: [PodcastEpisodes]
        
        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case code = "Code"
            case name = "Name"
            case imageURL = "ImageUrl"
            case productBy = "ProductBy"
            case presenter = "Presenter"
            case about = "About"
            case duration = "Duration"
            case episodeList = "EpisodeList"
        }
        
        init(id: Int, code: String, name: String, imageURL: String, productBy: String, presenter: String, about: String, duration: String, episodeList: [PodcastEpisodes]) {
            self.id = id
            self.code = code
            self.name = name
            self.imageURL = imageURL
            self.productBy = productBy
            self.presenter = presenter
            self.about = about
            self.duration = duration
            self.episodeList = episodeList
        }
    }
}


class PodcastEpisodes: Codable, CommonContentProtocol {
    
    var artistImage: String?
    var contentID: String? = nil
    var image: String? = nil
    var newBannerImg: String? = nil
    var title: String? = nil
    var playUrl: String? = nil
    var artist: String? = nil
    var artistId: String? = nil
    var albumId: String? = nil
    var duration: String? = nil
    var contentType: String? = nil
    var fav: String? = nil
    var playCount: Int? = nil
    var trackType: String? = nil
    var isPaid: Bool? = nil
    var copyright: String? = nil
    var labelname: String? = nil
    var releaseDate: String? = nil
    var hasRBT: Bool? = false
    var teaserUrl: String? = nil
    var followers: String? = nil
    
    let id: Int
    let showID, code, name, imageURL: String
    let details: String
    var isCommentPaid : Bool = false
    var trackList: [CommonContent_V5]
    var rbtOperators: [String]?
    var templateFlag: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case showID = "ShowId"
        case code = "Code"
        case name = "Name"
        case imageURL = "ImageUrl"
        case details = "Details"
        case trackList = "TrackList"
        case isCommentPaid = "IsCommentPaid"
        case artistImage = "ArtistImage"
    }
    
    init(id: Int, showID: String, code: String, name: String, imageURL: String, details: String, trackList: [CommonContent_V5]) {
        self.id = id
        self.showID = showID
        self.code = code
        self.name = name
        self.imageURL = imageURL
        self.details = details
        self.trackList = trackList
    }
}

