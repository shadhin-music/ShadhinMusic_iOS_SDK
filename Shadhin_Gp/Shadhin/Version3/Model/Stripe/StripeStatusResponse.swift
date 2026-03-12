//
//  StripeStatusResponse.swift
//  Shadhin_Gp_Examaple
//
//  Created by MD Murad Hossain  on 6/10/25.
//


import Foundation

struct StripeStatusResponse: Codable {
    let statusCode: Int
    let message: String
    let data: [StripeStatus]
}

// MARK: - Datum
struct StripeStatus: Codable {
    let status, productID, subscriptionID: String

    enum CodingKeys: String, CodingKey {
        case status
        case productID = "productId"
        case subscriptionID = "subscriptionId"
    }
}
