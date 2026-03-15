//
//  Lyrics.swift
//  Shadhin
//
//  Created by Gakk Alpha on 9/1/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

struct LyricsObj: Codable {
    let status, message: String
    let data: Data
    
    struct Data: Codable {
        let id, lyrics: String?

        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case lyrics = "Lyrics"
        }
    }
}
