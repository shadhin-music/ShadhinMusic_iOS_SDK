//
//  PopUpDTO.swift
//  Shadhin
//
//  Created by Gakk Alpha on 5/19/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

// MARK: - PopUpDTO
struct PopUpObj: Codable {
    let content: [Content]

    enum CodingKeys: String, CodingKey {
        case content = "Data"
    }

    struct Content: Codable, CommonContentProtocol, Equatable{
        var rbtOperators: [String]?
        var templateFlag: Bool?
        
        
        static func == (lhs: Content, rhs: Content) -> Bool {
            return lhs.contentID == rhs.contentID
        }
   
        var contentID: String?
        var image: String?
        var title: String?
        var contentType: String?
        var playUrl: String?
        var duration: String?
        var fav: String?
        
        var playCount: Int?
        let type: String?
        var isPaid, seekable: Bool?
        var trackType: String?
        var artistId, artist: String?
        var artistImage: String?
        var albumId: String?
        let albumName, albumImage, playListID, playListName: String?
        let playListImage, createDate, rootID: String?
        let rootType: String
        
        var copyright: String?
        var labelname: String?
        var releaseDate: String?
        var hasRBT: Bool? = false
        var newBannerImg: String?
        var banner: String?{
            get{
                return image
            }
        }
        var newBanner: String?{
            get{
                return image
            }
        }
        var teaserUrl: String?
        var followers: String?

        enum CodingKeys: String, CodingKey {
            case contentID = "ContentID"
            case image, title
            case contentType = "ContentType"
            case playUrl = "PlayUrl"
            case duration = "Duration"
            case fav
            case playCount = "PlayCount"
            case type = "Type"
            case isPaid = "IsPaid"
            case seekable = "Seekable"
            case trackType = "TrackType"
            case artistId = "artistId"
            case artist = "Artist"
            case artistImage = "ArtistImage"
            case albumId = "albumId"
            case albumName = "AlbumName"
            case albumImage = "AlbumImage"
            case playListID = "PlayListId"
            case playListName = "PlayListName"
            case playListImage = "PlayListImage"
            case createDate = "CreateDate"
            case rootID = "RootId"
            case rootType = "RootType"
        }
    }
}



