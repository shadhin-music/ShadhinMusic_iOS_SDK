//
//  SubscriptionService.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 8/22/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//


import UIKit


//#if DEBUG
//let verifyReceiptURL = "https://sandbox.itunes.apple.com/verifyReceipt"
//#else
//let verifyReceiptURL = "https://buy.itunes.apple.com/verifyReceipt"
//#endif

class ShadhinCoreSubscriptions {
    

    static let EVALY_HALF_YEARLY            = "1"
    static let EVALY_YEARLY                 = "2"
    static let COUPON                       = "3"
    static let BANGLA_LINK_DATA_PACK        = "4"
    
    static let BKASH_MONTHLY                = "110"
    static let BKASH_HALF_YEARLY            = "111"
    
    static let BKASH_DAILY_NEW              = "2264"
    static let BKASH_MONTHLY_NEW            = "2265"
    static let BKASH_HALF_YEARLY_NEW        = "2266"
    static let BKASH_YEARLY_NEW             = "2267"
    
    static let SSL_MONTHLY                  = "112"
    static let SSL_HALF_YEARLY_OLD          = "113"
    static let SSL_HALF_YEARLY              = "2262"
    
    static let SSL_HALF_YEARLY_NEW          = "200001"
    
    static let UPAY_HALF_YEARLY             = "2269"
    
    static let GP_DAILY                     = "260"
    static let GP_MONTHLY                   = "261"
    static let GP_HALF_YEARLY               = "262"
    static let GP_YEARLY                    = "263"
    static let GP_MONTHLY_PLUS              = "2291"
    
    static let GP_DAILY_NEW                 = "4001"
    static let GP_DAILY_NEWV2               = "4005"
    static let GP_MONTHLY_NEW               = "4002"
    static let GP_HALF_YEARLY_NEW           = "4003"
    static let GP_YEARLY_NEW                = "4004"
    
    static let ROBI_3DAY_DATA_PACK          = "280"
    static let ROBI_WEEKLY_DATA_PACK        = "281"
    static let ROBI_15DAY_DATA_PACK         = "282"
    static let ROBI_MONTHLY_DATA_PACK       = "283"
    
    
    static let AIRTEL_3DAY_DATA_PACK        = "284"
    static let AIRTEL_WEEKLY_DATA_PACK      = "285"
    static let AIRTEL_15DAY_DATA_PACK       = "286"
    static let AIRTEL_MONTHLY_DATA_PACK     = "287"
    
    
    static let ROBI_DAILY                   = "2250"
    static let ROBI_MONTHLY                 = "2251"
    static let ROBI_HALF_YEARLY             = "2252"
    static let ROBI_YEARLY                  = "2253"
    
    static let ROBI_DCB_DAILY_NEW           = "2255"
    static let ROBI_DCB_MONTHLY_NEW         = "2257"
    static let ROBI_DCB_HALF_YEARLY_NEW     = "2258"
    static let ROBI_DCB_YEARLY_NEW          = "2259"
    
    static let BL_DAILY                     = "256"
    static let BL_MONTHLY                   = "257"
    static let BL_HALF_YEARLY               = "258"
    static let BL_YEARLY                    = "259"
    
    //new service id for BL
    static let BL_DAILY_NEW                 = "9917710001"
    static let BL_DAILY_NEWV2               = "9917710006"
    static let BL_MONTHLY_NEW               = "9917710002"
    static let BL_HALF_YEARLY_NEW           = "9917710003"
    static let BL_YEARLY_NEW                = "9917710004"
    
    static let APP_MONTHLY                  = "601"
    static let APP_YEARLY                   = "602"
    
    static let NAGAD_DAILY                  = "2271"
    static let NAGAD_MONTHLY                = "2272"
    static let NAGAD_HALF_YEARLY            = "2273"
    static let NAGAD_YEARLY                 = "2274"
    
    //stripe id
    static let STRIPE_MONTHLY               = "100001"
    static let STRIPE_YEARLY                = "100003"
    
