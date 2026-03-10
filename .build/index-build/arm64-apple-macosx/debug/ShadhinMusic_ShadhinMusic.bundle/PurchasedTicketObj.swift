//
//  PurchasedTicketObj.swift
//  Shadhin
//
//  Created by Gakk Alpha on 9/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation


struct PurchasedTicketObj: Codable {
    let message: String?
    let data: [Data]

    enum CodingKeys: String, CodingKey {
        case message, data
    }
    
    struct Data: Codable {
        let userName, phonenumber, userEmail, ticketNo: String?
        let campaignDate, campaignTime, ticketType, venueName: String?
        let venueHall, barcode: String?
    }
}

