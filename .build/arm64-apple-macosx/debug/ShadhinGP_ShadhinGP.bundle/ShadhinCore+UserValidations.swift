//
//  ShadhinCore+User_Validations.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinCore {
    
    var isUserLoggedIn: Bool{
        get{
            !defaults.userSessionToken.isEmpty
        }
    }
    
    var isUserPro: Bool{
        get {
            if let newSubscriptionDetails = ShadhinCore.instance.defaults.newSubscriptionDetails {
                if newSubscriptionDetails.isExpired == false {
                    return true
                }
            }
            return false
        }
    }
    
//    func userInBD() -> Bool{
//        //#if DEBUG
//        //        return false //return true to turn on bd things
//        //#endif
//        let phoneNumberKit = PhoneNumberKit()
//        let mobileNumber = ShadhinCore.instance.defaults.userMsisdn
//        if !mobileNumber.isEmpty {
//            do {
//                let phoneNumber = try phoneNumberKit.parse(mobileNumber)
//                let regionCode = phoneNumberKit.getRegionCode(of: phoneNumber)
//                if regionCode?.uppercased() == "BD" {
//                    return true
//                }
//            }catch{
//                return false
//            }
//        }
//        let countryCode = ShadhinCore.instance.defaults.userCountryCode
//        if countryCode == "BD"{
//            return true
//        }
//        return false
//    }
    
 /* func userInMY() -> Bool{
//#if DEBUG
//        return false //return true to turn on bd things
//#endif
        let phoneNumberKit = PhoneNumberKit()
        let mobileNumber = ShadhinCore.instance.defaults.userMsisdn
        if !mobileNumber.isEmpty {
            do {
                let phoneNumber = try phoneNumberKit.parse(mobileNumber)
                let regionCode = phoneNumberKit.getRegionCode(of: phoneNumber)
                if regionCode?.uppercased() == "MY" {
                    return true
                }
            }catch{
                return false
            }
        }
        let countryCode = ShadhinCore.instance.defaults.userCountryCode
        if countryCode == "MY"{
            return true
        }
        return false
    } */
    
    func isAirtelOrRobi(_ number : String = ShadhinCore.instance.defaults.userMsisdn) -> Bool{
        let robiAirtelRegex =  "^8801[86]\\d{8}$"
        do {
            let regex = try NSRegularExpression(pattern: robiAirtelRegex)
            let nsString = number as NSString
            let results = regex.matches(in: number, range: NSRange(location: 0, length: nsString.length))
            return !results.isEmpty
        } catch let error {
            Log.error("invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    
    func isAirtel(_ number : String = ShadhinCore.instance.defaults.userMsisdn) -> Bool{
        let robiAirtelRegex =  "^8801[6]\\d{8}$"
        do {
            let regex = try NSRegularExpression(pattern: robiAirtelRegex)
            let nsString = number as NSString
            let results = regex.matches(in: number, range: NSRange(location: 0, length: nsString.length))
            return !results.isEmpty
        } catch let error {
            Log.error("invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    
    func isRobi(_ number : String = ShadhinCore.instance.defaults.userMsisdn) -> Bool{
        let robiAirtelRegex =  "^8801[8]\\d{8}$"
        do {
            let regex = try NSRegularExpression(pattern: robiAirtelRegex)
            let nsString = number as NSString
            let results = regex.matches(in: number, range: NSRange(location: 0, length: nsString.length))
            return !results.isEmpty
        } catch let error {
            Log.error("invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    
    func isGP(_ number : String = ShadhinCore.instance.defaults.userMsisdn) -> Bool{
        let robiAirtelRegex =  "^8801[37]\\d{8}$"
        do {
            let regex = try NSRegularExpression(pattern: robiAirtelRegex)
            let nsString = number as NSString
            let results = regex.matches(in: number, range: NSRange(location: 0, length: nsString.length))
            return !results.isEmpty
        } catch let error {
            Log.error("invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    
    func isBanglalink(_ number : String = ShadhinCore.instance.defaults.userMsisdn) -> Bool{
        let banglalinkRegex =  "^8801[49]\\d{8}$"
        do {
            let regex = try NSRegularExpression(pattern: banglalinkRegex)
            let nsString = number as NSString
            let results = regex.matches(in: number, range: NSRange(location: 0, length: nsString.length))
            return !results.isEmpty
        } catch let error {
            Log.error("invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    
    func isValidBangladeshNumber(_ number : String = ShadhinCore.instance.defaults.userMsisdn) -> Bool{
        let gpRegex =  "^8801\\d{9}$"
        do {
            let regex = try NSRegularExpression(pattern: gpRegex)
            let nsString = number as NSString
            let results = regex.matches(in: number, range: NSRange(location: 0, length: nsString.length))
            return !results.isEmpty
        } catch let error {
            Log.error("invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isStringLink(string: String) -> Bool {
        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try? NSDataDetector(types: types.rawValue)
        guard (detector != nil && string.count > 0) else { return false }
        if detector!.numberOfMatches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, string.count)) > 0 {
            return true
        }
        return false
    }
    
    func getUserTelcoBrand(_ number : String = ShadhinCore.instance.defaults.userMsisdn) -> Telco{
        if isGP(number){
            return .GrameenPhone
        }else if isRobi(number){
            return .Robi
        }else if isAirtel(number){
            return .Airtel
        }else if isBanglalink(number){
            return .BanglaLink
        }else{
            return .Unknown
        }
    }
    
}