    static let UMOBILE_SUBSCRIPTION_WEEKLY   = "104"
    static let UMOBILE_SUBSCRIPTION_MONTHLY  = "105"
    
    
    static let bkash = [
        Subscriptions(subsTime: "MONTHLY", currency: "BDT", price: "20.00", totalDays: "30", subTitle: "৳20 / 30 days", description: "VAT+SD+SC Included • Auto-renewal", serviceId: ShadhinCoreSubscriptions.BKASH_MONTHLY_NEW),
        Subscriptions(subsTime: "HALF YEARLY", currency: "BDT", price: "99.00", totalDays: "182", subTitle: "৳99 / 182 days", description: "VAT+SD+SC Included • Auto-renewal", serviceId: ShadhinCoreSubscriptions.BKASH_HALF_YEARLY_NEW),
        Subscriptions(subsTime: "YEARLY", currency: "BDT", price: "199.00", totalDays: "365", subTitle: "৳199 / 356 days", description: "VAT+SD+SC Included • Auto-renewal", serviceId: ShadhinCoreSubscriptions.BKASH_YEARLY_NEW)
    ]
    
    static let ssl = [
        Subscriptions(subsTime: "HALF YEARLY", currency: "BDT", price: "99.00", totalDays: "182", subTitle: "৳99 / 182 days", description: "VAT+SD+SC Included • Non Auto-renewal", serviceId: ShadhinCoreSubscriptions.SSL_HALF_YEARLY)
    ]
    
    static let telco = [
        Subscriptions(subsTime: "DAILY", currency: "BDT", price: "2.44", totalDays: "1", subTitle: "৳2.44 / 1 day", description: "VAT+SD+SC Excluded • Auto-renewal", serviceId: ShadhinCoreSubscriptions.GP_DAILY),
        Subscriptions(subsTime: "MONTHLY", currency: "BDT", price: "20.00", totalDays: "30", subTitle: "৳20 / 30 days", description: "VAT+SD+SC Excluded • Auto-renewal", serviceId: ShadhinCoreSubscriptions.GP_MONTHLY)
       ]
    
    static let telcoGP = [
        Subscriptions(subsTime: "DAILY", currency: "BDT", price: "3.00", totalDays: "1", subTitle: "৳3 / 1 day", description: "VAT+SD+SC Excluded • Auto-renewal", serviceId: ShadhinCoreSubscriptions.GP_DAILY_NEWV2),
        Subscriptions(subsTime: "MONTHLY", currency: "BDT", price: "20.00", totalDays: "30", subTitle: "৳20 / 30 days", description: "VAT+SD+SC Excluded • Auto-renewal", serviceId: ShadhinCoreSubscriptions.GP_MONTHLY_NEW),
        Subscriptions(subsTime: "HALF YEARLY", currency: "BDT", price: "99.00", totalDays: "182", subTitle: "৳99 / 182 days", description: "VAT+SD+SC Excluded • Auto-renewal", serviceId: ShadhinCoreSubscriptions.GP_HALF_YEARLY_NEW),
        Subscriptions(subsTime: "YEARLY", currency: "BDT", price: "199.00", totalDays: "365", subTitle: "৳199 / 365 days", description: "VAT+SD+SC Excluded • Auto-renewal", serviceId: ShadhinCoreSubscriptions.GP_YEARLY_NEW),
        Subscriptions(subsTime: "MONTHLY PLUS", currency: "BDT", price: "30.00", totalDays: "30", subTitle: "৳30 / 30 days", description: "VAT+SD+SC Excluded • Non Auto-renewal", serviceId: ShadhinCoreSubscriptions.GP_MONTHLY_PLUS)
       ]
    
    static let telcoRobi = [
        Subscriptions(subsTime: "DAILY", currency: "BDT", price: "3.00", totalDays: "1", subTitle: "৳3.00 / 1 day", description: "1% SC Applicable • Auto-renewal", serviceId: ShadhinCoreSubscriptions.ROBI_DCB_DAILY_NEW),
        Subscriptions(subsTime: "MONTHLY", currency: "BDT", price: "20.00", totalDays: "30", subTitle: "৳20 / 30 days", description: "1% SC Applicable • Auto-renewal", serviceId: ShadhinCoreSubscriptions.ROBI_DCB_MONTHLY_NEW),
        Subscriptions(subsTime: "HALF YEARLY", currency: "BDT", price: "99.00", totalDays: "182", subTitle: "৳99 / 182 days", description: "1% SC Applicable • Auto-renewal", serviceId: ShadhinCoreSubscriptions.ROBI_DCB_HALF_YEARLY_NEW),
        Subscriptions(subsTime: "YEARLY", currency: "BDT", price: "199.00", totalDays: "365", subTitle: "৳199 / 365 days", description: "1% SC Applicable • Auto-renewal", serviceId: ShadhinCoreSubscriptions.ROBI_DCB_YEARLY_NEW)
    ]
    
