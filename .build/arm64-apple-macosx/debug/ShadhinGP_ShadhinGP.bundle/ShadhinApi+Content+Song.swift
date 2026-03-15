//
//  ShadhinApi+Song.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/14/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

private var cache : [String:LyricsObj] = [:]

extension ShadhinApi{
    
    
    func getLyricsBy(
        _ songID : String,
        completion : @escaping (LyricsObj?) -> Void ) -> DataRequest?
    {
        
        if let cacheItem = cache[songID] {
            completion(cacheItem)
            return nil
        }
        
        let request = AF.request(
            GET_LYRICS(songID),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: LyricsObj.self){ response in
            switch response.result{
            case let .success(data):
                completion(data)
                cache[songID] = data
            case let .failure(error):
                completion(nil)
                Log.error(error.localizedDescription)
            }
        }
        return request
    }
    
}
