//
//  PodcastExploreModel.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/23/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

public struct PodcastExploreObj: Codable {
    let status, message: String
    var data: [Patch]
}

public struct Patch: Codable {
    let patchName: String
    let patchType: String
    let design: String?
    let data: [PatchItem]
    var scrollBy = CGPoint.zero

    enum CodingKeys: String, CodingKey {
        case patchName = "PatchName"
        case patchType = "PatchType"
        case design = "Design"
        case data = "Data"
    }
}

public struct PatchItem: Codable {

    let tracktID, showID, episodeID, showCode: String
    let showName: String
    let episodeCode, episodeName, trackName: String
    let imageURL: String
    let playURL: String
    var duration: String
    let presenter: String
    let about: String
    var contentType: String
    let patchType: String
    let seekable: Bool
    let ceateDate: String
    let totalPlayCount: Int
    var startDate, endDate, fav: String
    var IsPaid : Bool?
    var TrackType : String?

    enum CodingKeys: String, CodingKey {
        case tracktID = "TracktId"
        case showID = "ShowId"
        case episodeID = "EpisodeId"
        case showCode = "ShowCode"
        case showName = "ShowName"
        case episodeCode = "EpisodeCode"
        case episodeName = "EpisodeName"
        case trackName = "TrackName"
        case imageURL = "ImageUrl"
        case playURL = "PlayUrl"
        case duration = "Duration"
        case presenter = "Presenter"
        case about = "About"
        case contentType = "ContentType"
        case patchType = "PatchType"
        case seekable = "Seekable"
        case ceateDate = "CeateDate"
        case totalPlayCount = "TotalPlayCount"
        case startDate = "StartDate"
        case endDate = "EndDate"
        case fav
        case IsPaid
        case TrackType
    }
}