    static let telcoBanglalink = [
        Subscriptions(subsTime: "DAILY", currency: "BDT", price: "3.00", totalDays: "1", subTitle: "৳3 / 1 day", description: "VAT+SD+SC Excluded • Auto-renewal", serviceId: ShadhinCoreSubscriptions.BL_DAILY_NEWV2),
        Subscriptions(subsTime: "MONTHLY", currency: "BDT", price: "20.00", totalDays: "30", subTitle: "৳20 / 30 days", description: "VAT+SD+SC Included • Auto-renewal", serviceId: ShadhinCoreSubscriptions.BL_MONTHLY_NEW),
        Subscriptions(subsTime: "HALF YEARLY", currency: "BDT", price: "99.00", totalDays: "182", subTitle: "৳99 / 182 days", description: "VAT+SD+SC Excluded • Auto-renewal", serviceId: ShadhinCoreSubscriptions.BL_HALF_YEARLY_NEW),
        Subscriptions(subsTime: "YEARLY", currency: "BDT", price: "199.00", totalDays: "365", subTitle: "৳199 / 365 days", description: "VAT+SD+SC Excluded • Auto-renewal", serviceId: ShadhinCoreSubscriptions.BL_YEARLY_NEW)
    ]
    
    static let telcoUmobile = [
        Subscriptions(subsTime: "WEEKLY", currency: "RM", price: "2.00", totalDays: "7", subTitle: "RM2.00 / 7 days", description: "VAT+SD+SC Excluded • Auto-renewal", serviceId: ShadhinCoreSubscriptions.UMOBILE_SUBSCRIPTION_WEEKLY),
        Subscriptions(subsTime: "MONTHLY", currency: "RM", price: "20.00", totalDays: "30", subTitle: "RM5.00 / 30 days", description: "VAT+SD+SC Excluded • Auto-renewal", serviceId: ShadhinCoreSubscriptions.UMOBILE_SUBSCRIPTION_MONTHLY)
       ]
    
    static let upay = [
        Subscriptions(subsTime: "HALF YEARLY", currency: "BDT", price: "99.00", totalDays: "182", subTitle: "৳99 / 182 days", description: "VAT+SD+SC Included • Non Auto-renewal", serviceId: ShadhinCoreSubscriptions.UPAY_HALF_YEARLY)
    ]
    
    static let nagad = [
        Subscriptions(subsTime: "HALF YEARLY", currency: "BDT", price: "99.00", totalDays: "182", subTitle: "৳99 / 182 days", description: "VAT+SD+SC Included • Non Auto-renewal", serviceId: ShadhinCoreSubscriptions.NAGAD_HALF_YEARLY),
        Subscriptions(subsTime: "YEARLY", currency: "BDT", price: "199.00", totalDays: "365", subTitle: "৳199 / 365 days", description: "VAT+SD+SC Included • Non Auto-renewal", serviceId: ShadhinCoreSubscriptions.NAGAD_YEARLY)
    ]

    static let instance = ShadhinCoreSubscriptions()
    let userDefault = UserDefaults.standard
    
    var pinnedCertificatesession : Session?
    
    func clearSubFromOurServer(subId: String, completion: @escaping ()-> ()){
        ShadhinCore.instance.api.tryClearFromShadhinServer(subscriptionID: subId, subscribeNumber: ShadhinCore.instance.defaults.userMsisdn) { (ignore) in
            ShadhinCore.instance.defaults.isBkashSubscribedUser = false
            ShadhinCore.instance.defaults.isSSLSubscribedUser = false
            ShadhinCore.instance.defaults.subscriptionServiceID = ""
        }
    }
}

extension ShadhinCoreSubscriptions{
    
    static let TelcoDailyCode = "APP_029532"
    static let TelcoMonthlyCode = "APP_026506"
    
    static let TELCO_ROBI_MONTHLY = "0300417324"
    static let TELCO_ROBI_HALF_YEARLY = "0300417326"
    static let TELCO_ROBI_YEARLY = "0300417330"
    
    
    private func showAlert(_ vc : UIViewController, _ msg : String){
        
        let alertVC = UIAlertController(title: "Robi/Airtel subscription", message: msg, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Ok", style: .default) { (action) in
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.checkUserSubscription(5)
        }
        
        alertVC.addAction(confirmAction)
        vc.present(alertVC, animated: true, completion: nil)
    }
    
}

    
   



