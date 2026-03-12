//
//  UserSearchedItemsObj.swift
//  Shadhin
//
//  Created by Gakk Alpha on 11/8/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

struct UserSearchedItemsObj: Codable {
    let Status: String
    let Message: String
    let Data: [CommonContent_V0]
}
