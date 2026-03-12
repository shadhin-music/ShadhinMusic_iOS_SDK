//
//  TopStreammingElementModelData.swift
//  Shadhin_Gp_Examaple
//
//  Created by MD Murad Hossain  on 6/10/25.
//


import Foundation

struct TopStreammingElementModelData:Codable {
    let data:[TopStreammingElementModel]?
    let statusCode: Int?
    let message: String?
}

// MARK: - Datum
struct TopStreammingElementModel:Codable {
    let contentType: String?
    let contentName: String?
    let minOfStream: Int?
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case contentType, contentName, minOfStream
        case imageURL = "imageUrl"
    }
}
