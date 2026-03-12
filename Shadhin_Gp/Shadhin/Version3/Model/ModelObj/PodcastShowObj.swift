//
//  PodcastShowModel.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/23/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation
struct PodcastShowObj: Codable {
    let status, message: String
    let data: [PatchShow]
}

// MARK: - Datum
struct PatchShow: Codable {
    let patchName, patchType: String?
    let design: String?
    let data: [PatchShowItem]

    enum CodingKeys: String, CodingKey {
        case patchName = "PatchName"
        case patchType = "PatchType"
        case design = "Design"
        case data = "Data"
    }
}

// MARK: - DatumElement
struct PatchShowItem: Codable {
    let tracktID, showID, episodeID, showCode: String
    let showName, episodeCode, episodeName, trackName: String
    let imageURL: String
    let playURL, duration, presenter, about: String
    let contentType, patchType: String
    let seekable: Bool
    let ceateDate: String
    let totalPlayCount: Int
    let startDate, endDate, fav: String?

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
    }
}

