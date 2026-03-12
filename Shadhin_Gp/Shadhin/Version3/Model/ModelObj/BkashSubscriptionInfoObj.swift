//
//  BkashSubscriptionInfoObj.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation
struct BkashSubscriptionInfoObj: Codable {
    let id: Int
    let createdAt, modifiedAt, subscriptionRequestID: String
    let requesterID, serviceID: Int
    let paymentType, subscriptionType: String
    let amountQueryURL: String?
    let amount, firstPaymentAmount: Int
    let maxCapRequired: Bool
    let maxCapAmount: Int?
    let frequency, startDate, expiryDate: String
    let merchantID: Int
    let payerType, payer, currency, nextPaymentDate: String
    let status, subscriptionReference: String
    let extraParams: ExtraParams?
    let cancelledBy, cancelledTime: String?
    let expired, enabled: Bool
    let rrule: String
    let active: Bool

    enum CodingKeys: String, CodingKey {
        case id, createdAt, modifiedAt
        case subscriptionRequestID = "subscriptionRequestId"
        case requesterID = "requesterId"
        case serviceID = "serviceId"
        case paymentType, subscriptionType
        case amountQueryURL = "amountQueryUrl"
        case amount, firstPaymentAmount, maxCapRequired, maxCapAmount, frequency, startDate, expiryDate
        case merchantID = "merchantId"
        case payerType, payer, currency, nextPaymentDate, status, subscriptionReference, extraParams, cancelledBy, cancelledTime, expired, enabled, rrule, active
    }

    struct ExtraParams: Codable {
        let cancellationReason: String
    }
}
