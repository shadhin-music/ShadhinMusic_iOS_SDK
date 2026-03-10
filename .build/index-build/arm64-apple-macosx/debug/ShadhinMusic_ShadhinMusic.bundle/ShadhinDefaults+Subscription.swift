//
//  ShadhinDefaults+Subscription.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/2/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinDefaults{
    
    var receiptData: String {
        get { return userDefault.string(forKey: #function) ?? ""}
        set {
            userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var subscriptionServiceID: String {
        get { return userDefault.string(forKey: #function) ?? ""}
        set {
            userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    var subscriptionIDForStripeAndSSL: String {
        get { return userDefault.string(forKey: #function) ?? ""}
        set {
            userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    var stripeSSLDetails : StripeStatus?{
        set{
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                userDefault.set(encoded, forKey: #function)
            }
        }get{
            if let savedPerson = userDefault.object(forKey: #function) as? Data {
                let decoder = JSONDecoder()
                if let loadedPerson = try? decoder.decode(StripeStatus.self, from: savedPerson) {
                    return loadedPerson
                }
            }
            return nil
        }
    }
    var isNagadSubscribedUser: Bool {
        get { return userDefault.bool(forKey: #function) }
        set { userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var isTelcoSubscribedUser: Bool {
        get { return userDefault.bool(forKey: #function) }
        set { userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var isSSLSubscribedUser: Bool {
        get { return userDefault.bool(forKey: #function) }
        set { userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var isBkashSubscribedUser: Bool {
        get { return userDefault.bool(forKey: #function) }
        set { userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    var isStripeSubscriptionUser : Bool{
        get { return userDefault.bool(forKey: #function) }
        set { userDefault.set(newValue, forKey: #function)
            userDefault.synchronize()
        }
    }
    
    var isAppleSubscribeUser : Bool{
        return (ShadhinCore.instance.defaults.subscriptionServiceID == ShadhinCoreSubscriptions.APP_YEARLY || ShadhinCore.instance.defaults.subscriptionServiceID == ShadhinCoreSubscriptions.APP_YEARLY)
    }
    var isBDSubscriber : Bool {
        return (ShadhinCore.instance.defaults.isBkashSubscribedUser  ||
        ShadhinCore.instance.defaults.isSSLSubscribedUser   ||
        ShadhinCore.instance.defaults.isNagadSubscribedUser ||
        ShadhinCore.instance.defaults.isTelcoSubscribedUser)
    }
}
