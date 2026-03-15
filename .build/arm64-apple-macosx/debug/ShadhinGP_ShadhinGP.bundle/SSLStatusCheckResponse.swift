//
//  SSLStatusCheckResponse.swift
//  Shadhin_Gp_Examaple
//
//  Created by MD Murad Hossain  on 6/10/25.
//


import Foundation

// MARK: - SSLStatusCheckResponse
struct SSLStatusCheckResponse: Codable {
    let status: Bool
    let message: String?
    let data: SSLStatus?
}

// MARK: - DataClass
struct SSLStatus: Codable {
    let status, serviceID, subscriptionID: String

    enum CodingKeys: String, CodingKey {
        case status
        case serviceID = "serviceId"
        case subscriptionID = "subscriptionId"
    }
}
