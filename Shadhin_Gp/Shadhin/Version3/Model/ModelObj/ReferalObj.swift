//
//  ReferalObj.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/22/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

struct ReferalObj: Codable {
    let status, message: String
    let data: Data
    
    // MARK: - Data
    struct Data: Codable {
        let referralCode, points, currentLevelPoints, pointsLevel: String
        let levelTarget, levelState, totalReferrals, campaignMessage: String
        let isCampaign: Bool

        enum CodingKeys: String, CodingKey {
            case referralCode = "ReferralCode"
            case points = "Points"
            case currentLevelPoints = "CurrentLevelPoints"
            case pointsLevel = "PointsLevel"
            case levelTarget = "LevelTarget"
            case levelState = "LevelState"
            case totalReferrals = "TotalReferrals"
            case isCampaign = "IsCampaign"
            case campaignMessage = "CampaignMessage"
        }
    }

}
