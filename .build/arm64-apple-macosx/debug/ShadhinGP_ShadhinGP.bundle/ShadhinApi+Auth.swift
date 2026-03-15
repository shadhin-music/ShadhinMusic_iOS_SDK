//
//  ShadhinApi+Auth.swift
//  Shadhin
//
//  Created by Gakk Alpha on 2/14/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SwiftUI


extension ShadhinApi{
    
    func updateMsisdn(
        token           : String,
        mobileNumber    : String,
        completion      : @escaping (_ token: String?, _ errorMsg: String?)->Void)
    {
        var API_HEADER: HTTPHeaders {
            get{
                var header = [
                   // "Token" : !(token.isEmpty) ? token : "aU9T",
                    "Content-Type" : "application/json"
                ]
                if !token.isEmpty{
                    header["Authorization"] = "Bearer \(token)"
                }
                header["countryCode"] = ShadhinCore.instance.defaults.geoLocation.lowercased()
                header["DeviceType"] =  "iOS"
                return  HTTPHeaders.init(header)
            }
        }
        let body = [
         "msisdn"   : mobileNumber
        ]
        
        AF.request(
            UPDATE_MSISDN,
            method: .put,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of:UpdateMsisdnObj.self) { response in
            switch response.result{
            case let .success(data):
                completion(data.message,nil)
            case let .failure(error):
                Log.error(error.localizedDescription)
                completion(nil,error.errorDescription)
            }
        }
    }
    
    
    func updateUserPassword(
        mobileNumber    : String,
        password        : String,
        completion      : @escaping (_ isSuccess: Bool,_ message: String?)->Void)
    {
        
        let body = [
            "MSISDN"   : mobileNumber,
            "Password" : password
        ]
        
        guard let jsonBodyData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted),
              let jsonBodyString = String(data: jsonBodyData,encoding: .ascii),
              let encryptedJsonBodyString = CryptoCBC.shared.encryptMessage(message: jsonBodyString, encryptionKey: cbc_secret_key , iv: cbc_iv),
              let data = "\"\(encryptedJsonBodyString)\"".data(using: .utf8)
        else {return}
        
        var request = URLRequest(url: URL(string: PASSWORD_UPDATE)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        AF.request(request).responseData{ response in
            switch response.result{
            case let .success(data):
                if let json = try? JSONSerialization.jsonObject(with: data),
                   let data = json as? [String : Any],
                   let message = data["Status"] as? String,
                   message == "1"{
                    completion(true,message)
                } else {
                    return completion(false, "Data parse error")
                }
            case .failure(_):
                return completion(false, "We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
            }
        }
    }
}


extension ShadhinApi{

    func registation(
        userLoginId    : String,
        password       : String,
        registerWith   : RegistrationMedium,
        otpCode        : String = "",
        referralCode   : String = "",
        userName       : String = "",
        gender         : UserGender = .male,
        country        : String = "", //todo
        countryCode    : String = "",
        city           : String = "",
        telcoProvider  : String = "",
        latitude       : Double = 0,
        longitude      : Double = 0)
    {
        
        let body:[String : Any] = [
            "UserName"       : userLoginId,
            "Password"       : password,
            "RegisterWith"   : registerWith.rawValue,
            "LoginPlatform"  : "iOS",
            "DeviceName"     : UIDevice.modelName,
            "VendorId"       : "\(UIDevice.modelName)\(userLoginId)iOS",
            "DeviceId"       : ShadhinCore.instance.defaults.fcmToken ?? "",
            "LoginCode"      : otpCode,
            "ReferralCode"   : referralCode,
            "UserFullName"   : userName,
            "Gender"         : gender.rawValue,
            "ImageUrl"       : "",
            "Country"        : country,
            "CountryCode"    : countryCode,
            "City"           : city,
            "TelcoProvider"  : telcoProvider,
            "Latitude"       : latitude,
            "Longitude"      : longitude
        ]
        
        guard let jsonBodyData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted),
              let jsonBodyString = String(data: jsonBodyData,encoding: .ascii),
              let encryptedJsonBodyString = CryptoCBC.shared.encryptMessage(message: jsonBodyString, encryptionKey: cbc_secret_key , iv: cbc_iv),
              let data = "\"\(encryptedJsonBodyString)\"".data(using: .utf8)
        else {return}
        
