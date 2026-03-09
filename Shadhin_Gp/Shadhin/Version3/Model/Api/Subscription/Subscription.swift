//
//  BkashAppDelegate.swift
//  Shadhin
//
//  Created by Rezwan on 7/30/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit
import CoreTelephony
import UserNotifications


struct CheckSubscriptionNew {
    
    func checkUserSubscription(_ delayInterval : TimeInterval = 0){
        if !ShadhinCore.instance.isUserLoggedIn{
            ShadhinCore.instance.defaults.shadhinUserType = .FreeNeverPro
            userNotPro()
            return
        }
        guard try! Reachability().connection != .unavailable else {return}
        self.checkAppleSubscription()
    }
    
    
    private func check_bkash_ssl_eval_sub(){
        ShadhinCore.instance.api.checkGlobalSubscription { packageArray, isSubscribed in
            var foundValidSubcription = false
            for item in packageArray{
                print(item.serviceID)
                ShadhinCore.instance.defaults.expireDate = item.expireDate
                foundValidSubcription = self.checkIfSubDateOver(
                    regDateStr: item.regDate,
                    package: item.serviceID
                )
                if foundValidSubcription{
                    break
                }
            }
            if !foundValidSubcription{
                if packageArray.isEmpty{
                    ShadhinCore.instance.defaults.shadhinUserType = .FreeNeverPro
                }else{
                    ShadhinCore.instance.defaults.shadhinUserType = .FreeOncePro
                }
                ShadhinCore.instance.defaults.expireDate = ""
                self.checkStripe()
            }
        }

    }
    
    private func checkStripe(){
        ShadhinApi.StripeSubscription.getStripSubscriptionStatus { result in
            switch result {
            case .success(let success):
                if let item = success.data.first{
                    ShadhinCore.instance.defaults.stripeSSLDetails = item
                    ShadhinCore.instance.defaults.shadhinUserType = .Pro
                    ShadhinCore.instance.defaults.isStripeSubscriptionUser = true
                    ShadhinCore.instance.defaults.subscriptionServiceID = item.productID
                    ShadhinCore.instance.defaults.subscriptionIDForStripeAndSSL = item.subscriptionID
                    NotificationCenter.default.post(name: .didTapBackBkashPayment, object: nil)
                }else{
                    self.checkSSL()
                }
            case .failure(let failure):
                Log.error(failure.localizedDescription)
                self.checkSSL()
            }
        }
    }
    
    private func checkSSL(){
        ShadhinApi.SSLSubscription.getSSLSubscriptionStatus { result in
            switch result {
            case .success(let success):
                if let item = success.data{
                    ShadhinCore.instance.defaults.stripeSSLDetails = StripeStatus(status: item.status, productID: item.serviceID, subscriptionID: item.subscriptionID)
                    ShadhinCore.instance.defaults.isSSLSubscribedUser = true
                    ShadhinCore.instance.defaults.subscriptionIDForStripeAndSSL  = item.subscriptionID
                    ShadhinCore.instance.defaults.subscriptionServiceID = item.serviceID
                    ShadhinCore.instance.defaults.shadhinUserType = .Pro
                }else{
                    self.checkBanglalinkDataPack()
                }
            case .failure(let failure):
                Log.error(failure.localizedDescription)
                self.checkBanglalinkDataPack()
            }
        }
    }
    
    private func checkBanglalinkDataPack(){
        if ShadhinCore.instance.isBanglalink(){
            ShadhinCore.instance.api.checkBLDataPack { isPro in
                if isPro{
                    ShadhinCore.instance.defaults.subscriptionServiceID = ShadhinCoreSubscriptions.BANGLA_LINK_DATA_PACK
                    ShadhinCore.instance.defaults.shadhinUserType = .Pro
                    ShadhinCore.instance.defaults.isBkashSubscribedUser = false
                    ShadhinCore.instance.defaults.isSSLSubscribedUser = true
                    NotificationCenter.default.post(name: .didTapBackBkashPayment, object: nil)
                }else{
                    self.userNotPro()
                }
            }
            
        }else{
            self.userNotPro()
        }
    }
    
