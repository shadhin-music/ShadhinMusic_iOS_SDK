//
//  StripeProductItem.swift
//  Shadhin_Gp_Examaple
//
//  Created by MD Murad Hossain  on 6/10/25.
//


import Foundation

struct StripeProductItem: Codable {
    let id, name, stripeProductID, currency: String
    let unitAmount: Double
    let isAlreadySubscribe: Bool

    enum CodingKeys: String, CodingKey {
        case id, name
        case stripeProductID = "stripeProductId"
        case currency, unitAmount, isAlreadySubscribe
    }
    
    func getSubscription()-> Subscriptions{
        return .init(subsTime: name.capitalizeFirstLetter(), currency: "USD", price: "\(unitAmount)", totalDays: "", subTitle: "\(name.capitalizeFirstLetter())", description: "VAT+SD+SC Excluded • Auto-renewal", serviceId: "\(id)")
    }
}

typealias StripeProductResponse = [StripeProductItem]