        var request = URLRequest(url: URL(string: REGISTRATION)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        AF.request(request).responseDecodable(of: Tokenv7Obj.self) { response in
            switch response.result{
            case let .success(data):
                for notifyer in ShadhinCore.instance.notifiers.objects{
                    notifyer.registationResponseV5?(response: data)
                }
            case let .failure(error):
                for notifyer in ShadhinCore.instance.notifiers.objects{
                    notifyer.registationResponseV5?(response: nil)
                }
                Log.error(error.localizedDescription)
            }
        }
    }
    
    
    func login(
        userLoginId    : String,
        password       : String,
        registerWith   : RegistrationMedium,
        otpCode        : String = "",
        referralCode   : String = "",
        userName       : String = "",
        gender         : UserGender = .unknown,
        imageUrl       : String = "",
        country        : String = "",
        countryCode    : String = "",
        city           : String = "",
        telcoProvider  : String = "",
        msisdn         : String = "",
        latitude       : Double = 0,
        longitude      : Double = 0,
        accessToken    : String? = nil)
    {
        
        var body:[String : Any] = [
            "UserName"      : userLoginId,
            "RegisterWith"  : registerWith.rawValue,
            "LoginPlatform" : "iOS",
            "DeviceName"    : UIDevice.modelName,
            "VendorId"      : "\(UIDevice.modelName)\(userLoginId)iOS",
            "DeviceId"      : ShadhinCore.instance.defaults.fcmToken ?? "",
            "LoginCode"     : otpCode,
            "ReferralCode"  : referralCode,
            "UserFullName"  : userName,
            "Gender"        : gender.rawValue,
            "ImageUrl"      : imageUrl,
            "Country"       : "",
            "CountryCode"   : "",
            "City"          : "",
            "TelcoProvider" : "",
            "Latitude": 0,
            "Longitude": 0
        ]
        
        if !msisdn.isEmpty{
            body["MSISDN"] = msisdn
        }
        
        if registerWith == .mobile{
            body["Password"] = password
        }
        
        if let accessToken = accessToken{
            body["AccessToken"] = accessToken
        }
        
        guard let jsonBodyData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted),
              let jsonBodyString = String(data: jsonBodyData,encoding: .ascii),
              let encryptedJsonBodyString = CryptoCBC.shared.encryptMessage(message: jsonBodyString, encryptionKey: cbc_secret_key , iv: cbc_iv),
              let data = "\"\(encryptedJsonBodyString)\"".data(using: .utf8)
        else {return}
        
        var request = URLRequest(url: URL(string: LOGIN)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
    
        AF.request(request).responseDecodable(of: Tokenv7Obj.self){ response in
            switch response.result{
            case let .success(data):
                for notifyer in ShadhinCore.instance.notifiers.objects{
                    notifyer.loginResponseV7?(response: data, errorMsg: nil)
                }
                self.recentlyPlayedLoad()
                self.fetchAndCacheAllFav()
            case let .failure(error):
                for notifyer in ShadhinCore.instance.notifiers.objects{
                    notifyer.loginResponseV7?(response: nil, errorMsg: error.localizedDescription)
                }
                Log.error(error.localizedDescription)
            }
        }
    }
    
    
    func accountLink(
        userLoginId    : String,
        password       : String,
        registerWith   : RegistrationMedium,
        accessToken    : String? = nil,
        userName       : String = "",
        imageUrl       : String = "",
        completion     : @escaping (_ isSuccess: Bool,_ message: String?)->Void)
    {
        var body:[String : String] = [
            "UserName"      : userLoginId,
            "Password"      : password,
            "RegisterWith"  : registerWith.rawValue,
            "DeviceId"      : ShadhinCore.instance.defaults.fcmToken ?? "",
            "UserFullName"  : userName,
            "ImageUrl"      : imageUrl
        ]
        
        if let accessToken = accessToken{
            body["AccessToken"] = accessToken
        }
        
        AF.request(ACC_LINK, method: .post, parameters: body,encoding: JSONEncoding.default, headers: API_HEADER).responseData { response in
            switch response.result{
            case let .success(data):
                if let json = try? JSONSerialization.jsonObject(with: data),
                   let value = json as? [String : Any],
                   let message = value["Message"] as? String{
                    if let status = value["Status"] as? String,
                       status.elementsEqual("200"){
                        completion(true, "")
                    }else{
                        completion(false, message)
                    }
                }else {
                    return completion(false, "Data parse error")
                }
            case .failure(_):
                completion(false,"experiencing technical problems now which will be fixed soon.Thanks for your patience.")
            }
        }
    }
}
