//
//  AnalyticsEvents.swift
//  Shadhin
//
//  Created by Admin on 3/7/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit


import CoreTelephony

class AnalyticsEvents: NSObject {

    static func downloadEvent(with contentType : String?,contentID : String?, contentTitle : String?){
//        Analytics.logEvent("sm_content_downloaded",
//                           parameters: [
//                            "content_type"  : contentType?.lowercased() ?? "" as NSObject,
//                            "content_id"    : contentID ?? "" as NSObject,
//                            "content_name"  : contentTitle?.lowercased() ?? "" as NSObject,
//                            "platform"      : "ios" as NSObject
//                           ])
    }
    
}

class RobiAnalytics : NSObject {
    static var USER_STATUS : String {
        return ShadhinCore.instance.isUserLoggedIn ? "login" :"non-login"
    }
    static var NETWORK_TYPE : String{
        if ConnectionManager.shared.reachability?.connection == .cellular{
            return "Mobile Data"
        }else if ConnectionManager.shared.reachability?.connection == .wifi{
            return "WiFi"
        }
        
        return "Unavailable"
    }
    static var carrierName:String {
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.serviceSubscriberCellularProviders?.first?.value
        return carrier?.carrierName ?? ""
    }
    static func activeApp(){
        var parameters : [String : NSObject] = [:]
        parameters["USER_STATUS"] = USER_STATUS as NSObject
        parameters["NETWORK_TYPE"] = NETWORK_TYPE as NSObject
        
   //     Analytics.logEvent("app_open", parameters: parameters)
      //  AppEvents.logEvent(AppEvents.Name("Activate App"), parameters: parameters)
        
    }
    static func signUP(){
        var parameters : [String : NSObject] = [:]
        parameters["USER_STATUS"] = USER_STATUS as NSObject
        parameters["NETWORK_TYPE"] = NETWORK_TYPE as NSObject
        
     //   Analytics.logEvent("sign_up", parameters: parameters)
      //  AppEvents.logEvent(AppEvents.Name("Sign Up"), parameters: parameters)
        
    }
    static func signIN(){
        var parameters : [String : NSObject] = [:]
        parameters["USER_STATUS"] = USER_STATUS as NSObject
        parameters["NETWORK_TYPE"] = NETWORK_TYPE as NSObject
        
     //   Analytics.logEvent("sign_in", parameters: parameters)
      //  AppEvents.logEvent(AppEvents.Name("Sign In"), parameters: parameters)
    }
    
