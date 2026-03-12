//
//  TicketPurchaseUrlObj.swift
//  Shadhin
//
//  Created by Gakk Alpha on 9/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

struct TicketPurchaseUrlObj: Codable {
    let message: String?
    let data: Data?

    enum CodingKeys: String, CodingKey {
        case message, data
    }
    
    struct Data: Codable {
        let gatewayPageURL: String?
        let bkashURL: String?
        let errorMessage, purchaseCode: String?
        var getUrl: String?{
            get{
                if gatewayPageURL != nil{
                    return gatewayPageURL
                }else{
                    return bkashURL
                }
            }
        }

        enum CodingKeys: String, CodingKey {
            case gatewayPageURL = "GatewayPageURL"
            case bkashURL
            case errorMessage, purchaseCode
        }
    }

}

