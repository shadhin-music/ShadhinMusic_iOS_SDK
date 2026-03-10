//
//  ShadhinApi+Subscription+Umobile.swift
//  Shadhin
//
//  Created by Gakk Alpha on 10/22/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi{
    
    class Umobile{
        
        public static func getSubscriptionUrl(serviceID: String) -> String{
            return "\(BASE_URL_UMOBILE)/Subscription/?serviceId=\(serviceID)"
        }
        
        public static func getUnsubscriptionUrl(
            msisdn: String = ShadhinCore.instance.defaults.userMsisdn,
            serviceID: String) -> String{
            return "\(BASE_URL_UMOBILE)/UnSubscription/?mobileNo=\(msisdn)&serviceId=\(serviceID)"
        }
        
    }
    
}
