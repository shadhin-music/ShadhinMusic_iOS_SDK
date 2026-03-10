//
//  SubscriptionModel.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 8/21/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import Foundation

enum REGIONS {
    case GLOBAL, MALAYSIA, MIDDLE_EAST
}

struct Subscriptions : Comparable{
    
    var subsTime: String
    var currency: String
    var price: String
    var totalDays: String
    var subTitle : String
    var description : String
    var serviceId : String

    static func < (lhs: Subscriptions, rhs: Subscriptions) -> Bool {
        if let l = Double(lhs.price), let r = Double(rhs.price){
            return l < r
        }
        return false
    }
    
}


