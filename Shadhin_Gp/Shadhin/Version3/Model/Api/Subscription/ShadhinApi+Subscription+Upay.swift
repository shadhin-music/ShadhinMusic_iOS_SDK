//
//  ShadhinApi+Subscription+Upay.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation


extension ShadhinApi{
    
    func getUpaySubscriptionUrl(
        _ serviceId : String,
        completion: @escaping (_ paymentGateway : String?)->Void) {
        
        let json = [
            "MSISDN" : ShadhinCore.instance.defaults.userIdentity,
            "serviceid": serviceId,
            "puser":"up#y!Pg$$k"
        ]
        
        AF.request(
            GET_UPAY_SUB_URL,
            method: .post,
            parameters: json,
            encoding: JSONEncoding.default
        ).responseData { response in
            if case let .success(data) = response.result,
               let value = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                guard let paymentGateway = value["paymentUrl"] as? String else {
                    completion(nil)
                    return
                }
                completion(paymentGateway)
                return
            }
            completion(nil)
        }
    }
}
