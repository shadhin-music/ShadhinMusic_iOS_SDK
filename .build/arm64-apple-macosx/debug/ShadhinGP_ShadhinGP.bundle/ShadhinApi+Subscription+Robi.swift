//
//  ShadhinApi+Subscription+Robi.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation


extension ShadhinApi{
    
    func getRobiSubcriptionUrl(_ msisdn: String = ShadhinCore.instance.defaults.userMsisdn, serviceId: String)->String{
        return GET_ROBI_SUB(msisdn, serviceId)
    }
    
    func getRobiSubsriptionUrl(_ msisdn: String = ShadhinCore.instance.defaults.userMsisdn, serviceId: String, _ completion: @escaping (_ url: String?,_ error: String?)->Void){
        let body = [
            "MSISDN":  ShadhinCore.instance.defaults.userMsisdn,
            "ServiceId": serviceId,
            "ChargeType": "SMS",
            "CallBackUrl": "https://www.robicallback.com"
        ]
        
        AF.request(
            GET_ROBI_SUB_V2,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: ShadhinApiContants().API_HEADER
        ).responseData { response in
            switch response.result{
            case let .success(data):
                if let value = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                   let data = value["data"] as? [String : Any],
                   let url = data["paymentUrl"] as? String{
                    return completion(url, nil)
                }
                return completion(nil,"We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
            case let .failure(error):
                completion(nil,"We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
                Log.error(error.localizedDescription)
            }
        }
    }
    /// Amin vai cancel
    @available(*,deprecated, message: "This method is deprecated after Amin digester, Use Pias version for cancel 'cancelRobiSubscriptionNew'")
    func cancelRobiSubscription(
        _ completion: @escaping (_ msg: String)->Void)
    {
        let URL = CANCEL_ROBI_SUB(ShadhinCore.instance.defaults.userMsisdn, ShadhinCore.instance.defaults.subscriptionServiceID)
        AF.request(
            URL,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: nil
        ).responseString{ response in
            switch response.result{
            case let .success(data):
                completion(data)
            case .failure(_):
                completion("We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
            }
        }
    }
    /// Pias Uddin cancel
    func cancelRobiSubscriptionNew(
        _ completion: @escaping (_ msg: String)->Void)
    {
        let URL = URL(string: CANCEL_ROBI_V2)
        let parameter : [String : String] = [
            "MSISDN" : ShadhinCore.instance.defaults.userMsisdn,
            "ServiceId" : ShadhinCore.instance.defaults.subscriptionServiceID
        ]
        
        guard let jsonBodyData = try? JSONSerialization.data(withJSONObject: parameter, options: .prettyPrinted),
              let jsonBodyString = String(data: jsonBodyData,encoding: .ascii),
              let encryptedJsonBodyString = CryptoCBC.shared.encryptMessage(message: jsonBodyString, encryptionKey: ShadhinApi.cancel_secretKey , iv: ShadhinApi.cancel_iv_secret),
              let data = "\"\(encryptedJsonBodyString)\"".data(using: .utf8)
        else {return}
        
        var request = URLRequest(url: URL!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.headers.add(.init(name: "x-api-key", value: "Sv0390cf388d6bc429d9fd09741b0abf7c8T"))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        AF.request(request)
            .responseString { response in
                switch response.result{
                case let .success(data):
                    completion(data)
                case .failure(_):
                    completion("We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
                }
            }
    }
}
