//
//  UserPlaylistDetailsObj.swift
//  Shadhin
//
//  Created by Gakk Alpha on 11/8/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

struct UserPlaylistDetailsObj: Codable {
    var status: String
    var data: [CommonContent_V4]
}
