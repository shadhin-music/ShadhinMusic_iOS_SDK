//
//  SSLPaymentRequestResponse.swift
//  Shadhin_Gp_Examaple
//
//  Created by MD Murad Hossain  on 6/10/25.
//


import Foundation

// MARK: - SSLPaymentRequestResponse
struct SSLPaymentRequestResponse: Codable {
    let status: Bool
    let message: String
    let data: SSLPaymentInfo
}

// MARK: - DataClass
struct SSLPaymentInfo: Codable {
    let status, failedreason, amount, currency: String
    let sessionkey: String
    let redirectGatewayURL: String
    let gatewayPageURL, directPaymentURL: String
    let storeBanner: String
    let storeLogo: String
    let tranID, isMultiAttempt, subscriptionID, subscriptionStatus: String
    let subscriptionError, isDirectPayEnable: String
    let payByNewCardURL: String
    let emiStatus, offerStatus: Int

    enum CodingKeys: String, CodingKey {
        case status, failedreason, amount, currency, sessionkey, redirectGatewayURL, gatewayPageURL, directPaymentURL, storeBanner, storeLogo
        case tranID = "tran_id"
        case isMultiAttempt = "is_multi_attempt"
        case subscriptionID = "subscription_id"
        case subscriptionStatus = "subscription_status"
        case subscriptionError = "subscription_error"
        case isDirectPayEnable = "is_direct_pay_enable"
        case payByNewCardURL
        case emiStatus = "emi_status"
        case offerStatus = "offer_status"
    }
}

