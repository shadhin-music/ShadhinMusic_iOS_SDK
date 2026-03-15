//
//  BkashPaymentRequestResponse.swift
//  Shadhin_Gp_Examaple
//
//  Created by MD Murad Hossain  on 6/10/25.
//


import Foundation

struct BkashPaymentRequestResponse: Codable{
    let statusCode: Int?
    let message: String?
    let data: DataClass?
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let paymentURL: String
        enum CodingKeys: String, CodingKey {
            case paymentURL = "paymentUrl"
        }
    }

}
