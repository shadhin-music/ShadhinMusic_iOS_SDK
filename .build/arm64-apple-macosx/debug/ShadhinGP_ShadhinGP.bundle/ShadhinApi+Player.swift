//
//  ShadhinApi+Player.swift
//  Shadhin
//
//  Created by Gakk Alpha on 3/8/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit
import Foundation

extension ShadhinApi{
    
    func getPlayUrl(
        _ content           : CommonContentProtocol,
        reportError       : Bool = true,
        completion          : @escaping (_ playUrl: String?, _ error: Error?) -> Void)
    {
        
        var contentType: String?
        var podcastShowCode: String?
        var trackType: String?
        var urlKey: String?
        
        if let _contentType = content.contentType {
            if _contentType.uppercased().contains("PD"){
                podcastShowCode = String(_contentType.suffix(_contentType.count - 2)).uppercased()
                contentType = String(_contentType.prefix(2)).uppercased()
            }else if _contentType.uppercased().contains("VD"){
                podcastShowCode = String(_contentType.suffix(_contentType.count - 2)).uppercased()
                contentType = String(_contentType.prefix(2)).uppercased()
            } else{
                contentType = _contentType
                podcastShowCode = ""
            }
        }else{
            contentType = "S"
            podcastShowCode = ""
        }
        var url: URL? = nil
        if let decryptedUrlStr = content.playUrl?.decryptUrl(){
            let strUrl =  decryptedUrlStr.contains("http") ? decryptedUrlStr.replacingOccurrences(of: " ", with: "%20") : decryptedUrlStr
            url =  URL(string: strUrl)
        }
        trackType = content.trackType ?? ""
        urlKey = url?.absoluteString ?? ""
        _ = getPlayUrl(content.contentType ?? "", podcastShowCode ?? "", trackType ?? "", urlKey ?? "", reportError: reportError, completion: completion)
    }
    
    public func getPlayURLTwo(
        _ contentType       : String,
        _ podcastShowCode   : String,
        _ trackType         : String,
        _ urlKey            : String,
        _ willRetry         : Bool = false,
        reportError         : Bool = true,
        completion          : @escaping (_ playUrl: String?, _ error: Error?) -> Void) {
        
            var url: URL? = nil
            var urlKey = urlKey
            let apiUrl = GET_PLAY_URL(contentType, podcastShowCode, trackType, urlKey).safeUrl()
            
            if let decryptedUrlStr = apiUrl.decryptUrl(){
                let strUrl =  decryptedUrlStr.contains("http") ? decryptedUrlStr.replacingOccurrences(of: " ", with: "%2F") : decryptedUrlStr
                url =  URL(string: strUrl)
            }
            
            urlKey = url?.absoluteString ?? ""
            _ = getPlayUrl(contentType, podcastShowCode, trackType, urlKey, reportError: reportError, completion: completion)
    }
        
