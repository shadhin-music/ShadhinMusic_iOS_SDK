//
//  ShadhinAPI+SSLSubscription.swift
//  Shadhin
//
//  Created by Joy on 30/5/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import Foundation


extension ShadhinApi{
    class SSLSubscription{
        
        private static let SSL_SUBSCRIPTION = "\(BASE_URL_SSL)/api/SSLPayment/CreatePayment"
        private static let SSL_CANCEL_SUBSCRIPTION = "\(BASE_URL_SSL)/api/SSLPayment/CancelSubscription"
        private static let SSL_STATUS_CHECK = "\(BASE_URL_SSL)/api/SubAction/SubscriptionStatus"
        
        static func subscriptionRequest(complete : @escaping (Result<SSLPaymentRequestResponse,AFError>)-> Void){
            guard let url = URL(string: SSL_SUBSCRIPTION) else{
                return
            }
            
            let parameter  = [
                "userCode": ShadhinCore.instance.defaults.userIdentity,
                "serviceId": "200001"
              ]
            
            var urlRequest = URLRequest(url: url)
            urlRequest.method =  .post
            urlRequest.headers = ShadhinCore.instance.api.API_HEADER
            do{
                urlRequest =  try JSONEncoding.default.encode(urlRequest,with: parameter)
            }catch{
                Log.error(error.localizedDescription)
                return
            }
            
            AF.request(urlRequest)
                .responseDecodable(of: SSLPaymentRequestResponse.self) { response in
                    complete(response.result)
                }
        }
        static func sslSubscriptionCancel(id : String,complete : @escaping (Result<SSLCancelResponse,AFError>)->Void){
            guard let url = URL(string: SSL_CANCEL_SUBSCRIPTION) else{
                return
            }
            let parameters = ["subscriptionId"  : id]
            
            var urlRequest = URLRequest(url: url)
            urlRequest.method =  .post
            urlRequest.headers = ShadhinCore.instance.api.API_HEADER
            do{
                urlRequest = try JSONEncoding.default.encode(urlRequest,with: parameters)
            }catch{
                Log.error(error.localizedDescription)
                return
            }
            
            AF.request(urlRequest)
                .responseDecodable(of: SSLCancelResponse.self) { response in
                    if let data = response.data, let str = try? String(data: data, encoding: .ascii){
                        Log.info(str)
                    }
                    complete(response.result)
                }
            
        }
        
        static func getSSLSubscriptionStatus(complete : @escaping (Result<SSLStatusCheckResponse,AFError>)->Void){
            guard let url = URL(string: SSL_STATUS_CHECK) else{
                return
            }
            let parameters = ["userCode"  : ShadhinCore.instance.defaults.userIdentity]
            
            var urlRequest = URLRequest(url: url)
            
            do{
                urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
            }catch{
                Log.error(error.localizedDescription)
                return
            }
            
            AF.request(urlRequest)
                .responseDecodable(of: SSLStatusCheckResponse.self) { response in
                    if let data = response.data, let str = try? String(data: data, encoding: .ascii){
                        Log.info(str)
                    }
                    complete(response.result)
                }
        }
    }
}
