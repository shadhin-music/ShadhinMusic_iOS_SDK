//
//  ApiCore.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/24/21.
//  Copyright © 2021 Cloud 7 Limited. All rights reserved.
//

import Foundation

var AF = Session.default

public class ShadhinApi : ShadhinApiURL{
    static let cancel_secretKey = "secretKeyb1DEYmhXrTYiyU65EWI8U1h"
    static let cancel_iv_secret = "ivSec1HJFhYrhcr5"
    override init() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        let configuration = URLSessionConfiguration.default
        var defaultHeaders = HTTPHeaders.default
        defaultHeaders.add(name: "device-name", value: "\(UIDevice.modelName)")
        defaultHeaders.add(name: "app-version", value: "iOS-\(version)")
        defaultHeaders.add(name: "user-id",     value: "\(ShadhinDefaults().userIdentity)")
        defaultHeaders.add(name: "countryCode", value: ShadhinDefaults().geoLocation.lowercased())
        configuration.headers = defaultHeaders
    }
    
    
    public func getStreamingPoints(
        completion  : @escaping (_ isSuccess: Bool, _ totalCount: String?)->Void)
    {
        AF.request(STREAM_POINTS, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: API_HEADER).responseData { response in
            switch response.result{
            case .success(let data):
                if let json = try? JSONSerialization.jsonObject(with: data),
                   let value = json as? [String : Any],
                   let point = value["Data"] as? Int{
                    return completion(true, "\(point)")
                } else {
                    return completion(true, "Unknown")
                }
            case .failure(let error):
                Log.error(error.localizedDescription)
                return completion(false,"We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
            }
        }
    }
    
    public func removeSocialCredentials(
        completion  : @escaping (_ isSuccess: Bool)->Void)
    {
        AF.request(REMOVE_SOCIAL, method: .post, encoding: JSONEncoding.default, headers: API_HEADER).responseData { response in
            if response.response?.statusCode == 200{
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
    func getTopTenTrendingData(
        type        : String,
        completion  : @escaping (_ data: TopTenTrendingObj?,Error?)-> Void)
    {
        AF.request(TOP_TEN_TRENDING(type), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: API_HEADER).responseDecodable(of: TopTenTrendingObj.self) { response in
            switch response.result {
            case let .success(data):
                completion(data,nil)
            case .failure(_):
            let error = NSError(domain: "", code: 400, userInfo: [ NSLocalizedDescriptionKey: "experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                completion(nil,error)
            }
        }
    }
    
    //get image url
    static func getImageUrl(url : String,size : Int)-> URL?{
        let urlString = url.replacingOccurrences(of: "<$size$>", with: "\(size)")
        return URL(string: urlString.safeUrl())
    }
    
    
    
    func getHelpCenterFAQData(_ completion : @escaping (_ responseModel: Result<FAQResponse, AFError> )->()){
        
        AF.request(
            "https://connect.shadhinmusic.com/api/v1/faqs",
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: FAQResponse.self) { response in
            completion(response.result)
        }
    }
    
    func getAnswerFAQDataByID(id: Int, _ completion : @escaping (_ responseModel: Result<FAQAnswerResponse, AFError> )->()){
        AF.request(
            "https://connect.shadhinmusic.com/api/v1/faqs/ans?faqId=\(id)",
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: FAQAnswerResponse.self) { response in
            completion(response.result)
        }
    }
    
    func sendLikedFAQFeedback(faqAnsId: Int, isLiked: Bool, completion: @escaping (Result<FAQFeedbackResponse, Error>) -> Void) {
        
        guard let url = URL(string: "https://connect.shadhinmusic.com/api/v1/faqs/feedback") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }
        
        let request = FAQFeedbackLikedRequest(faqAnsId: faqAnsId, isLiked: isLiked)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 404)))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(FAQFeedbackResponse.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func sendDisLikedFAQFeedback(faqAnsId: Int, isDisLiked: Bool, completion: @escaping (Result<FAQFeedbackResponse, Error>) -> Void) {
        
        guard let url = URL(string: "https://connect.shadhinmusic.com/api/v1/faqs/feedback") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }
        
        let request = FAQFeedbackDisLikedRequest(faqAnsId: faqAnsId, isDisLiked: isDisLiked)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 404)))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(FAQFeedbackResponse.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
