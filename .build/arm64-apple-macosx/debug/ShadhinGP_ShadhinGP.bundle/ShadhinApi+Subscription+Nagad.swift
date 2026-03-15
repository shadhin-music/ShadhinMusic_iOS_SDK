//
//  ShadhinApi+Subscription+Nagad.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi{
    
    func getNagadSubscriptionUrl(
        _ serviceId: String,
        completion : @escaping (_ url: String?, _ msg:String?)->Void)
    {
            
        let body = [
            "MSISDN": ShadhinCore.instance.defaults.userMsisdn,
            "serviceid": serviceId,
            "puser": "n@g!dG$kk"
        ]

        AF.request(
            GET_NAGAD_SUB_URL,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default
        ).responseData { response in
            switch response.result{
            case let .success(data):
                if let value = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                   let url = value["paymentUrl"] as? String,
                   let msg = value["errorMessage"] as? String{
                    return completion(url, msg)
                }
                return completion(nil, "Data format error")
            case let .failure(error):
                completion(nil,"We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
                Log.error(error.localizedDescription)
            }
        }
    }

    
}