    private func checkIfSubDateOver(regDateStr : String, package : String) -> Bool{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" //"MM/dd/yyyy hh:mm:ss a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
       
        
        var months = 1
        
        //let package = "3"
        
        switch package {
        case "112":
            months = 1
        case ShadhinCoreSubscriptions.COUPON,
            ShadhinCoreSubscriptions.ROBI_3DAY_DATA_PACK,
            ShadhinCoreSubscriptions.ROBI_WEEKLY_DATA_PACK,
            ShadhinCoreSubscriptions.ROBI_15DAY_DATA_PACK,
            ShadhinCoreSubscriptions.ROBI_MONTHLY_DATA_PACK,
            
            ShadhinCoreSubscriptions.AIRTEL_3DAY_DATA_PACK,
            ShadhinCoreSubscriptions.AIRTEL_WEEKLY_DATA_PACK,
            ShadhinCoreSubscriptions.AIRTEL_15DAY_DATA_PACK,
            ShadhinCoreSubscriptions.AIRTEL_MONTHLY_DATA_PACK:
            ShadhinCore.instance.defaults.shadhinUserType = .Pro
            ShadhinCore.instance.defaults.subscriptionServiceID = package
            ShadhinCore.instance.defaults.isBkashSubscribedUser = false
            ShadhinCore.instance.defaults.isSSLSubscribedUser = true
            NotificationCenter.default.post(name: .didTapBackBkashPayment, object: nil)
            return true
        case "113",
            ShadhinCoreSubscriptions.SSL_HALF_YEARLY,
            "1",
            "2269":
            months = 6
        case "2":
            months = 12
        case "110",
            "111",
            ShadhinCoreSubscriptions.BKASH_DAILY_NEW,
            ShadhinCoreSubscriptions.BKASH_MONTHLY_NEW,
            ShadhinCoreSubscriptions.BKASH_HALF_YEARLY_NEW,
            ShadhinCoreSubscriptions.BKASH_YEARLY_NEW:
            ShadhinCore.instance.defaults.shadhinUserType = .Pro
            ShadhinCore.instance.defaults.subscriptionServiceID = package
            ShadhinCore.instance.defaults.isBkashSubscribedUser = true
            NotificationCenter.default.post(name: .didTapBackBkashPayment, object: nil)
            return true
        case
            ShadhinCoreSubscriptions.GP_DAILY,
            ShadhinCoreSubscriptions.GP_MONTHLY,
            ShadhinCoreSubscriptions.GP_MONTHLY_PLUS,
            ShadhinCoreSubscriptions.GP_HALF_YEARLY,
            ShadhinCoreSubscriptions.GP_YEARLY,
            
            ShadhinCoreSubscriptions.GP_DAILY_NEW,
            ShadhinCoreSubscriptions.GP_DAILY_NEWV2,
            ShadhinCoreSubscriptions.GP_MONTHLY_NEW,
            ShadhinCoreSubscriptions.GP_HALF_YEARLY_NEW,
            ShadhinCoreSubscriptions.GP_YEARLY_NEW,
            
            ShadhinCoreSubscriptions.BL_DAILY,
            ShadhinCoreSubscriptions.BL_MONTHLY,
            ShadhinCoreSubscriptions.BL_HALF_YEARLY,
            ShadhinCoreSubscriptions.BL_YEARLY,
            
            ShadhinCoreSubscriptions.BL_DAILY_NEWV2,
            ShadhinCoreSubscriptions.BL_MONTHLY_NEW,
            ShadhinCoreSubscriptions.BL_HALF_YEARLY_NEW,
            ShadhinCoreSubscriptions.BL_YEARLY_NEW,
            
            ShadhinCoreSubscriptions.ROBI_DAILY,
            ShadhinCoreSubscriptions.ROBI_MONTHLY,
            ShadhinCoreSubscriptions.ROBI_HALF_YEARLY,
            ShadhinCoreSubscriptions.ROBI_YEARLY,
            
            ShadhinCoreSubscriptions.ROBI_DCB_DAILY_NEW,
            ShadhinCoreSubscriptions.ROBI_DCB_MONTHLY_NEW,
            ShadhinCoreSubscriptions.ROBI_DCB_HALF_YEARLY_NEW,
            ShadhinCoreSubscriptions.ROBI_DCB_YEARLY_NEW,
            
            ShadhinCoreSubscriptions.UMOBILE_SUBSCRIPTION_WEEKLY,
            ShadhinCoreSubscriptions.UMOBILE_SUBSCRIPTION_MONTHLY:
            
            ShadhinCore.instance.defaults.shadhinUserType = .Pro
            ShadhinCore.instance.defaults.subscriptionServiceID = package
            ShadhinCore.instance.defaults.isTelcoSubscribedUser = true
            NotificationCenter.default.post(name: .didTapBackBkashPayment, object: nil)
            return true
        case
            ShadhinCoreSubscriptions.NAGAD_DAILY,
            ShadhinCoreSubscriptions.NAGAD_MONTHLY,
            ShadhinCoreSubscriptions.NAGAD_HALF_YEARLY,
            ShadhinCoreSubscriptions.NAGAD_YEARLY:
            ShadhinCore.instance.defaults.shadhinUserType = .Pro
            ShadhinCore.instance.defaults.subscriptionServiceID = package
            ShadhinCore.instance.defaults.isNagadSubscribedUser = true
            NotificationCenter.default.post(name: .didTapBackBkashPayment, object: nil)
            return true
        default:
            return false
        }
        guard let regDate = dateFormatter.date(from: regDateStr),
              let endDate = Calendar.current.date(byAdding: .month, value: months, to: regDate) else {return false}
        
        if endDate < Date()  {
            ShadhinCoreSubscriptions.instance.clearSubFromOurServer(subId: package){
                //tried to clear from server
            }
            return false
        }else{
            ShadhinCore.instance.defaults.shadhinUserType = .Pro
            ShadhinCore.instance.defaults.subscriptionServiceID = package
            ShadhinCore.instance.defaults.isBkashSubscribedUser = false
            ShadhinCore.instance.defaults.isSSLSubscribedUser = true
            NotificationCenter.default.post(name: .didTapBackBkashPayment, object: nil)
            return true
        }
    }
    
    
    private func userNotPro(){
        ShadhinCore.instance.defaults.subscriptionServiceID = ""
        ShadhinCore.instance.defaults.subscriptionIDForStripeAndSSL = ""
        ShadhinCore.instance.defaults.isBkashSubscribedUser = false
        ShadhinCore.instance.defaults.isSSLSubscribedUser =  false
        ShadhinCore.instance.defaults.isTelcoSubscribedUser = false
        ShadhinCore.instance.defaults.isNagadSubscribedUser = false
        ShadhinCore.instance.defaults.isStripeSubscriptionUser = false
        ShadhinCore.instance.defaults.stripeSSLDetails = nil
        NotificationCenter.default.post(name: .didTapBackBkashPayment, object: nil)
    }
    
    
    
