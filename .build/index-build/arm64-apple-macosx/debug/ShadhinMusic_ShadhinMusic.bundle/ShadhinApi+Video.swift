//
//  ShadhinApi+Video.swift
//  Shadhin
//
//  Created by Gakk Alpha on 10/24/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi{
    
    func getVideoPatches(
        completion: @escaping (_ data: [VideoPatch]?,Error?)-> Void)
    {
        AF.request(
            GET_ALL_VIDEO_CATEGORIES,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER)
        .responseDecodable(of: VideoPatchesObj.self) { response in
            switch response.result{
            case let .success(data):
                completion(data.data,nil)
            case .failure(_):
                let error = NSError(domain: "", code: 400, userInfo: [ NSLocalizedDescriptionKey: "experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                completion(nil,error)
            }
        }
    }
    
}
