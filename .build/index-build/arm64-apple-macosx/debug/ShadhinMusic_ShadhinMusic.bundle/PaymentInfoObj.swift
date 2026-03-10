//
//  PaymentInfoObj.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation
struct PaymentInfoObj: Codable {
    let id, subscriptionID: Int
    let dueDate, status, trxID, trxTime: String
    let amount: Int
    let reverseTrxAmount, reverseTrxID, reverseTrxTime: String?

    enum CodingKeys: String, CodingKey {
        case id
        case subscriptionID = "subscriptionId"
        case dueDate, status
        case trxID = "trxId"
        case trxTime, amount, reverseTrxAmount
        case reverseTrxID = "reverseTrxId"
        case reverseTrxTime
    }
}
