//
//  ShadhinApi+Subscription.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation


extension ShadhinApi{
    
    func checkGlobalSubscription(
        completion: @escaping (_ packageArray : [GlobalSubscriptionObj],
                               _ isSubscribed : Bool)->Void)
    {
        AF.request(
            GLOBAL_SUBSCRIPTION_CHECK,
            method: .get,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseData { response in
            if case .success(let data) = response.result{
                var foundSubscribed = false
                var array: [GlobalSubscriptionObj] = []
//#if DEBUG
//                var testIndex = 0
//#endif
                if let value = try? JSONSerialization.jsonObject(with: data) as? [[String : Any]] {
                    if value.count > 0 {
                        for i in value {
                            if let regStatus  = i["RegStatus"] as? String,
                               let serviceID  = i["ServiceId"] as? String,
                               let regDate    = i["RegDate"] as? String{
                                if regStatus  == "Subscribed"{
                                    foundSubscribed = true
                                    let expireDate = (i["ExpireDate"] as? String)  ??  ""
                                    array.append(GlobalSubscriptionObj(serviceID: serviceID, regDate: regDate, expireDate: expireDate))
                                }

                            }
                        }
                    }
                }
//#if DEBUG
//
//                foundSubscribed = true
//                array.append(GlobalSubscriptionObj(serviceID: ShadhinCoreSubscriptions.UMOBILE_SUBSCRIPTION_WEEKLY, regDate: "regDate"))
//                                
//#endif
                completion(array,foundSubscribed)
            }
        }
    }
    
    func sendTransactionToken(
        receiptData     : String)
    {
        guard receiptData != ShadhinCore.instance.defaults.receiptData, !receiptData.isEmpty else {return}
        let body = [
            "Platform" : "ios",
            "SubToken" : receiptData
        ]
        AF.request(
            RECEIPT_DATA_NEW,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseData { response in
            if response.response?.statusCode == 200{
                ShadhinCore.instance.defaults.receiptData = receiptData
            }
        }
    }
    
    func getReceiptsFromAppStore() {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
           FileManager.default.fileExists(atPath: appStoreReceiptURL.path)
        {
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                //print(receiptData)
                
                let receiptString = receiptData.base64EncodedString(options: [])
                
                let body: [String : Any] = [
                    "" : receiptString,
                    "password" : "9c3de5c095f0423c949d881e92530f52",
                    "exclude-old-transactions" : true
                ]
                
                AF.request(
                    APPLE_VERIFY_RECEIPT_URL,
                    method: .post, parameters: body,
                    encoding: JSONEncoding.default,
                    headers: CONTENT_HEADER)
                .responseData { response in
                    //response ignored
                }
            }catch{
                Log.error("Couldn't read receipt data with error: " + error.localizedDescription)
            }
        }
    }
    
    @available(*, deprecated, message: "very old api")
    func tryClearFromShadhinServer(subscriptionID: String, subscribeNumber: String, completion: @escaping (_ isSuccess: Bool)->Void) {
        
        let user = "ShadhinApp10"
        let password = "Gakk@@bKash_Shadhin.123!"
        let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        
        let BASE_URL_SUB_0  = "https://gakkpay.bkash.shadhin.co/api"
        let BKASH_CANCEL_SUBSCRIPTION = {(
            _ mobileNumber: String,
            _ serviceID: String)->String in return
            "\(BASE_URL_SUB_0)/unsubs/?msisdn=\(mobileNumber)&serviceid=\(serviceID)"}
        
        AF.request(
            BKASH_CANCEL_SUBSCRIPTION(subscribeNumber, subscriptionID),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers:  HTTPHeaders.init(headers))
        .responseData { response in
            guard case .failure(_) = response.result else {
                return completion(false)
            }
            if case .success(let data) = response.result,
               let value = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                guard let message = value["Message"] as? String else {return}
                if message == "Successfully Unsubscribe" {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
}
