//
//  Subscription400Response.swift
//  Shadhin_Gp_Examaple
//
//  Created by MD Murad Hossain  on 6/10/25.
//


import Foundation
// MARK: - Subscription400Response
struct Subscription400Response: Codable {
    let type, title: String
    let status: Int
    let detail, instance, additionalProp1, additionalProp2: String
    let additionalProp3: String
}


struct SubscriptionResponse: Codable {
    let statusCode: Int
    let message: String
    let data: StripeResponse
}

struct StripeResponse: Codable {
    let expiresAt: Int
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case expiresAt = "expires_at"
        case url
    }
}