    static func viewContent(content : CommonContentProtocol){
        var parameters : [String : NSObject] = [:]
        parameters["USER_STATUS"] = USER_STATUS as NSObject
        parameters["NETWORK_TYPE"] = NETWORK_TYPE as NSObject
        parameters["CONTENT_TYPE"] = (content.contentType ?? "") as NSObject
        parameters["CONTENT_NAME"] = (content.title ?? "") as NSObject
        parameters["CONTENT_ID"] = (content.contentID ?? "") as NSObject
        
        let type = content.contentType?.lowercased() ?? ""
        
        let cat = type.contains("pd") ? "Podcast" : type.contains("vd") ? "VideoPodcast" : type.contains("v") ? "Video" : "Music"
        parameters["CONTENT_CATEGORY"] = cat as NSObject
        
    //    Analytics.logEvent("view_item", parameters: parameters)
    //    AppEvents.logEvent(AppEvents.Name("View Content"), parameters: parameters)
        
    }
    static func viewContent(contentName : String,contentID : String, contentType : String){
        var parameters : [String : NSObject] = [:]
        parameters["USER_STATUS"] = USER_STATUS as NSObject
        parameters["NETWORK_TYPE"] = NETWORK_TYPE as NSObject
        parameters["CONTENT_TYPE"] = contentType as NSObject
        parameters["CONTENT_NAME"] = contentName as NSObject
        parameters["CONTENT_ID"] = contentID as NSObject
        
        let type = contentName.lowercased()
        
        let cat = type.contains("pd") ? "Podcast" : type.contains("vd") ? "VideoPodcast" : type.contains("v") ? "Video" : "Music"
        parameters["CONTENT_CATEGORY"] = cat as NSObject
        
      //  Analytics.logEvent("view_item", parameters: parameters)
  //      AppEvents.logEvent(AppEvents.Name("View Content"), parameters: parameters)
        
    }
    static func gotoPro(){
        var parameters : [String : NSObject] = [:]
        parameters["USER_STATUS"] = USER_STATUS as NSObject
        parameters["NETWORK_TYPE"] = NETWORK_TYPE as NSObject
        
     //   Analytics.logEvent("add_to_cart", parameters: parameters)
      //  AppEvents.logEvent(AppEvents.Name("Add to Cart"), parameters: parameters)
    }
    static func paymentCheckOut(paymentType : String, packType : String,packValue : String,currency : String){
        var parameters : [String : NSObject] = [:]
        parameters["USER_STATUS"] = USER_STATUS as NSObject
        parameters["NETWORK_TYPE"] = NETWORK_TYPE as NSObject
        parameters["PAYMENT_TYPE"] = paymentType as NSObject
        parameters["PACK_TYPE"] = packType as NSObject
        parameters["PACK_VALUE"] = packValue as NSObject
        parameters["CURRENCY_TYPE"] = currency as NSObject
        
      //  Analytics.logEvent("begin_checkout", parameters: parameters)
    //    AppEvents.logEvent(AppEvents.Name("Initiate Checkout"), parameters: parameters)
    }
    static func robiPaymentSuccess(packType : String, packValue : String){
        var parameters : [String : NSObject] = [:]
        parameters["USER_STATUS"] = USER_STATUS as NSObject
        parameters["NETWORK_TYPE"] = NETWORK_TYPE as NSObject
        parameters["PAYMENT_TYPE"] = "Robi" as NSObject
        parameters["PACK_TYPE"] = packType as NSObject
        parameters["PACK_VALUE"] = packValue as NSObject
        parameters["CURRENCY_TYPE"] = "BDT" as NSObject
        
      //  Analytics.logEvent("purchase", parameters: parameters)
     //   AppEvents.logEvent(AppEvents.Name("Subscribe"), parameters: parameters)
    }
}

class SMAnalytics : NSObject {
    static var USER_STATUS : String {
        return ShadhinCore.instance.isUserLoggedIn ? "login" :"non-login"
    }
    static var NETWORK_TYPE : String{
        if ConnectionManager.shared.reachability?.connection == .cellular{
            return "Mobile Data"
        }else if ConnectionManager.shared.reachability?.connection == .wifi{
            return "WiFi"
        }
        
        return "Unavailable"
    }
    static var carrierName:String {
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.serviceSubscriberCellularProviders?.first?.value
        return carrier?.carrierName ?? ""
    }
    static func activeApp(){
        var parameters : [String : NSObject] = [:]
        parameters["USER_STATUS"] = USER_STATUS as NSObject
        parameters["NETWORK_TYPE"] = NETWORK_TYPE as NSObject
        
//        Analytics.logEvent("app_open", parameters: parameters)
//        AppEvents.logEvent(AppEvents.Name("Activate App"), parameters: parameters)
        
    }
    static func signUP(){
        var parameters : [String : NSObject] = [:]
        parameters["USER_STATUS"] = USER_STATUS as NSObject
        parameters["NETWORK_TYPE"] = NETWORK_TYPE as NSObject
        
//        Analytics.logEvent("sign_up", parameters: parameters)
//        AppEvents.logEvent(AppEvents.Name("Sign Up"), parameters: parameters)
        
    }
    static func signIN(){
        var parameters : [String : NSObject] = [:]
        parameters["USER_STATUS"] = USER_STATUS as NSObject
        parameters["NETWORK_TYPE"] = NETWORK_TYPE as NSObject
        
//        Analytics.logEvent("sign_in", parameters: parameters)
//        AppEvents.logEvent(AppEvents.Name("Sign In"), parameters: parameters)
    }
    
