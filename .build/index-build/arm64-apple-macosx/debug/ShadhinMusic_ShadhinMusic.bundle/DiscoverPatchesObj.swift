//
//  DiscoverPatchesObj.swift
//  Shadhin
//
//  Created by Gakk Alpha on 11/8/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

struct DiscoverPatchesObj: Codable {

    let status: String?
    let message: String
    let data: [PatchDetailsObj]
    let total: Int
    let type, fav, image, follow: String?
    let monthlyListener, name: String?

    enum CodingKeys: String, CodingKey {
        case status, message, data, total, type, fav, image, follow
        case monthlyListener = "MonthlyListener"
        case name
    }
}
