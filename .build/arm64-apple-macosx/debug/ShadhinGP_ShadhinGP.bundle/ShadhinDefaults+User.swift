//
//  ShadhinDefaults+User.swift
//  Shadhin
//
//  Created by Gakk Alpha on 7/14/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation
 
extension ShadhinDefaults{
    
    var shadhinUserType: ShadhinUserType{
        get {
            guard let rawValue = userDefault.string(forKey: #function) else {
                return .FreeNotSignedIn
            }
            return ShadhinUserType(rawValue: rawValue)!
        }
        set {
            userDefault.set(newValue.rawValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var userCode: String {
        get { return userDefault.string(forKey: #function) ?? ""}
        set {
            userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var userSessionToken: String {
        get { return userDefault.string(forKey: #function) ?? ""}
        set {
            userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    //TODO:
    var userIdentity: String {
        get { return userDefault.string(forKey: #function) ?? ""}
        set {
            userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var userName: String {
        get { return userDefault.string(forKey: #function) ?? ""}
        set {
            userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var userGender: UserGender {
        get {
            let rawStr = userDefault.string(forKey: #function) ?? ""
            return UserGender(rawValue: rawStr) ?? .unknown
        }
        set {
            userDefault.set(newValue.rawValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var userProPicUrl: String {
        get { return userDefault.string(forKey: #function) ?? ""}
        set {
            userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var userEmail: String {
        get { return userDefault.string(forKey: #function) ?? ""}
        set {
            userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    //TODO:
    var userCountryCode: String {
        get { return userDefault.string(forKey: #function) ?? "bd"}
        set {
            userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var userCountry: String {
        get { return userDefault.string(forKey: #function) ?? ""}
        set {
            userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var userCity: String {
        get { return userDefault.string(forKey: #function) ?? ""}
        set {
            userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var userISP: String {
        get { return userDefault.string(forKey: #function) ?? ""}
        set {
            userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var userMsisdn: String {
        get { return userDefault.string(forKey: #function) ?? ""}
        set {
            userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var userBirthDate: Date?{
        get {
            let intervalSince1970 = userDefault.double(forKey: #function)
            if intervalSince1970 == 0 {
                return nil
            }
            return Date(timeIntervalSince1970: intervalSince1970)
        }
        set {
            guard let date = newValue else {return}
            userDefault.set(date.timeIntervalSince1970, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var userLinkedAccounts: [String]{
        get { return userDefault.stringArray(forKey: #function) ?? [] }
        set {
            userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var expireDate: String {
        get { return userDefault.string(forKey: #function) ?? ""}
        set {
            userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var registationDate: String {
        get { return userDefault.string(forKey: #function) ?? ""}
        set {
            userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    func isFavCached(type: SMContentType)-> Bool {
        return userDefault.bool(forKey: "isFavCached\(type.rawValue)")
    }
    
    func setFavCached(type: SMContentType, value: Bool){
        userDefault.set(value, forKey: "isFavCached\(type.rawValue)")
    }
    
    var didReferedSignUp : Bool{
        get { return userDefault.bool(forKey: #function)}
        set { userDefault.set(newValue, forKey: #function) }
    }
    var isLighTheam : Bool{
        get {return userDefault.bool(forKey: #function)}
        set {userDefault.setValue(newValue, forKey: #function)}
    }

    var isFirstTime: Bool {
        get {
            if userDefault.object(forKey: #function) == nil {
                userDefault.setValue(true, forKey: #function)
                userDefault.synchronize()
                return true
            }
            return userDefault.bool(forKey: #function)
        }
        set {
            userDefault.setValue(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }

    var appModeType: AppModeType {
        get {
            if let rawValue = userDefault.string(forKey: #function),
               let type = AppModeType(rawValue: rawValue) {
                return type
            }
            return .light // default to light/white mode
        }
        set {
            userDefault.setValue(newValue.rawValue, forKey: #function)
        }
    }
}
