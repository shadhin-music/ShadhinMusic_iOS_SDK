//
//  PlaylistModel.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/8/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import Foundation

struct PlaylistsObj: Codable {
    var data: [PlaylistDetails]
    
    struct PlaylistDetails: Codable {
        var id: String
        var name: String
        var Data : [Songs]?
        var isAIPlayList: Bool?
        var aiImageUrl: String?
        
        var isSelected: Bool = true
        
        struct Songs : Codable {
            var image : String
        }
        
        enum CodingKeys: String,CodingKey {
            case id = "id"
            case name = "name"
            case Data = "Data"
        }
    }
}

// Root model
struct UserPlaylistModel: Codable {
    let success: Bool
    let responseCode: Int
    let title: String
    let data: [NewContent]
    let error: String?
}
