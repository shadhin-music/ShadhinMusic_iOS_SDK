//
//  ShadhinAPI+StripeSubscription.swift
//  Shadhin
//
//  Created by Joy on 21/5/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import Foundation


extension ShadhinApi{
    class StripeSubscription{
        private static let SUBSCRIPTION_STATUS = "\(BASE_URL_STRIPE)/Billing/subscription-status"
        private static let SUBSCRIPTION_CANCEL = "\(BASE_URL_STRIPE)/Billing/cancel-subscription"
        private static let SUBSCRIPTION_PRODUCTS = "\(BASE_URL_STRIPE)/Billing/products"
        private static let SUBSCRIPTION_REQUEST = "\(BASE_URL_STRIPE)/Checkout/create-checkout-session"
        
        static func getAllStripeProduct(complete : @escaping (Result<StripeProductResponse,AFError>)->Void){
            guard let url = URL(string: SUBSCRIPTION_PRODUCTS) else {
                Log.info("Url invalide")
                return
            }
            let parameters : [String : String] = ["Currency" : "usd","UserCode" : ShadhinCore.instance.defaults.userIdentity]
            var urlRequest = URLRequest(url: url)
            urlRequest.headers = ShadhinApiContants().API_HEADER
            urlRequest.method = .get
            
            do{
                urlRequest =  try URLEncoding.default.encode(urlRequest,with: parameters)
            }catch{
                Log.error(error.localizedDescription)
                return
            }
           
            
            AF.request(urlRequest)
                .responseDecodable(of: StripeProductResponse.self) { response in
                    complete(response.result)
                }
            
        }
        static func getStripSubscriptionStatus(complete : @escaping (Result<StripeStatusResponse,AFError>)->Void){
            guard let url = URL(string: SUBSCRIPTION_STATUS) else {
                Log.info("Url invalide")
                return
            }
            let parameters : [String:String] = ["userCode" : ShadhinCore.instance.defaults.userIdentity]
            var urlRequest = URLRequest(url: url)
            urlRequest.headers = ShadhinApiContants().API_HEADER
            urlRequest.method = .get
            do{
                urlRequest =  try URLEncoding.default.encode(urlRequest,with: parameters)
            }catch{
                Log.error(error.localizedDescription)
                return
            }
           
            AF.request(urlRequest)
                .responseDecodable(of: StripeStatusResponse.self, completionHandler: { response in
                    if let data = response.data, let str = try? String(data: data, encoding: .ascii){
                        Log.info(str)
                    }
                    complete(response.result)
                    switch response.result{
                    case .success(let obj):
                        if let item = obj.data.first{
                            ShadhinCore.instance.defaults.stripeSSLDetails = item
                            ShadhinCore.instance.defaults.isStripeSubscriptionUser = true
                            ShadhinCore.instance.defaults.subscriptionServiceID = item.productID
                            ShadhinCore.instance.defaults.subscriptionIDForStripeAndSSL = item.subscriptionID
                        }
                    case .failure(let error):
                        Log.error(error.localizedDescription)
                    }
                })
        }
        
        static func subscriptionRequest(productId : String,complete :@escaping (Result<SubscriptionResponse,AFError>)->Void){
            guard let url = URL(string: SUBSCRIPTION_REQUEST) else {
                Log.info("Url invalide")
                return
            }
            
            let parameters : [String : String] = ["productId" : productId,"userCode" :ShadhinCore.instance.defaults.userIdentity]
            
            var urlRequest = URLRequest(url: url)
            urlRequest.headers = ShadhinApiContants().API_HEADER
            urlRequest.method = .post
            do{
                urlRequest =  try JSONEncoding.default.encode(urlRequest,with: parameters)
            }catch{
                Log.error(error.localizedDescription)
                return
            }
           
            AF.request(urlRequest)
                .responseDecodable(of: SubscriptionResponse.self) { response in
                    if let data = response.data, let str = try? String(data: data, encoding: .ascii){
                        Log.info(str)
                    }
                    complete(response.result)
                }
        }
        static func subscriptionCancel(subscriptionId : String,complete :@escaping (Result<SubscriptionCancelResponse,AFError>)->Void){
            guard let url = URL(string: SUBSCRIPTION_CANCEL) else {return}
            let parameters : [String : String] = ["subscriptionId" : subscriptionId]
            
            var urlRequest = URLRequest(url: url)
            urlRequest.headers = ShadhinApiContants().API_HEADER
            urlRequest.method = .post
            do{
                urlRequest =  try JSONEncoding.default.encode(urlRequest,with: parameters)
            }catch{
                Log.error(error.localizedDescription)
                return
            }
           
            AF.request(urlRequest)
                .responseDecodable(of: SubscriptionCancelResponse.self) { response in
                    if let data = response.data, let str = try? String(data: data, encoding: .ascii){
                        Log.info(str)
                    }
                    complete(response.result)
                    
                }
        }
    }
}

