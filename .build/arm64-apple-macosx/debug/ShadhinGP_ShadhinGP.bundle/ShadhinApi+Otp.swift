//
//  ShadhinApi+Otp.swift
//  Shadhin
//
//  Created by Gakk Alpha on 5/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit
import Foundation

extension ShadhinApi{
    
    func sendOtpLocal(
        _ vc : UIViewController,
        _ mobileNumber : String,
        _ completion : @escaping ((Bool) -> Void) )
    {
        let mobile = mobileNumber.replacingOccurrences(of: "+", with: "")
        if ShadhinCore.instance.isAirtelOrRobi(mobile){
            ShadhinCore.instance.api.sendBdOtherOtp(vc, mobile, completion)
        }else if(ShadhinCore.instance.isBanglalink(mobile)){
            ShadhinCore.instance.api.sendBdOtherOtp(vc, mobile, completion)
        }else{
            ShadhinCore.instance.api.sendBdOtherOtp(vc, mobile, completion)
        }
    }
    
    func checkOTPLocal(
        _ vc : UIViewController,
        _ mobileNumber : String,
        _ code : String,
        _ completion : @escaping ((Bool?) -> Void))
    {
        let mobile = mobileNumber.replacingOccurrences(of: "+", with: "")
        if ShadhinCore.instance.isAirtelOrRobi(mobile){
            ShadhinCore.instance.api.checkRobiAirtelOTP(vc, mobile, code, completion)
        }else if(ShadhinCore.instance.isBanglalink(mobile)){
            ShadhinCore.instance.api.checkBlOTP(vc, mobile, code, completion)
        }else{
            ShadhinCore.instance.api.checkBdOtherOTP(vc, mobile, code, completion)
        }
    }
    
    func sendBdOtherOtp(
        _ vc            : UIViewController,
        _ mobileNumber  : String,
        _ completion    : @escaping ((Bool) -> Void) )
    {
        
        LoadingIndicator.startAnimation()
        let body:[String : String] = [
            "msisdn" : "\(mobileNumber)",
            "user" : "sh@dHinOTP",
            "servicename" : "Shadhin Music",
            "action" : "Forget"
        ]
        
        AF.request(
            SEND_OTHER_BD_OTP,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: CONTENT_HEADER)
        .responseData { response in
            LoadingIndicator.stopAnimation()
            switch response.result{
            case let .success(data):
                if let json = try? JSONSerialization.jsonObject(with: data),
                   let value = json as? [String : Any],
                   let message = value["response"] as? String{
                    if message.lowercased() == "success"{
                        return completion(true)
                    }
                    vc.view.makeToast(message)
                    return completion(false)
                }else{
                    completion(false)
                }
            case let .failure(error):
                completion(false)
                Log.error(error.localizedDescription)
            }
        }
    }
    
