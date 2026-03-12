//
//  ShadhinApi+Subscription+BL.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation


extension ShadhinApi{
    @available (*,deprecated,message: "This is a old method for subscribe, use `ShadhinApi.BLSubscription.requestBLSubOTP(String, (Result<String, AFError>) -> Void)`")
    func requestBLSubOTP(
        _ serviceId : String,
        _ completion: @escaping (_ response: String)->Void)
    {
        AF.request(
            GET_BL_SUB_OTP(ShadhinCore.instance.defaults.userMsisdn, serviceId),
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
    @available (*,deprecated,message: "This is old method to check Subscription OTP, use ShadhinApi.BLSubscription.checkBLSubOTP(serviceId: String##String, otp: String, completion: (Result<String, AFError>) -> Void)")
    func checkBLSubOTP(
        _ serviceId : String,
        _ otp : String,
        _ completion: @escaping (_ response: String)->Void)
    {
        AF.request(
            CHECK_BL_SUB_OTP(ShadhinCore.instance.defaults.userMsisdn, serviceId, otp),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: nil
        ).responseString { response in
            switch response.result{
            case let .success(data):
                completion(data)
            case .failure(_):
                completion("We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
            }
        }
        
        
    }
    @available (*,deprecated,message: "Use ShadhinApi.BLSubscription.cancelBLSub(completion: (Result<String, AFError>) -> Void")
    func cancelBLSub(_ completion: @escaping (_ success: Bool)->Void){
        AF.request(
            CANCEL_BL_SUB(ShadhinCore.instance.defaults.userMsisdn, ShadhinCore.instance.defaults.subscriptionServiceID),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: nil
        ).responseString { response in
            switch response.result{
            case let .success(data):
                if data.uppercased().contains("SUCCESSFUL"){
                    completion(true)
                }else{
                    completion(false)
                }
            case let .failure(error):
                completion(false)
                Log.error(error.localizedDescription)
            }
        }
    }
    
    func checkBLDataPack(_ completion : @escaping (_ isPro : Bool)->Void){
        AF.request(
            CHECK_BL_DATA_BUNDLE(ShadhinCore.instance.defaults.userMsisdn),
            method: .get
        ).responseData { response in
            switch response.result{
            case let .success(data):
                if let value = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                   let dataArray = value["data"] as? [[String : Any]] {
                    for item in dataArray{
                        if let isPro = item["isValidProduct"] as? Bool,
                           isPro{
                            return completion(true)
                        }
                    }
                }
                return completion(false)
            case let .failure(error):
                completion(false)
                Log.error(error.localizedDescription)
            }
        }
    }
}
