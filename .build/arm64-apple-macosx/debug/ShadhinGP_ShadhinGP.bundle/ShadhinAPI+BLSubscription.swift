//
//  ShadhinAPI+BL_Subscription.swift
//  Shadhin
//
//  Created by Joy on 26/12/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation


extension ShadhinApi{
     
    ///BL Subscription check class
    class BLSubscription{
        private static let PAYMENT_CHECK_URL   = "\(BASE_URL_1)/paymentreqShadhin"
        private static let OTP_CHECK           = "\(BASE_URL_1)/paymentreqConsentShadhin"
        private static let SUBSCRIPTION_CHECK  = "\(BASE_URL_1)/substatusShadhin"
        private static let CANCEL_SUBSCRIPTION = "\(BASE_URL_1)/paymentcancelShadhin"
        
        private static let REQUEST_OTP_V2         = "\(BASE_URL_PAYMENT)/banglalink/checkout/create-checkout-session"
        private static let CANCEL_SUBSCRIPTION_V2 = "\(BASE_URL_PAYMENT)/banglalink/billing/cancel-subscription"
        private static let OTP_CHECK_V2           = "\(BASE_URL_PAYMENT)/banglalink/checkout/verify-checkout-session"
        
        
        ///payment request with service id
        ///this request works for BL user only
        static func requestBLSubOTP(
            _ serviceId : String,
            _ completion: @escaping (Result<String,AFError>)->Void)
        {
            guard let url = URL(string: REQUEST_OTP_V2) else{
                Log.error("URL make error")
                return
            }
            //make request body
            let body : [String : String] = [
                "msisdn"  : ShadhinCore.instance.defaults.userMsisdn,
                "serviceid" : serviceId
            ]
            let json = try? JSONSerialization.data(withJSONObject: body)
            
            //make url request
            var urlRequest = URLRequest(url: url)
            urlRequest.method = .post
            urlRequest.httpBody = json
            urlRequest.headers = ShadhinApiContants().API_HEADER
            
            AF.request(urlRequest)
                .responseDecodable(of: BLPaymentRequestResponse.self) { response in
                    switch response.value{
                    case .some(let result):
                        completion(.success(result.message ?? "Response empty"))
                    case .none:
                        if let error = response.error{
                            completion(.failure(error))
                        }else{
                            completion(.success("server error"))
                            Log.error(response.error?.localizedDescription ?? "error occur")
                        }
                    }
                }
            
        }
        
        ///check otp for payment confirmation
        ///this method for BL user only
        static func checkBLSubOTP(
            _ serviceId : String,
            _ otp : String,
            _ completion: @escaping (Result<String,AFError>)->Void)
        {
            guard let url = URL(string: OTP_CHECK_V2) else {
                Log.error("Url make error")
                return
            }
            
            let body : [String:String] =   ["msisdn":ShadhinCore.instance.defaults.userMsisdn,
                                            "serviceid":serviceId,
                                            "ConsentNo":otp]
            let json = try? JSONSerialization.data(withJSONObject: body)
            
            var urlRequest = URLRequest(url: url)
            urlRequest.method = .post
            urlRequest.httpBody = json
            urlRequest.headers = ShadhinApiContants().API_HEADER
            
            AF.request(urlRequest)
                .responseDecodable(of: BLPaymentRequestResponse.self) { response in
                    switch response.value{
                    case .some(let result):
                        completion(.success(result.message ?? "Response Empty!"))
                    case .none:
                        if let error = response.error{
                            completion(.failure(error))
                        }else{
                            Log.error(response.error?.localizedDescription ?? "error occur")
                        }
                    }
                }
        }
        
        ///subscription status check
        ///this method only for BL user
        ///
        static func paymentStatus(
            _ completion : @escaping (Result<Bool,AFError>)-> Void)
        {
            guard let url = URL(string: SUBSCRIPTION_CHECK) else {
                Log.error("Url make error")
                return
            }
            let body : [String:String] =  ["msisdn":ShadhinCore.instance.defaults.userMsisdn,
                                           "serviceid":ShadhinCore.instance.defaults.subscriptionServiceID]
            let json = try? JSONSerialization.data(withJSONObject: body)
            
            var urlRequest = URLRequest(url: url)
            urlRequest.method = .post
            urlRequest.httpBody = json
            urlRequest.headers = ShadhinApiContants().API_HEADER
            
            AF.request(urlRequest)
                .responseString { response in
                    guard let result = response.value else{
                        if let error = response.error{
                            completion(.failure(error))
                        }
                        return
                    }
                    if result.elementsEqual("1BL"){
                        completion(.success(true))
                    }else{
                        completion(.success(false))
                    }
                }
        }
        
        ///cancel subscription
        ///this method only for BL user
        ///
        static func cancelBLSub(
            _ completion: @escaping (Result<String,AFError>)-> Void)
        {
            guard let url = URL(string: CANCEL_SUBSCRIPTION_V2) else {
                Log.error("Url make error")
                return
            }
            let body : [String:String] =  ["msisdn":ShadhinCore.instance.defaults.userMsisdn,
                                           "serviceid":ShadhinCore.instance.defaults.subscriptionServiceID]
            guard let jsonBodyData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted),
                  let jsonBodyString = String(data: jsonBodyData,encoding: .ascii),
                  let encryptedJsonBodyString = CryptoCBC.shared.encryptMessage(message: jsonBodyString, encryptionKey: ShadhinApi.cancel_secretKey , iv: ShadhinApi.cancel_iv_secret),
                  let data = "\"\(encryptedJsonBodyString)\"".data(using: .utf8)
            else {return}
            
            
            var urlRequest = URLRequest(url: url)
            urlRequest.method = .post
            urlRequest.headers.add(.init(name: "x-api-key", value: "Sv0390cf388d6bc429d9fd09741b0abf7c8T"))
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = data
            
            AF.request(urlRequest)
                .responseString { response in
                    switch response.result{
                    case let .success(data):
                        completion(.success(data))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
        }
    }
}
