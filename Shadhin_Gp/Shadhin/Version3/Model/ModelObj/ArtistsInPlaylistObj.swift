//
//  ArtistsInPlaylistObj.swift
//  Shadhin
//
//  Created by Gakk Alpha on 11/8/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

struct ArtistsInPlaylistObj: Codable {
    let status: String
    let message: String
    let data: [CommonContent_V0]
}
