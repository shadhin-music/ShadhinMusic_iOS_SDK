//
//  NewSubscriptionResponseObj.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 15/4/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import Foundation

struct NewSubscriptionResponseObj: Codable {
    let success: Bool
    let responseCode: Int
    let title: String
    var data: [Plan]
    let error: String?
}

struct Plan: Codable {
    let planName: String
    let durationInDays: Int
    let currencySymbol: String
    var items: [Item]
}

struct Item: Codable {
    let subscriptionType: String
    let isMobileOperator: Int
    let isMostPopular: Int
    let planPrice: Double
    let operatorName: String
    let paymentOptionName: String
    let planId: Int
    let icon: String?
    
    enum CodingKeys: String, CodingKey {
        case subscriptionType
        case isMobileOperator
        case isMostPopular
        case planPrice
        case operatorName = "operator"
        case paymentOptionName
        case planId
        case icon
    }
}

struct PaymentMethodSuccessResponseObj: Codable {
    let success: Bool
    let responseCode: Int
    let title: String
    let data: [PaymentMethodObj]
    let error: String?
}

struct PaymentMethodObj: Codable {
    let icon: String
    let methodName: String
    let checkOutUrl: String
    let serviceId: String
    let isOtpBased: Bool
    let otpCheckUrl: String?
}

struct SubscriptionDetailsResponseOBj: Codable {
    var success: Bool?
    var responseCode: Int?
    var title: String?
    var data: [SubscriptionDetail]?
    var error: String?
}

struct ErrorResponseObj: Codable {
    let success: Bool
    let responseCode: Int
    let title: String
    let data: ErrorDetail?
    let error: ErrorInfo
}

struct ErrorDetail: Codable {
    let source: String
    let message: String
    let details: String
}

struct ErrorInfo: Codable {
    let source: String
    let message: String
    let details: String
}

struct PlanDetailModel: Codable {
    let success: Bool
    let responseCode: Int
    let title: String
    let data: PlanDetailResponseData?
    let error: String?
}

struct PlanDetailResponseData: Codable {
    let icon: URL
    let methodName: String
    let checkOutUrl: String?
    let serviceId: String
    let isOtpBased: Bool
    let otpCheckUrl: String?
    let otpLength: Int?
}

struct OTPResponseModel: Codable {
    let statusCode: Int
    let message: String
    let data: OTPResponseData?
}

struct OTPResponseData: Codable {
    let expireAt: String?
    let adsId: Int?
    let transactionId: String?
}


struct PaymentData: Codable {
    let paymentUrl: String
    let requestId: String?
}

// Define the main response structure
struct PaymentResponseModel: Codable {
    let statusCode: Int
    let message: String
    let data: PaymentData
}

struct SubscriptionDetail: Codable {
    var serviceId: String?
    var regStatus: Int?
    var regDate: String?
    var expireDate: String?
    var expiryUnixTimestamp: Int?
    var isRenewal: Bool?
    var serviceName: String?
    var planType: String?
    var planStatus: String?
    var `operator`: String?
    var cancelSubscriptionUrl: String?
    var renewSubscriptionUrl: String?
    var isApiCallForCancel: Bool?
    var chargeAmount: Double?
    var currencySymbol: String?
    var durationInDay: Int?
    var isExpired: Bool?
    var msisdn: String?
    
    static func getMockSubscriptionDetail() -> SubscriptionDetail {
        return SubscriptionDetail(
            serviceId: "com.example.service",
            regStatus: 1,
            regDate: "2024-08-18",
            expireDate: "2024-09-18",
            expiryUnixTimestamp: 1694995200, // Corresponding to 2024-09-18
            isRenewal: true,
            serviceName: "Premium Service",
            planType: "Monthly",
            planStatus: "Active",
            operator: "Operator XYZ",
            cancelSubscriptionUrl: "https://example.com/cancel",
            renewSubscriptionUrl: "https://example.com/renew",
            isApiCallForCancel: true,
            chargeAmount: 9.99,
            currencySymbol: "$",
            durationInDay: 30,
            isExpired: false,
            msisdn: "8801784818346"
        )
    }
}

struct CancelSubscriptionModel: Codable {
    var statusCode: Int?
    var message: String?
}

struct RenewSubscriptionModel: Codable {
    //TODO: TANVIR KNOW MODE
    var statusCode: Int?
    var message: String?
}
