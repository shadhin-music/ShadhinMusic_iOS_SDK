//
//  ShadhinApi+Subscription+Bkash.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation


extension ShadhinApi {
    public func getBkashSubscriptionUrlV2(
        serviceId : String,
        completion : @escaping (_ url : String?, _ error : String?) -> Void) {
            let headers = [
                "Content-Type": "application/json",
                "DeviceType": "iOS"
            ]
            let body = [
                "userCode": ShadhinCore.instance.defaults.userIdentity,
                "serviceId": serviceId
            ]
            AF.request(
                BKASH_TOKEN_GENERATEV2,
                method: .post,
                parameters: body,
                encoding: JSONEncoding.default,
                headers: HTTPHeaders.init(headers)
            ).responseDecodable(of:BkashPaymentRequestResponse.self) { response in
                switch response.result {
                case .success(let data):
                    if let url = data.data?.paymentURL{
                        completion(url, nil)
                    }else{
                        completion(nil, "We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
                    }
                case .failure(_):
                    completion(nil, "We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
                }
            }
            
        }
    
    private func getBkashSubscriptionUrl(
        serviceId : String,
        completion : @escaping (_ url : String?, _ error : String?) -> Void)
    {
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let body = [
            "username" : "bkash@@shadhin",
            "password": "bkash@shadhinG@11",
            "grant_type": "password"
        ]
        AF.request(
            BKASH_TOKEN_GENERATE,
            method: .post,
            parameters: body,
            encoding: URLEncoding.default,
            headers: HTTPHeaders.init(headers)
        ).responseData { response in
            if case let .success(data) = response.result,
               let value = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
               let token = value["access_token"] as? String{
                return self.getBkashSubUrlByToken(serviceId: serviceId, token: token, completion: completion)
            }
            return completion(nil, "Unable to generate token")
        }
    }
    
    private func getBkashSubUrlByToken(
        serviceId : String,
        token : String,
        completion : @escaping (_ url : String?, _ error : String?) -> Void)
    {
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        let body = [
            "MSISDN": ShadhinCore.instance.defaults.userIdentity,
            "serviceid": serviceId,
            "puser":"b@k!Hg$$k"
        ]
        AF.request(
            GET_BKASH_SUB_URL,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: HTTPHeaders.init(headers)
        ).responseData { response in
            if case let.success(data) = response.result,
               let value = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
               let url = value["redirectURL"] as? String,
               var msg = value["errorMessage"] as? String{
                if msg.lowercased().contains("subscription with current date as start date after"){
                    msg = "Dear Customer due to bKash server maintenance process, you will not able to able purchase our premium plan from 11:30 pm to 12am. So please try after 12am."
                }
                return completion(url, msg)
            }
            return completion(nil, "We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
        }
    }
    
    public func cancelBkashSubscriptionV2(
        completion : @escaping (String)-> Void) {
            let body = [
                "userCode":  ShadhinCore.instance.defaults.userIdentity,
                "serviceId": ShadhinCore.instance.defaults.subscriptionServiceID,
            ]
            guard let url = URL(string: CANCEL_BKASH_SUBV2), let jsonBodyData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted),
                  let jsonBodyString = String(data: jsonBodyData,encoding: .utf8),
                  let encryptedJsonBodyString = CryptoCBC.shared.encryptMessage(message: jsonBodyString, encryptionKey: ShadhinApi.cancel_secretKey , iv: ShadhinApi.cancel_iv_secret),
                  let data = "\"\(encryptedJsonBodyString)\"".data(using: .utf8)
            else {return}
            
            var urlRequest = URLRequest(url: url)
            urlRequest.method = .post
            urlRequest.httpBody = data
            urlRequest.headers.add(.init(name: "x-api-key", value: "Sv0390cf388d6bc429d9fd09741b0abf7c8T"))
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            AF.request(urlRequest).responseData { response in
                if let data = response.data, let str = String(data: data, encoding: .utf8){
                    Log.info(str)
                }
                if case let .success(data) = response.result,
                   let value = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                   let message = value["message"] as? String{
                    return completion(message)
                }
                return completion("We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
            }
        }
    
    private func cancelBkashSubscription(
        completion : @escaping (String)-> Void)
    {
        
        let body = [
            "MSISDN":  ShadhinCore.instance.defaults.userIdentity,
            "serviceid": ShadhinCore.instance.defaults.subscriptionServiceID,
        ]
        guard let url = URL(string: CANCEL_BKASH_SUB), let jsonBodyData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted),
              let jsonBodyString = String(data: jsonBodyData,encoding: .utf8),
              let encryptedJsonBodyString = CryptoCBC.shared.encryptMessage(message: jsonBodyString, encryptionKey: ShadhinApi.cancel_secretKey , iv: ShadhinApi.cancel_iv_secret),
              let data = "\"\(encryptedJsonBodyString)\"".data(using: .utf8)
        else {return}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.method = .post
        urlRequest.httpBody = data
        urlRequest.headers.add(.init(name: "x-api-key", value: "Sv0390cf388d6bc429d9fd09741b0abf7c8T"))
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        AF.request(urlRequest).responseData { response in
            if let data = response.data, let str = String(data: data, encoding: .utf8){
                Log.info(str)
            }
            if case let .success(data) = response.result,
               let value = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
               let response = value["response"] as? String{
                return completion(response)
            }
            return completion("We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
        }
    }
    
    func getBkashSubscriptionHistory(
        completion : @escaping ([BkashSubHistoryObj])-> Void)
    {
        let body = [
            "MSISDN":  ShadhinCore.instance.defaults.userIdentity,
        ]
        AF.request(
            BKASH_SUB_HISTORY,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default
        ).responseDecodable(of: [BkashSubHistoryObj].self) { response in
            switch response.result{
            case let .success(data):
                completion(data)
            case let .failure(error):
                Log.error(error.localizedDescription)
                completion([])
            }
        }
    }
    
    func getBkashSubscriptionInfoBySubscriptionID(
        subreqid : String,
        completion : @escaping (BkashSubscriptionInfoObj?)-> Void)
    {
        AF.request(
            GET_BKASH_SUB_INFO_BY_SUBID(subreqid),
            method: .get,
            encoding: JSONEncoding.default
        ).responseDecodable(of: BkashSubscriptionInfoObj.self) { response in
            switch response.result{
            case let .success(data):
                completion(data)
            case let .failure(error):
                completion(nil)
                Log.error(error.localizedDescription)
            }
        }
    }
    
    
    func getBkashPaymentInfoByPaymentID(
        paymentid : String,
        completion : @escaping (PaymentInfoObj?)-> Void)
    {
        AF.request(
            GET_BKASH_PAY_INFO_BY_PAYID(paymentid),
            method: .get,
            encoding: JSONEncoding.default
        ).responseDecodable(of: PaymentInfoObj.self){ response in
            switch response.result{
            case let .success(data):
                completion(data)
            case let .failure(error):
                completion(nil)
                Log.error(error.localizedDescription)
            }
        }
    }
}
