//
//  ArtistDTO.swift
//  Shadhin
//
//  Created by Gakk Alpha on 5/18/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation


struct ArtistObj: Codable {
    let data: DataClass?
    
    struct DataClass: Codable {
        let artist: ArtistsInPlaylistObj?

        enum CodingKeys: String, CodingKey {
            case artist = "Artist"
        }
        
    }
}


