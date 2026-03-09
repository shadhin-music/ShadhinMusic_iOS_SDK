//
//  TopTenTrendingModel.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 1/16/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import Foundation

struct TopTenTrendingObj: Codable {
    let data: [CommonContent_V0]
    var sort: Int!
}
