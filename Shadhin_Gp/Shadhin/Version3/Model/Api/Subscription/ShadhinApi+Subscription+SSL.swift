//
//  ShadhinApi+Subscription+SSL.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation


extension ShadhinApi{
    
    func getSSLSubcriptionUrl(
        _ amount : String,
        completion: @escaping (_ paymentGateway : String?)->Void) {
        
        let user = "ShadhinSSLApp20"
        let password = "Gakk@@SSL_Commz.456!"
        let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        
        let json = [
            "cus_phone" : ShadhinCore.instance.defaults.userIdentity,
            "total_amount" : amount
        ]
        
        AF.request(
            GET_SSL_SUB_URL,
            method: .post,
            parameters: json,
            encoding: JSONEncoding.default,
            headers: HTTPHeaders.init(headers)
        ).responseData { response in
            if case let .success(data) = response.result,
               let value = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                guard let paymentGateway = value["GatewayPageURL"] as? String else {
                    completion(nil)
                    return
                }
                return completion(paymentGateway)
            }
            completion(nil)
        }
    }
}
