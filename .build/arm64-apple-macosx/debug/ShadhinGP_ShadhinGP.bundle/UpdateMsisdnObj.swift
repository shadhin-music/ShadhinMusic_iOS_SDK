//
//  UpdateMsisdnObj.swift
//  Shadhin
//
//  Created by Maruf on 22/1/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import Foundation

struct UpdateMsisdnObj: Codable {
    let message: String?
    let statusCode: Int?
   // let errors: [JSONAny]?

    enum CodingKeys: String, CodingKey {
        case message = "Message"
        case statusCode = "StatusCode"
      //  case errors = "Errors"
    }
}
