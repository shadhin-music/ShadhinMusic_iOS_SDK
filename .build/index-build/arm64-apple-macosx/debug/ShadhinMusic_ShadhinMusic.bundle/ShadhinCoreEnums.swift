//
//  ShadhinCoreEnums.swift
//  Shadhin
//
//  Created by Joy on 26/12/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

enum BL_SUBSCRIPTION_SERVICEID : String{
    case DAILY = "9917710001"
    case MONTHLY = "9917710002"
    case HALF_YEAR = "9917710003"
    case YEARLY = "9917710004"
    case unknown
    
    init?(rawValue: String) {
        switch rawValue{
        case "9917710001":
            self = .DAILY
        case "9917710002":
            self = .MONTHLY
        case "9917710003":
            self = .HALF_YEAR
        case "9917710004":
            self = .YEARLY
        default:
            self = .unknown
        }
    }
}
