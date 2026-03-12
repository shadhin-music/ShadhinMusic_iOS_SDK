//
//  PlaylistResponseModel.swift
//  Shadhin
//
//  Created by Joy on 14/7/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

// MARK: - PlayListResponseModel
struct PlaylistResponseObj: Codable {
    let status, message, type: String
    let fav: String?
    let data: [PlaylistContentModel]
    let image: String
    let follow: String?
}

// MARK: - Datum
struct PlaylistContentModel: Codable {
    let contentID: String
    let image: String
    let title: String
    let contentType: String
    let playURL, artist, duration, copyright: String
    let labelname: String
    let releaseDate: String
    let fav, albumId, artistId: String
    let userPlayListID: String?

    enum CodingKeys: String, CodingKey {
        case contentID = "ContentID"
        case image, title
        case contentType = "ContentType"
        case playURL = "PlayUrl"
        case artist, duration, copyright, labelname, releaseDate, fav
        case albumId = "albumId"
        case artistId = "artistId"
        case userPlayListID = "UserPlayListId"
    }
    
    func getDataContentProtocal()-> CommonContent_V7{
        var data = CommonContent_V7()
        data.contentID  = self.contentID
        data.image = self.image
        data.title = self.title
        data.contentType = self.contentType
        data.playUrl = self.playURL
        data.artist = self.artist
        data.duration = self.duration
        data.copyright = self.copyright
        data.labelname = self.labelname
        data.releaseDate = self.releaseDate
        data.fav = self.fav
        data.artistId = self.artistId
        data.albumId = self.albumId
        
        return data
    }
}

