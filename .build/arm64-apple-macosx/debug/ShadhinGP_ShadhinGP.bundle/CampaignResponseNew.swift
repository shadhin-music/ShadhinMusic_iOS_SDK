//
//  CampaignResponseNew.swift
//  Shadhin_Gp_Examaple
//
//  Created by MD Murad Hossain  on 6/10/25.
//


import Foundation

struct CampaignResponseNew: Codable {
    let success: Bool
    let responseCode: Int
    let title: String
    let data: CampaignData?
    let error: CampaignError?
}

// MARK: - CampaignData (Handles different structures)
enum CampaignData: Codable {
    case campaign(CampaignWrapper)
    case singleCampaign(Campaign)
    case multipleCampaigns([SimpleCampaign])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let campaign = try? container.decode(CampaignWrapper.self) {
            self = .campaign(campaign)
        } else if let singleCampaign = try? container.decode(Campaign.self) {
            self = .singleCampaign(singleCampaign)
        } else if let multipleCampaigns = try? container.decode([SimpleCampaign].self) {
            self = .multipleCampaigns(multipleCampaigns)
        } else {
            throw DecodingError.typeMismatch(CampaignData.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Data type mismatch"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .campaign(let campaign):
            try container.encode(campaign)
        case .singleCampaign(let singleCampaign):
            try container.encode(singleCampaign)
        case .multipleCampaigns(let multipleCampaigns):
            try container.encode(multipleCampaigns)
        }
    }
}

// MARK: - Wrapper for Campaign
struct CampaignWrapper: Codable {
    let campaign: Campaign
    let userStreamings: [UserStreaming]?
}

// MARK: - Campaign Model
struct Campaign: Codable {
    let id: Int?
    let title: String
    let description: String
    let imageUrl: String
    let imageUrlWeb: String?
    let operatorId: Int?
    let operatorTitle: String?
    let operatorIconUrl: String?
    let frequencies: [Int]?
    let startDate: String?
    let endDate: String?
    let leaderboardTop: Int?
    let topStreamingTitle: String?
    let tnCUrl: String?
    let faqUrl: String?
    let segments: [CampaignSegmentData]?
    let prizes: [Prize]?
}

// MARK: - Simplified Campaign Model for List
struct SimpleCampaign: Codable {
    let title: String
    let description: String
    let imageUrl: String
    let imageUrlWeb: String?
    let operators: [OperatorInfo]?
}

// MARK: - Operator Model
struct OperatorInfo: Codable {
    let id: Int
    let campaignId: Int
    let title: String
    let iconUrl: String
}

// MARK: - Campaign Segment
struct CampaignSegmentData: Codable {
    let id: Int
    let startDate: String
    let endDate: String
    let hours: Int
    let seconds: Int
}

// MARK: - Prize Model
struct Prize: Codable {
    let id: Int
    let title: String
    let description: String
    let imageUrl: String
    let sort: Int
}

// MARK: - User Streaming Model
struct UserStreaming: Codable {
    let isCurrentUser: Bool
    let rank: Int
    let msisdn: String
    let fullname: String
    let imageUrl: String
    let totalStreaming: Int
    let bonusLimit: Int
    let bonsuStreaming: Int
    let remainingBonusStreaming: Int
    let streamingLimit: Int
    let currentStreaming: Int
    let remainingDailyStreaming: Int
}

// Error handaling
struct CampaignError: Codable {
    let source: String?
    let message: String?
    let details: String?
    let errorCode: String?
}