    func checkBdOtherOTP(
        _ vc : UIViewController,
        _ mobileNumber : String,
        _ code : String,
        _ completion : @escaping ((Bool?) -> Void))
    {
        LoadingIndicator.startAnimation()
        
        let body:[String : String] = [
            "msisdn" : "\(mobileNumber.replacingOccurrences(of: "+", with: ""))",
            "password" : "\(code)"
        ]
        
        AF.request(
            CHECK_OTHER_BD_OTP,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: CONTENT_HEADER)
        .responseData { response in
            LoadingIndicator.stopAnimation()
            switch response.result{
            case let .success(data):
                if let json = try? JSONSerialization.jsonObject(with: data),
                   let value = json as? [String : Any],
                   let bool = value["response"] as? String,
                   bool.lowercased() == "true"{
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
    
    func sendOtpForRobiAirtel(
        _ vc : UIViewController,
        _ mobileNumber : String,
        _ completion : @escaping ((Bool) -> Void))
    {
        
        LoadingIndicator.startAnimation()
        let body:[String : String] = [
            "msisdn" : "\(mobileNumber)",
            "shortcode" : "16235",
            "servicename" : "Shadhin Music"
        ]
        
        AF.request(
            SEND_ROBI_OTP,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: CONTENT_HEADER)
        .responseData { response in
            LoadingIndicator.stopAnimation()
            switch response.result{
            case let .success(data):
                if let json = try? JSONSerialization.jsonObject(with: data),
                   let value = json as? [String : String],
                   let message = value["reponse"]{
                    if message.uppercased() == "SUCCESSFUL"{
                        completion(true)
                    }else{
                        vc.view.makeToast(message)
                        completion(false)
                    }
                }else{
                    vc.view.makeToast("We are experiencing technical problems now which will be fixed soon. Thanks for your patience.")
                    completion(false)
                }
            case let .failure(error):
                completion(false)
                vc.view.makeToast(error.localizedDescription)
            }
        }
    }
    
    func checkRobiAirtelOTP(
        _ vc : UIViewController,
        _ mobileNumber : String,
        _ code : String,
        _ completion : @escaping ((Bool?) -> Void) )
    {
        
        LoadingIndicator.startAnimation()
        let body:[String : String] = [
            "msisdn" : "\(mobileNumber)",
            "pasword" : "\(code)"
        ]
        
        AF.request(
            CHECK_ROBI_OTP,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: CONTENT_HEADER)
        .responseData { response in
            LoadingIndicator.stopAnimation()
            switch response.result{
            case let .success(data):
                if let json = try? JSONSerialization.jsonObject(with: data),
                   let value = json as? [String : Any],
                   let bool = value["reponse"] as? String,
                   bool.lowercased() == "true" {
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
    
    func sendOtpForBanglalink(
        _ vc : UIViewController,
        _ mobileNumber : String,
        _ completion : @escaping ((Bool) -> Void))
    {
            
        LoadingIndicator.startAnimation()
        let body:[String : String] = [
            "msisdn" : "\(mobileNumber)",
            "shortcode" : "16235",
            "servicename" : "Shadhin Music"
        ]
        
        AF.request(
            SEND_BL_OTP,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: CONTENT_HEADER)
        .responseData { response in
            LoadingIndicator.stopAnimation()
            switch response.result{
            case let .success(data):
                if let json = try? JSONSerialization.jsonObject(with: data),
                   let value = json as? [String : String] ,
                   let message = value["reponse"]{
                    if message.uppercased() == "SUCCESSFUL"{
                        completion(true)
                    }else{
                        vc.view.makeToast(message)
                        completion(false)
                    }
                }else{
                    vc.view.makeToast("We are experiencing technical problems now which will be fixed soon. Thanks for your patience.")
                    completion(false)
                }
            case .failure(_):
                vc.view.makeToast("We are experiencing technical problems now which will be fixed soon. Thanks for your patience.")
                completion(false)
            }
        }
    }
    
    func checkBlOTP(
        _ vc : UIViewController,
        _ mobileNumber : String,
        _ code : String,
        _ completion : @escaping ((Bool?) -> Void))
    {
            
        LoadingIndicator.startAnimation()
        
        let body:[String : String] = [
            "msisdn" : "\(mobileNumber)",
            "pasword" : "\(code)"
        ]
        
        AF.request(
            CHECK_BL_OTP,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: CONTENT_HEADER)
        .responseData { response in
            LoadingIndicator.stopAnimation()
            switch response.result{
            case let .success(data):
                if let json = try? JSONSerialization.jsonObject(with: data),
                   let value = json as? [String : Any],
                   let bool = value["reponse"] as? String,
                   bool.lowercased() == "true" {
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
    
    
    // NEW SUBSCRIPTION
    /*
    func requestOtp(url: String, parameter:[String: String], _ completion : @escaping ((Bool?) -> Void)) {
        AF.request(
            url,
            method: .post,
            parameters: parameter,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).response { response in
            if let httpResponse = response.response, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                if response.error != nil {
                    completion(false)
                } else {
                    completion(false)
                }
            }
        }
    }
    */
    
    func requestOtp(url: String, parameter:[String: String], _ completion : @escaping (Result<OTPResponseModel,AFError>)->Void) {
        AF.request(
            url,
            method: .post,
            parameters: parameter,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: OTPResponseModel.self) { response in
            print(response)
            completion(response.result)
        }
    }
}
