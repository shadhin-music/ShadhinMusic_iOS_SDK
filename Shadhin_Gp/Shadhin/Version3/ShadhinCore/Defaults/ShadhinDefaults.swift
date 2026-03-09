//
//  ShadhinDefaults.swift
//  Shadhin
//
//  Created by Gakk Alpha on 3/9/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation
import CoreTelephony

class ShadhinDefaults {
    let userDefault = UserDefaults.standard
    
    enum ShadhinUserType: String{
        case FreeNotSignedIn
        case FreeNeverPro
        case FreeOncePro
        case Pro
    }
    
    init() {
        guard let array = userDefault.stringArray(forKey: "shuffleItems") else {
            return
        }
        print(array)
        ShadhinDefaults.shuffleItems = Set(array)
        print( ShadhinDefaults.shuffleItems)
    }
    
    
    var popUpShownIds: [String]{
        get{
            return userDefault.stringArray(forKey: #function) ?? [String]()
        }
        set {
            userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var playerSkipLimitTimestamp: Double{
        get {
            return userDefault.double(forKey: #function)
        }
        set {
            userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var playerSkipCount: Int{
        get {
            return userDefault.integer(forKey: #function)
        }
        set {
            userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var locationGetTimeStamp: Double{
        get {
            return userDefault.double(forKey: #function)
        }
        set {
            userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var fcmToken : String?{
        get { return userDefault.string(forKey: #function)}
        set {
            guard let _newValue = newValue else {return}
            ShadhinCore.instance.api.updateFcmTokenToServer(
                newToken: _newValue,
                key: #function,
                defaults: userDefault)
        }
    }
    var geoLocation : String{
        set{
            userDefault.set(newValue, forKey: #function)
        }
        get{
            guard let code = userDefault.string(forKey: #function), !code.isEmpty else {
                return countryCode
            }
            return code
        }
    }
    private var countryCode : String{
        get{
            var country = ""
            if let carriers = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.values, let countryCode = Array(carriers).compactMap({ $0.isoCountryCode }).first {
                if countryCode.count > 1{
                    country = String(countryCode.prefix(2))
                }
            }
            if let countryCode = NSLocale.current.regionCode{
                if country.isEmpty{
                    if countryCode.count > 1{
                        country = String(countryCode.prefix(2))
                    }
                }
            }
            
            return country.isEmpty ? "global" : country
        }
    }
    
    var totalPlayedDuration: Int{
        get {
            return userDefault.integer(forKey: #function)
        }
        set {
            userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    // gp explore music tab data model
    
    var gpExploreMusicList: GPExploreMusicModel? {
        get {
            return codable(forKey: #function)
        }
        
        set {
            setCodable(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
// data model save in userdefaults
    var newSubscriptionDetails: SubscriptionDetail? {
        get {
            return codable(forKey: #function)
        }
        
        set {
            setCodable(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    func setCodable<T: Codable>(_ value: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(value) {
            userDefault.set(encoded, forKey: key)
        }
    }
    
    func codable<T: Codable>(forKey key: String) -> T? {
        if let data = userDefault.data(forKey: key) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(T.self, from: data) {
                return decoded
            }
        }
        return nil
    }
    
    var gpMusicContentsCache: [GPContent] {
        get {
            return codable(forKey: #function) ?? []
        }
        set {
            setCodable(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
}
