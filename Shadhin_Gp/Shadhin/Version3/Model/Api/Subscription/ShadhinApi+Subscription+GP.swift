//
//  ShadhinApi+Subscription+GP.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation


extension ShadhinApi{
    
    func requestGpDobSubscriptionOtp(
        _ serviceId : String,
        _ completion : @escaping (_ otpTransactionId: String?)->Void)
    {
        
        let body = [
            "MSISDN" : "\(ShadhinCore.instance.defaults.userMsisdn)",
            "serviceid": serviceId,
            "puser": "d@Bb!sg$$k"
        ]
        AF.request(
            GET_GP_DOB_SUB_OTP,
            method: .post,
            parameters: body
        ).responseData { response in
            switch response.result{
            case let .success(data):
                if let value = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                   let otpTrancId = value["otpTrasactionId"] as? String,
                   !otpTrancId.isEmpty{
                    return completion(otpTrancId)
                }
                return completion(nil)
            case let .failure(error):
                completion("We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
                Log.error(error.localizedDescription)
            }
        }
    }
    
    func checkGpDobSubscriptionOtp(
        serviceId : String,
        otpTransactionId : String,
        otp : String,
        _ completion : @escaping (_ success : Bool)->Void)
    {
        
        let body = [
            "MSISDN" : "\(ShadhinCore.instance.defaults.userMsisdn)",
            "serviceid": serviceId,
            "puser": "d@Bb!sg$$k",
            "otpTrasactionId": otpTransactionId,
            "transactionPin": otp
        ]
        
        AF.request(
            CHECK_GP_DOB_SUB_OTP,
            method: .post,
            parameters: body
        ).responseData { response in
            switch response.result{
            case let .success(data):
                if let value = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                   let otpTrancId = value["result"] as? String{
                    return completion(otpTrancId == "200")
                }
                return completion(false)
            case let .failure(error):
                completion(false)
                Log.error(error.localizedDescription)
            }
        }
    }
    
    func getGpDobPlusRechargeUrl(
        _ serviceId : String,
        _ completion : @escaping (_ paymentUrl : String?)->Void)
    {
        
        let body = [
            "MSISDN" : "\(ShadhinCore.instance.defaults.userMsisdn)",
            "serviceid": serviceId,
            "puser": "d@Bb!sg$$k"
        ]
        AF.request(
            GET_GP_DOB_PLUS_SUB,
            method: .post,
            parameters: body)
        .responseData { response in
            switch response.result{
            case let .success(data):
                if let value = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                   let url = value["paymentUrl"] as? String,
                   ShadhinCore.instance.isStringLink(string: url){
                    return completion(url)
                }
                return completion(nil)
            case let .failure(error):
                completion("We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
                Log.error(error.localizedDescription)
            }
        }
    }
    
    func cancelGpSub(
        completion: @escaping (_ success: Bool)->Void)
    {
        if ShadhinCore.instance.defaults.subscriptionServiceID == ShadhinCoreSubscriptions.GP_MONTHLY_PLUS{
            cancelGpDobPlus(ShadhinCore.instance.defaults.subscriptionServiceID, completion)
            return
        }else if
            ShadhinCore.instance.defaults.subscriptionServiceID == ShadhinCoreSubscriptions.GP_DAILY_NEW ||
            ShadhinCore.instance.defaults.subscriptionServiceID == ShadhinCoreSubscriptions.GP_DAILY_NEWV2 ||
            ShadhinCore.instance.defaults.subscriptionServiceID == ShadhinCoreSubscriptions.GP_MONTHLY_NEW ||
            ShadhinCore.instance.defaults.subscriptionServiceID == ShadhinCoreSubscriptions.GP_HALF_YEARLY_NEW ||
            ShadhinCore.instance.defaults.subscriptionServiceID == ShadhinCoreSubscriptions.GP_YEARLY_NEW{
            cancelGpAutoNew(completion)
        }else{
            cancelGpAuto(completion)
        }
        
    }
    
    func cancelGpAutoNew(
        _ completion: @escaping (_ success: Bool)->Void)
    {
        let URL = URL(string:CANCEL_GP_SUB_V2)
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
                    completion(true)
                case .failure(_):
                    completion(false)
                }
            }
    }
    
//    private func cancelGpAutoNew(_ completion : @escaping (_ success : Bool)->Void){
//        AF.request(
//            CANCEL_GP_SUB(
//                ShadhinCore.instance.defaults.subscriptionServiceID,
//                ShadhinCore.instance.defaults.userMsisdn),
//            method: .delete)
//        .responseData { response in
//            switch response.result{
//            case let .success(data):
//                if let value = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
//                   value["Status"] as? Int == 200{
//                    return completion(true)
//                }
//                return completion(false)
//            case let .failure(error):
//                completion(false)
//                Log.error(error.localizedDescription)
//            }
//        }
//    }
    
    private func cancelGpAuto(_ completion : @escaping (_ success : Bool)->Void){
        AF.request(
            GP_DPDP_CANCEL(ShadhinCore.instance.defaults.subscriptionServiceID,ShadhinCore.instance.defaults.userMsisdn),
            method: .get)
        .responseString { response in
            switch response.result{
            case let .success(data):
                if data == "Request Processed"{
                    return completion(true)
                }
                return completion(false)
            case let .failure(error):
                completion(false)
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func cancelGpDobPlus(
        _ serviceId : String,
        _ completion : @escaping (_ success : Bool)->Void)
    {
        
        let body = [
            "MSISDN": ShadhinCore.instance.defaults.userMsisdn,
            "serviceid": serviceId,
            "puser": "d@Bb!sg$$k"
        ]
        AF.request(
            GP_DOB_PLUS_CANCEL,
            method: .post,
            parameters: body)
        .responseData { response in
            switch response.result{
            case let .success(data):
                if let value = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                   let msg = value["errorMessage"] as? String,
                   msg.lowercased().contains("successful"){
                    return completion(true)
                }
                return completion(false)
            case let .failure(error):
                completion(false)
                Log.error(error.localizedDescription)
            }
        }
    }
    
    func getGPChargingUrl(_ serviceID: String) -> String{
        return GET_GP_DPDP_CHARGING_URL(serviceID)
    }
    
    func getGPChargingUrlNew(
        _ serviceId : String,
        _ completion : @escaping (_ paymentUrl : String?, _ errMsg: String?)->Void)
    {
        let body = [
            "serviceId"   : serviceId,
            "MSISDN"      : "\(ShadhinCore.instance.defaults.userMsisdn)"
            //    "callbackUrl" : "https://micropay.techapi24.com/SSLPaySuccessCallBack/Get"
        ]
        
        AF.request(
            GET_GP_CHARGING_URL_V2,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default
        ).responseDecodable(of:GPChargingModel.self) { response in
            switch response.result {
            case .success(let data):
                if let url = data.data?.paymentURL {
                    completion(url, nil)
                }else{
                    completion(nil, "We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
                }
            case .failure(_):
                completion(nil, "We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
            }
        }
    }
}
