//
//  BkashSubHistoryObj.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation
struct BkashSubHistoryObj: Codable {
    let msisdn, serviceid, servicename, chargeamount: String
    let trnasctiondate, subscriptionid, subrequestid, paymentid: String
}