    func getPlayUrl(
        _ contentType       : String,
        _ podcastShowCode   : String,
        _ trackType         : String,
        _ urlKey            : String,
        _ willRetry         : Bool = false,
        reportError         : Bool = true,
        completion : @escaping (_ playUrl: String?, _ error: Error?) -> Void) -> DataRequest?
    {
        
//        let apiUrl = GET_PLAY_URL(contentType, podcastShowCode, trackType, urlKey).safeUrl()
        let apiUrl = "https://connect.shadhinmusic.com/api/v1/streamings/url?ContentType=\(contentType)&Path=\(urlKey)"
        
        
        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue("Bearer \(ShadhinCore.instance.defaults.userSessionToken)", forHTTPHeaderField: "Authorization")
        return AF.request(request).responseData { response in
            switch response.response?.statusCode {
            case 200:
                if let data = response.data,
                   let json = try? JSONSerialization.jsonObject(with: data),
                   let value = json as? [String : Any]{
                    if let data = value["data"] as? String ?? value["Data"] as? String {
                        var decrypt: URL? = nil
                        if let decryptedUrlStr = data.decryptPlayerUrl(){
                            let strUrl =  decryptedUrlStr.contains("http") ? decryptedUrlStr.replacingOccurrences(of: " ", with: "%2F") : decryptedUrlStr
                            decrypt = URL(string: strUrl)
                        }
                        completion(decrypt?.absoluteString, nil)
                    }else if let msg = value["Message"] as? String{
                        if !willRetry && reportError {
                            self.showAlert(title: "Error", msg: msg)
                        }
                        completion(nil, NSError(domain: "", code: 500, userInfo: nil))
                    }else{
                        if !willRetry && reportError{
                            self.showAlert(title: "Parse Error", msg: "We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
                        }
                        completion(nil, NSError(domain: "", code: 500, userInfo: nil))
                    }
                }else{
                    if !willRetry && reportError {
                        self.showAlert(title: "Parse Error", msg: "We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
                    }
                    completion(nil, NSError(domain: "", code: 500, userInfo: nil))
                }
            case 409:
                //restriction
                if let data = response.data,
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                   let msg = json["Message"]{
                    if !willRetry && reportError{
                        self.showRestrictionReleaseAlert(msg: msg)
                    }
                }
                completion(nil, response.error)
                break
            case 402:
                //payment required
                //print("SHADHIN LOG ContentId \(urlKey) requires payment")
                if !willRetry && reportError {
                    self.showAlert(title: "Subscription Error", msg: "This content requires an active pro plan")
                }
                completion(nil, response.error)
                break
            case 401:
                //Invalid token
                if !willRetry && reportError {
                    self.showAlert(title: "Session Error", msg: "It seems your session is invalid, please re-log in")
                }
                completion(nil, response.error)
                break
            default:
                if let data = response.data,
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                   let msg = json["Message"]{
                    if !willRetry && reportError {
                        self.showAlert(title: "Server Error", msg: msg)
                    }
                }else{
                    if !willRetry && reportError{
                        self.showAlert(title: "Parse Error", msg: "We are experiencing technical problems now which will be fixed soon. Thanks for your patience.")
                    }
                }
                completion(nil, response.error)
                break
            }
        }
    }
    
    func getPlayUrlV2(
        _ trackType         : String,
        _ urlKey            : String,
        _ willRetry         : Bool = false,
        reportError         : Bool = true,
        completion : @escaping (_ playUrl: String?, _ error: Error?) -> Void) -> DataRequest?
    {
        
        let apiUrl = GET_PLAY_URL_V2(trackType, urlKey).safeUrl()
        
        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = HTTPMethod.get.rawValue
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.addValue("Bearer \(ShadhinCore.instance.defaults.userSessionToken)", forHTTPHeaderField: "Authorization")
        return AF.request(request).responseData { response in
            switch response.response?.statusCode {
            case 200:
                if let data = response.data,
                   let json = try? JSONSerialization.jsonObject(with: data),
                   let value = json as? [String : Any]{
                    if let data = value["Data"] as? String,
                       let url = URL(string: data){
                        completion(url.absoluteString, nil)
                    }else if let msg = value["Message"] as? String{
                        if !willRetry && reportError {
                            self.showAlert(title: "Error", msg: msg)
                        }
                        completion(nil, NSError(domain: "", code: 500, userInfo: nil))
                    }else{
                        if !willRetry && reportError{
                            self.showAlert(title: "Parse Error", msg: "We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
                        }
                        completion(nil, NSError(domain: "", code: 500, userInfo: nil))
                    }
                }else{
                    if !willRetry && reportError {
                        self.showAlert(title: "Parse Error", msg: "We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
                    }
                    completion(nil, NSError(domain: "", code: 500, userInfo: nil))
                }
            case 409:
                //restriction
                if let data = response.data,
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                   let msg = json["Message"]{
                    if !willRetry && reportError{
                        self.showRestrictionReleaseAlert(msg: msg)
                    }
                }
                completion(nil, response.error)
                break
            case 402:
                //payment required
                //print("SHADHIN LOG ContentId \(urlKey) requires payment")
//                if !willRetry && reportError {
//                    self.showAlert(title: "Subscription Error", msg: "This content requires an active pro plan")
//                }
                completion(nil, response.error)
                break
            case 401:
                //Invalid token
                if !willRetry && reportError {
                    self.showAlert(title: "Session Error", msg: "It seems your session is invalid, please re-log in")
                }
                completion(nil, response.error)
                break
            default:
                if let data = response.data,
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                   let msg = json["Message"]{
                    if !willRetry && reportError {
                        self.showAlert(title: "Server Error", msg: msg)
                    }
                }else{
                    if !willRetry && reportError{
                        self.showAlert(title: "Parse Error", msg: "We are experiencing technical problems now which will be fixed soon. Thanks for your patience.")
                    }
                }
                completion(nil, response.error)
                break
            }
        }
    }
    

    
    
    public func resetRestriction(){
        let apiUrl = RESET_RESTRICTION
        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("Bearer \(ShadhinCore.instance.defaults.userSessionToken)", forHTTPHeaderField: "Authorization")
        AF.request(request).responseData { response in
            self.isRestrictionPaidAlertNotShowing = true
            switch response.response?.statusCode {
            case 200:
                if let data = response.data,
                   let json = try? JSONSerialization.jsonObject(with: data),
                   let value = json as? [String : Any]{
                    if let msg = value["Message"] as? String{
                        self.showAlert(title: "Success", msg: msg)
                    }
                }
            default:
                if let data = response.data,
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                   let msg = json["Message"]{
                    self.showAlert(title: "Server Error", msg: msg)
                }else{
                    self.showAlert(title: "Server Error", msg:"We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
                }
            }
        }
    }
    
    
    
    public func releaseServerLock(){
        AF.request(
            RELEASE_PLAY_LOCK,
            method: .post,
            parameters: nil,
            headers: API_HEADER)
        .responseData{
            response in
            guard response.response?.statusCode == 200 else {return}
        }
    }
    
    public func showAlert(title: String,msg: String){
        guard isRestrictionPaidAlertNotShowing else {return}
        isRestrictionPaidAlertNotShowing = false
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.isRestrictionPaidAlertNotShowing = true
        }))
        ShadhinCore.instance.getTopViewController()?.present(alert, animated: true, completion: nil)
    }
    
    
    public func showRestrictionReleaseAlert(msg: String){
        guard isRestrictionPaidAlertNotShowing else {return}
        isRestrictionPaidAlertNotShowing = false
        let alert = UIAlertController(title: "Restriction Error", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { action in
            //self.isRestrictionPaidAlertNotShowing = true
            self.resetRestriction()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            self.isRestrictionPaidAlertNotShowing = true
        }))
        ShadhinCore.instance.getTopViewController()?.present(alert, animated: true, completion: nil)
    }
    
}