    private func checkAppleSubscription() {
        ShadhinCore.instance.defaults.expireDate = ""
        if SubscriptionAppleProducts.store.isProductPurchased(SubscriptionAppleProducts.monthlySub) {
            ShadhinCore.instance.defaults.subscriptionServiceID = ShadhinCoreSubscriptions.APP_MONTHLY
            ShadhinCore.instance.defaults.shadhinUserType = .Pro
            NotificationCenter.default.post(name: .didTapBackBkashPayment, object: nil)
        }else if SubscriptionAppleProducts.store.isProductPurchased(SubscriptionAppleProducts.yearlySub) {
            ShadhinCore.instance.defaults.subscriptionServiceID = ShadhinCoreSubscriptions.APP_YEARLY
            ShadhinCore.instance.defaults.shadhinUserType = .Pro
            NotificationCenter.default.post(name: .didTapBackBkashPayment, object: nil)
        }else{
            if ShadhinCore.instance.isUserLoggedIn{
                ShadhinCore.instance.defaults.shadhinUserType = .FreeNeverPro
                self.check_bkash_ssl_eval_sub()
            }else{
                ShadhinCore.instance.defaults.subscriptionServiceID = ""
                ShadhinCore.instance.defaults.shadhinUserType = .FreeNotSignedIn
                NotificationCenter.default.post(name: .didTapBackBkashPayment, object: nil)
            }
        }
        getReceiptData()
    }
    
    func getReceiptData(){
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                let receiptString = receiptData.base64EncodedString(options: [])
                ShadhinCore.instance.api.sendTransactionToken(receiptData: receiptString)
            }
            catch { Log.error("Couldn't read receipt data with error: " + error.localizedDescription) }
        }
    }
    
    
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