    static func viewContent(content : CommonContentProtocol){
        
//        Analytics.logEvent("sm_content_viewed",
//                           parameters: [
//                            "content_type"  : content.contentType?.lowercased() ?? "" as NSObject,
//                            "content_id"    : content.contentID?.lowercased() ?? "" as NSObject,
//                            "user_type"     : ShadhinCore.instance.defaults.shadhinUserType.rawValue  as NSObject,
//                            "content_name"  : content.title?.lowercased() ?? "" as NSObject,
//                            "platform"      : "ios" as NSObject
//                           ])
        
        var parameters : [String : NSObject] = [:]
        parameters["USER_STATUS"] = USER_STATUS as NSObject
        parameters["NETWORK_TYPE"] = NETWORK_TYPE as NSObject
        parameters["CONTENT_TYPE"] = (content.contentType ?? "") as NSObject
        parameters["CONTENT_NAME"] = (content.title ?? "") as NSObject
        parameters["CONTENT_ID"] = (content.contentID ?? "") as NSObject
        
        let type = content.contentType?.lowercased() ?? ""
        
        let cat = type.contains("pd") ? "Podcast" : type.contains("vd") ? "VideoPodcast" : type.contains("v") ? "Video" : "Music"
        parameters["CONTENT_CATEGORY"] = cat as NSObject
        
//        Analytics.logEvent("view_item", parameters: parameters)
//        AppEvents.logEvent(AppEvents.Name.viewedContent, parameters: parameters)
        
    }
    static func viewContent(contentName : String,contentID : String, contentType : String){
        var parameters : [String : NSObject] = [:]
        parameters["USER_STATUS"] = USER_STATUS as NSObject
        parameters["NETWORK_TYPE"] = NETWORK_TYPE as NSObject
        parameters["CONTENT_TYPE"] = contentType as NSObject
        parameters["CONTENT_NAME"] = contentName as NSObject
        parameters["CONTENT_ID"] = contentID as NSObject
        
        let type = contentName.lowercased()
        
        let cat = type.contains("pd") ? "Podcast" : type.contains("vd") ? "VideoPodcast" : type.contains("v") ? "Video" : "Music"
        parameters["CONTENT_CATEGORY"] = cat as NSObject
        
//        Analytics.logEvent("view_item", parameters: parameters)
//        AppEvents.logEvent(AppEvents.Name("View Content"), parameters: parameters)
        
    }
    static func gotoPro(){
        var parameters : [String : NSObject] = [:]
        parameters["USER_STATUS"] = USER_STATUS as NSObject
        parameters["NETWORK_TYPE"] = NETWORK_TYPE as NSObject
        
//        Analytics.logEvent("add_to_cart", parameters: parameters)
//        AppEvents.logEvent(AppEvents.Name("Add to Cart"), parameters: parameters)
    }
    static func paymentCheckOut(paymentType : String, packType : String,packValue : String,currency : String){
        var parameters : [String : NSObject] = [:]
        parameters["USER_STATUS"] = USER_STATUS as NSObject
        parameters["NETWORK_TYPE"] = NETWORK_TYPE as NSObject
        parameters["PAYMENT_TYPE"] = paymentType as NSObject
        parameters["PACK_TYPE"] = packType as NSObject
        parameters["PACK_VALUE"] = packValue as NSObject
        parameters["CURRENCY_TYPE"] = currency as NSObject
        
//        Analytics.logEvent("begin_checkout", parameters: parameters)
//        AppEvents.logEvent(AppEvents.Name("Initiate Checkout"), parameters: parameters)
    }
    static func robiPaymentSuccess(packType : String, packValue : String){
        var parameters : [String : NSObject] = [:]
        parameters["USER_STATUS"] = USER_STATUS as NSObject
        parameters["NETWORK_TYPE"] = NETWORK_TYPE as NSObject
        parameters["PAYMENT_TYPE"] = "Robi" as NSObject
        parameters["PACK_TYPE"] = packType as NSObject
        parameters["PACK_VALUE"] = packValue as NSObject
        parameters["CURRENCY_TYPE"] = "BDT" as NSObject
        
//        Analytics.logEvent("purchase", parameters: parameters)
//        AppEvents.logEvent(AppEvents.Name("Subscribe"), parameters: parameters)
    }
}
