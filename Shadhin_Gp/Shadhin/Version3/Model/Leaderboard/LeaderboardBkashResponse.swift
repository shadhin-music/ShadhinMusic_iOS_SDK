//
//  LeaderboardBkashResponse.swift
//  Shadhin_Gp_Examaple
//
//  Created by MD Murad Hossain  on 6/10/25.
//


import Foundation
struct LeaderboardBkashResponse: Codable {
    let status, message: String
    let data: UserRankingBkashResponse
    let total: Int
    let type, fav, image, follow: String?
    let monthlyListener, name: String?

    enum CodingKeys: String, CodingKey {
        case status, message, data, total, type, fav, image, follow
        case monthlyListener = "MonthlyListener"
        case name
    }
}
// MARK: - DataClass
struct UserRankingBkashResponse: Codable {
    let userStreamingDetails: RankBkashResponse
    let userStreamingDetailsList: [RankBkashResponse]

    enum CodingKeys: String, CodingKey {
        case userStreamingDetails = "UserStreamingDetails"
        case userStreamingDetailsList = "UserStreamingDetailsList"
    }
}
// MARK: - UserStreamingDetails
struct RankBkashResponse: Rank,Codable {
    var userCode: String?
    var userFullName: String?
    var imageURL: String?
    var msisdn: String?
    let userRank: Int
    let timeCountSecond: Int
    let campaignStartDate, joiningDates: String?
    let dateDifferent, joiningDayDifferent, joiningDayBonusHours, dailyBudget: Int?
    let achivableBonus, totalAchivableBonusPoints: Int?
    let dailyStreamCount, dailyStreamRemaining, totalBonus, totalBonusRemaining: Int?

    enum CodingKeys: String, CodingKey {
        case userRank = "UserRank"
        case userCode = "UserCode"
        case timeCountSecond = "TimeCountSecond"
        case campaignStartDate = "CampaignStartDate"
        case joiningDates = "JoiningDates"
        case dateDifferent = "DateDifferent"
        case joiningDayDifferent = "JoiningDayDifferent"
        case joiningDayBonusHours = "JoiningDayBonusHours"
        case dailyBudget = "DailyBudget"
        case achivableBonus = "AchivableBonus"
        case totalAchivableBonusPoints = "TotalAchivableBonusPoints"
        case userFullName = "UserFullName"
        case imageURL = "ImageUrl"
        case msisdn = "Msisdn"
        case dailyStreamCount = "DailyStreamCount"
        case dailyStreamRemaining = "DailyStreamRemaining"
        case totalBonus = "TotalBonus"
        case totalBonusRemaining = "TotalBonusRemaining"
    }
}
