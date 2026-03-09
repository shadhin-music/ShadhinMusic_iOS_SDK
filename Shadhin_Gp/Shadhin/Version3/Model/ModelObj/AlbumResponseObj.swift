//
//  AlbumResponseModel.swift
//  Shadhin
//
//  Created by Admin on 13/7/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

// MARK: - AlbumResponseModel
struct AlbumResponseObj: Codable {
    let status, message, type: String
    let fav: String?
    let data: [AlbumModel]
    let image, follow: String?
}

// MARK: - Datum
struct AlbumModel: Codable {
    
    var contentID: String?
    var image: String?
    var title, contentType, playURL, artist: String?
    var duration, copyright, labelname: String?
    var releaseDate: String?
    var fav, artistId: String?

    enum CodingKeys: String, CodingKey {
        case contentID = "ContentID"
        case image, title
        case contentType = "ContentType"
        case playURL = "PlayUrl"
        case artist, duration, copyright, labelname, releaseDate, fav
        case artistId = "artistId"
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
        
        return data
    }
}

