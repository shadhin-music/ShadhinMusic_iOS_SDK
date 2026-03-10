//
//  RBTModel.swift
//  Shadhin_Gp
//
//  Created by Maruf on 2/2/26.
//

import Foundation

// MARK: - Main Response Model
struct RBTSubscriptionResponse: Codable {
    let value: ResponseValue
    let statusCode: Int
}

// MARK: - Response Value
struct ResponseValue: Codable {
    let data: [RBTSubscriptionPlan]
    let message: String
    let success: Bool
    let responseCode: Int
    let title: String
    let error: String?
}

// MARK: - Subscription Plan
struct RBTSubscriptionPlan: Codable {
    let id: String
    let price: Double
    let priceId: String?
    let duration: Int
    let isAutoRenewal: Bool
    let `operator`: String

    enum CodingKeys: String, CodingKey {
        case id
        case price
        case priceId
        case duration
        case isAutoRenewal
        case `operator`
    }
}


struct WelcomeTuneResponse: Codable {
    let message: String?
    let success: Bool
    let responseCode: Int
    let title: String
    let data: String?
    let error: APIErrorModel?
}

struct APIErrorModel: Codable {
    let source: String?
    let message: String?
    let details: String?
    let errorCode: String?
}


