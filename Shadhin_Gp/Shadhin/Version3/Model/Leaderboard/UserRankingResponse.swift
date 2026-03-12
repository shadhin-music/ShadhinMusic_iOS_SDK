//
//  UserRankingResponse.swift
//  Shadhin_Gp_Examaple
//
//  Created by MD Murad Hossain  on 6/10/25.
//


import Foundation
// MARK: - UserRankingResponse
struct UserRankingResponse: Codable {
    let status, message: String
    let data: RankBkashResponse?
    let total: Int
    let type, fav, image, follow: String?
    let monthlyListener, name: String?

    enum CodingKeys: String, CodingKey {
        case status, message, data, total, type, fav, image, follow
        case monthlyListener = "MonthlyListener"
        case name
    }
}

protocol Rank {
    var userRank: Int { get }
    var userCode: String? { get }
    var timeCountSecond: Int { get }
    var userFullName: String? { get }
    var imageURL: String? { get }
    var msisdn: String? { get }
}

// MARK: - DataClass
struct RankResponse: Rank, Codable {
    var userRank: Int
    
    var userCode: String?
    
    var timeCountSecond: Int
    
    var userFullName: String?
    
    var imageURL: String?
    
    var msisdn: String?
    
    enum CodingKeys: String, CodingKey {
        case userRank = "UserRank"
        case userCode = "UserCode"
        case timeCountSecond = "TimeCountSecond"
        case userFullName = "UserFullName"
        case imageURL = "ImageUrl"
        case msisdn = "Msisdn"
    }
}

struct AllUserRankingResponse: Codable {
        let status, message: String
        let data: UserRankingBkashResponse?
        let total: Int
        let type, fav, image, follow: String?
        let monthlyListener, name: String?

        enum CodingKeys: String, CodingKey {
            case status, message, data, total, type, fav, image, follow
            case monthlyListener = "MonthlyListener"
            case name
        }
}
