//
//  ShadhinApi+Download.swift
//  Shadhin
//
//  Created by Admin on 7/7/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi{
    
    func getDownloadUrl(
        _ content       : CommonContentProtocol,
        completion      : @escaping (_ playUrl: String?, _ error: Error?) -> Void)
    {
        
        guard let name = content.playUrl?.safeUrl() else {return}
        let url = GET_DOWNLOAD_URL(name)
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue("Bearer \(ShadhinCore.instance.defaults.userSessionToken)", forHTTPHeaderField: "Authorization")
        AF.request(request).responseData {
            response in
            switch response.response?.statusCode {
            case 200:
                if let data = response.data,
                   let value = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                   let data = value["Data"] as? String,
                   let url = URL(string: data){
                    completion(url.absoluteString, nil)
                }else{
                    completion(nil, NSError(domain:"", code:500, userInfo:nil))
                }
            case 409:
                //restriction
                Log.info("SHADHIN LOG ContentId \(String(describing: content.contentID)) is restricted \(String(describing: response.data))")
                completion(nil, response.error)
                break
            case 402:
                //payment required
                Log.info("SHADHIN LOG ContentId \(String(describing: content.contentID)) requires payment")
                completion(nil, response.error)
                break
            case 400:
                //payment required
                Log.info("SHADHIN LOG LOGIN SESSION INVALID")
                completion(nil, response.error)
                break
            default:
                break
            }
        }
    }
    
    func downloadCompletePost(model : CommonContentProtocol){
        
        //todo guard check
        let body:[String : String] = [
            "albumId": model.albumId ?? "",
            "ContentId": model.contentID ?? "90885",
            "ContentType": model.contentType ?? "S",
            "RootId": model.contentID ?? "90885",
            "RootType": model.contentType ?? "S"
        ]
        AF.request(DOWNLOAD_COMPLETE_HISTORY_POST, method: .post, parameters: body, encoding: JSONEncoding.default, headers: API_HEADER).responseData { respons in
            if let data = respons.data{
                Log.info(String(data: data, encoding: .utf8)!)
            }
            
        }
    }
    
    func downloadCompleteGET(complete : @escaping (Result<[DownloadContentModel], Error>)->Void){
        AF.request(
            DOWNLOAD_COMPLETE_HISTORY_GET,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER)
        .responseDecodable(of: DownloadHistoryObj.self) { response in
            switch response.result{
            case let .success(data):
                complete(.success(data.data))
            case .failure(_):
                let error = NSError(domain: "", code: 400, userInfo: [ NSLocalizedDescriptionKey: "experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                complete(.failure(error))
            }
        }
    }
    
    func deleteDownloadHistory(contents : [CommonContentProtocol]){
        var body : [[String:String]] = []
        contents.forEach { cdp in
            let x  : [String:String] = ["contentId": cdp.contentID!,"contentType" : cdp.contentType!]
            body.append(x)
        }
        var request = URLRequest(url: URL(string: DOWNLOAD_HISTORY_DELETE)!)
        request.httpMethod = HTTPMethod.delete.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(ShadhinCore.instance.defaults.userSessionToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try! JSONSerialization.data(withJSONObject: body)
        AF.request(request).response {
            response in
            
        }
    }
}
