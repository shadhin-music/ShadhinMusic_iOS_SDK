//
//  ArtistSelectObj.swift
//  Shadhin
//
//  Created by Maruf on 23/1/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import Foundation
// MARK: - Artists
class Artists: Codable {
    let status, message: String
    let data: [Artist]
    
    // MARK: - Artist
    class Artist: Codable {
        let id, artistName: String
        let image: String
        let follower: String
        let playURL: String
        var isFavorite: Bool = false

        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case artistName = "ArtistName"
            case image = "Image"
            case follower = "Follower"
            case playURL = "PlayUrl"
        }
    }
}

struct FavoriteArtistAdd: Codable {
    let status, type, contentID: String?
    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case type = "Type"
        case contentID = "ContentId"
    }
}
