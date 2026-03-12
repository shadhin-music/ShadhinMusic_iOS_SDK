//
//  ArtistFavModel.swift
//  Shadhin
//
//  Created by Rezwan on 6/25/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import Foundation

// MARK: - ArtistFavModel
struct FeaturedPlaylistOfArtistObj: Codable {
    let status, message, type, fav: String
    let image: String
    let follow, playListID, playListImage: String

    enum CodingKeys: String, CodingKey {
        case status, message, type, fav, image, follow
        case playListID = "PlayListId"
        case playListImage = "PlayListImage"
    }
}
