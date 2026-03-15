//
//  AllCategoriesModel.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/10/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import Foundation

struct VideoPatchesObj: Codable {
    var data: [VideoPatch]
}

struct VideoPatch: Codable {
    var name: String
    var code: String
    var contentType: String
    var sort: String
    var design: String?
    
    enum CodingKeys: String,CodingKey {
        case name = "Name"
        case code = "Code"
        case contentType = "ContentType"
        case sort = "Sort"
        case design = "Design"
    }
}
