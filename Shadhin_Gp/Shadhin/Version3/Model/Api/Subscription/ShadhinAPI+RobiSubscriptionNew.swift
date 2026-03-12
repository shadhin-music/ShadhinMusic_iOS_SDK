//
//  ShadhinAPI+ROBISubscriptionNew.swift
//  Shadhin
//
//  Created by Maruf on 27/5/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import Foundation


extension ShadhinApi {
    
    class RobiSubscription {
        
        private static let ROBI_DOB_OTP_REQUEST_URL = "\(BASE_URL_PAYMENT)/robi/DOBBilling/send_otp"
        private static let ROBI_DOB_VERIFY_OTP_URL = "\(BASE_URL_PAYMENT)/robi/DOBBilling/verify_otp"
        private static let ROBI_DOB_CANCEL_SUBSCRIPTION_URL = "\(BASE_URL_PAYMENT)/robi/DOBBilling/cancel_subscription"
        
        ///payment request with service id
        ///this request works for ROBI user only
        static func requestRobiSubOTP(
            _ serviceId : String,
            _ completion: @escaping (Result<String,AFError>)->Void)
        {
            guard let url = URL(string: ROBI_DOB_OTP_REQUEST_URL) else{
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
                .responseDecodable(of: RobiDobResponse.self) { response in
                    switch response.value{
                    case .some(let result):
                        completion(.success(result.message))
                    case .none:
                        if let error = response.error{
                            print(error)
                            completion(.failure(error))
                        }else{
                            completion(.success("server error"))
                            Log.error(response.error?.localizedDescription ?? "error occur")
                        }
                    }
                }
            
        }
        
        ///check otp for payment confirmation
        ///this method for ROBI user only
        static func checkRobiSubOTP(
            _ serviceId : String,
            _ otp : String,
            _ completion: @escaping (Result<String,AFError>)->Void)
        {
            guard let url = URL(string: ROBI_DOB_VERIFY_OTP_URL) else {
                Log.error("Url make error")
                return
            }
            
            let body : [String:String] =   ["msisdn":ShadhinCore.instance.defaults.userMsisdn,
                                            "serviceid":serviceId,
                                            //"ConsentNo":otp
                                            "otp":otp
            ]
            let json = try? JSONSerialization.data(withJSONObject: body)
            
            var urlRequest = URLRequest(url: url)
            urlRequest.method = .post
            urlRequest.httpBody = json
            urlRequest.headers = ShadhinApiContants().API_HEADER
            
            AF.request(urlRequest)
                .responseDecodable(of: RobiPaymentRequestResponse.self) { response in
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
        
        ///cancel subscription
        ///this method only for ROBI user
        ///
        static func cancelRobiSub(
            _ completion: @escaping (Result<String,AFError>)-> Void)
        {
            guard let url = URL(string: ROBI_DOB_CANCEL_SUBSCRIPTION_URL) else {
                Log.error("Url make error")
                return
            }
            let body : [String:String] =  ["msisdn":ShadhinCore.instance.defaults.userMsisdn,
                                           "serviceid":ShadhinCore.instance.defaults.subscriptionServiceID]
            print(body)
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
                        print(data)
                        completion(.success(data))
                    case let .failure(error):
                        print(error)
                        completion(.failure(error))
                    }
                }
        }
    }
}
