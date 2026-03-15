//
//  ShadhinApi+Podcast.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/22/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi{
    
    func getPodcastExplore(completion : @escaping (PodcastExploreObj?, String?) -> Void){
        // print(PODCAST_EXPLORE)
        AF.request(
            PODCAST_EXPLORE,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: PodcastExploreObj.self) { response in
            switch response.result{
            case let .success(data):
                completion(data, nil)
            case .failure(_):
                completion(nil,"We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
            }
        }
    }
    
    func getPodcastShowList(completion : @escaping (PodcastShowObj?) -> Void){
        AF.request(
            GET_PODCAST_SHOWS,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: PodcastShowObj.self){ response in
            switch response.result{
            case let .success(data):
                completion(data)
            case let .failure(error):
                completion(nil)
                Log.error(error.localizedDescription)
            }
        }
    }
    
//    func getPodcastDetails(
//        _ podcastType: String,
//        _ specificEpisodeID: Int,
//        _ podcastShowCode: String,
//        _ completion : @escaping (PodcastDetailsObj?, _ errMsg: String?) -> Void)
//    {
//        
//        var url = GET_PODCAST_DETAILS
//        if specificEpisodeID == 0{
//            url = url + "V6?podType=\(podcastType)&contentTYpe=\(podcastShowCode.lowercased())"
//        }else{
//            url = url + "byepisodeIdV6?podType=\(podcastType)&episodeId=\(specificEpisodeID)&contentTYpe=\(podcastShowCode.lowercased())"
//        }
//        url = url + "&isPaid=\(ShadhinCore.instance.isUserPro)"
//        print(url)
//        AF.request(
//            url,
//            method: .get,
//            parameters: nil,
//            encoding: JSONEncoding.default,
//            headers: API_HEADER
//        ).responseDecodable(of: PodcastDetailsObj.self){ response in
//            switch response.result{
//            case let .success(data):
//                completion(data, nil)
//            case let .failure(error):
//                completion(nil, error.localizedDescription)
//            }
//        }
//    }
    
    func getPodcastLikedCount(
        podcastType: String,
        contentID: Int,
        completion: @escaping (PodcastAPI.PodcastLike?)->Void)
    {
        AF.request(
            GET_PODCAST_LIKED_COUNT(podcastType, contentID),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER)
        .responseDecodable(of: PodcastAPI.PodcastLike.self) { response in
            switch response.result{
            case let .success(data):
                completion(data)
            case let .failure(error):
                completion(nil)
                Log.error(error.localizedDescription)
            }
        }
    }
    
    func likePodcastBy(
        contentID: String,
        podcastType: String,
        completion: @escaping (PodcastAPI.PodcastLike?)->Void)
    {
        let body = [
            "ContentId" : contentID,
            "ContentType" : podcastType
        ]
        AF.request(
            POST_PODCAST_LIKE,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: PodcastAPI.PodcastLike.self){ response in
            switch response.result{
            case let .success(data):
                completion(data)
            case let .failure(error):
                completion(nil)
                Log.error(error.localizedDescription)
            }
        }
    }
}
