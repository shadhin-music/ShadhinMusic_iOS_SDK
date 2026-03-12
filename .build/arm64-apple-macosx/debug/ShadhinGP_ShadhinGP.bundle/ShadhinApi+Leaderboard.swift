//
//  ShadhinApi+Leaderboard.swift
//  Shadhin
//
//  Created by Joy on 16/2/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi{
    
    class Leaderboard{
        private static let CAMPAIGN_BASE_URL = "https://campaign.shadhinmusic.com/api/v5"
        private static let DAILY_DATA_URL = {(campaignId : String,date : String, name: String)-> String in
            return "\(CAMPAIGN_BASE_URL)/ClientLeaderboard/GetUserStreamingDetail?campaignType=\(campaignId)&onDate=\(date)&name=\(name)"
        }
        private static var MONTHLY_DATA_URL = {(campaignType : String, date : String, name: String)->  String in
            return "\(CAMPAIGN_BASE_URL)/ClientLeaderboard/GetStreamingDetail?campaignType=\(campaignType)&onDate=\(date)&name=\(name)"
        }
 
        private static var PRIZE_URL = {(campaignType : String)-> String in
            return "\(BASE_URL)/CampaignSchedule/CampaignScheduleDetails?campaignName=\(campaignType)"
        }
        private static var BKASH_DAILY_DATA = {(campaignID : String,onDate : String, name: String)-> String in
            return "\(BASE_URL)/ClientLeaderboard/GetUserStreamingDetail?campaignType=\(campaignID)&onDate=\(onDate)&name=\(name)"
        }
        private static var BKASH_MONTHLY_DATA = {(campaignID : String,onDate : String, name: String)-> String in
            return "\(BASE_URL)/ClientLeaderboard/GetStreamingDetail?campaignType=\(campaignID)&onDate=\(onDate)&name=\(name)"
        }
//        @available (* , deprecated, message:"This method is deprecated")
//        static func getUserRank(campaignID : String , serviceId : String,complete : @escaping (Result<UserRankingResponse,AFError>)-> Void){
//            let formate = DateFormatter()
//            formate.dateFormat = "d MMM yyyy"
//            let date = formate.string(from: Date())
//            let str = ALL_USER_RANK(campaignID,date).safeUrl()
//            guard let url = URL(string: str) else {return}
//
//            var urlRequest = URLRequest(url: url)
//            urlRequest.headers = ShadhinApiContants().API_HEADER
//            AF.request(urlRequest)
//                .responseDecodable(of: UserRankingResponse.self) { response in
//                    if let data = response.data, let str = try? String(data: data, encoding: .utf8){
//                        Log.info(str)
//                    }
//                    switch response.result{
//                    case .success(let result):
//                        complete(.success(result))
//                    case .failure(let error):
//                        complete(.failure(error))
//                    }
//                }
//        }
        static func getAllUserRank(campaignType : String, serviceId : String, name: String, complete :@escaping (Result<AllUserRankingResponse,AFError>)-> Void){
            let formate = DateFormatter()
            formate.dateFormat = "d MMM yyyy"
            let date = formate.string(from: Date())
            
            let str = campaignType == "1" ? DAILY_DATA_URL(campaignType, date, name).safeUrl() : MONTHLY_DATA_URL(campaignType, date, name).safeUrl()
            
            guard let url = URL(string: str) else {return}
            
            var urlRequest = URLRequest(url: url)
            urlRequest.headers = ShadhinApiContants().API_HEADER
            
            AF.request(urlRequest)
                .responseDecodable(of: AllUserRankingResponse.self) { response in
//                    if let data = response.data, let str = try? String(data: data, encoding: .utf8){
//                        Log.info(str)
//                    }
                    switch response.result{
                    case .success(let result):
                        complete(.success(result))
                    case .failure(let error):
                        complete(.failure(error))
                    }
                }
        }
        
        static func getBkashUserRanking(campaignID : String,onDate : Date = Date(), name: String, complete : @escaping (Result<LeaderboardBkashResponse,AFError>)->Void){
            let formate = DateFormatter()
            formate.dateFormat = "d MMM yyyy"
            let date = formate.string(from: Date())
            var url = ""
            if campaignID == "1"{
                url = BKASH_DAILY_DATA(campaignID, date, name).safeUrl()
            }else{
                url = BKASH_MONTHLY_DATA(campaignID, date, name).safeUrl()
            }
            guard let url = URL(string: url) else {return}
            var urlRequest = URLRequest(url: url)
            urlRequest.headers = ShadhinApiContants().API_HEADER
            
            AF.request(urlRequest)
                .responseDecodable(of: LeaderboardBkashResponse.self) { response in
//                    if let data = response.data, let str = try? String(data: data, encoding: .utf8){
//                        Log.info(str)
//                    }
                    switch response.result{
                    case .success(let result):
                        complete(.success(result))
                    case .failure(let error):
                        complete(.failure(error))
                    }
                }
        }
        
        static func getPrize(campaignType : String,complete : @escaping (Result<PrizeResponseArr,AFError>)->Void){
            guard let url = URL(string: PRIZE_URL(campaignType).safeUrl()) else {
                return
            }
            var urlRequest = URLRequest(url: url)
            urlRequest.headers = ShadhinApiContants().API_HEADER
            
            AF.request(urlRequest)
                .responseDecodable(of: PrizeResponseArr.self) { response in
                    switch response.result{
                    case .success(let result):
                        complete(.success(result))
                    case .failure(let error):
                        complete(.failure(error))
                    }
                }
        }
    }
}
