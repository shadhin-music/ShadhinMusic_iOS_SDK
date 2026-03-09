//
//  ShadhinApi+Campaign.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/22/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi{
    
    func getRunningCampaigns(completion : @escaping ([String]) -> Void){
        if let cache = runningCampaignInRamCache{
            completion(cache)
            return
        }
        AF.request(
            RUNNING_CAMPAIGN,
            method: .get,
            encoding: JSONEncoding.default,
            headers: CONTENT_HEADER).responseData { response in
                var promoArray : [String] = []
                if case let .success(data) = response.result,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                   let data = json["data"] as? [Any]{
                    for obj in data{
                        if let item = obj as? [String : String],
                           let promoItem = item["CampaignName"] {
                            promoArray.append(promoItem)
                        }
                    }
                }
                #if DEBUG
                promoArray.append("Stream_And_Win")
                #endif
                self.runningCampaignInRamCache = promoArray
                return completion(promoArray)
            }
    }
    
    func getReferalData(_ completion : @escaping (_ data : ReferalObj?)->()){
        var header = API_HEADER
        header["X-Compatibility"] = X_Compatibility
        URLCache.shared.removeCachedResponse(for:  URLRequest(url: URL(string: REFERAL_DATA)!))
        AF.request(
            REFERAL_DATA,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: header).responseDecodable(of: ReferalObj.self) { response in
                switch response.result{
                case let .success(data):
                    completion(data)
                case let .failure(error):
                    completion(nil)
                    Log.error(error.localizedDescription)
                }
            }
    }
    
//    func getReferalPointHistory(_ completion : @escaping (_ data : ReferalHistory?)->()){
//        var header = API_HEADER
//        header["X-Compatibility"] = "1"
//        URLCache.shared.removeCachedResponse(for:  URLRequest(url: URL(string: REFERAL_POINT_HISTORY)!))
//        AF.request(
//            REFERAL_POINT_HISTORY,
//            method: .get,
//            parameters: nil,
//            encoding: JSONEncoding.default,
//            headers: header).responseDecodable(of: ReferalHistory.self) { response in
//                switch response.result{
//                case let .success(data):
//                    completion(data)
//                case let .failure(error):
//                    completion(nil)
//                    Log.error(error.localizedDescription)
//                }
//            }
//    }
//    
    func redeemReferalPoints(
        number: String,
        transactionType: String,
        _ completion : @escaping (_ success : Bool, _ errMsg : String?)->()){
            
        let json :[String : String] = [
            "TransactionType" : transactionType,
            "AccountType" : "M",
            "AccountNumber" : number
        ]
        var header = API_HEADER
        header["X-Compatibility"] = X_Compatibility
        AF.request(
            REDEEM_REFERAL_POINTS,
            method: .post,
            parameters: json,
            encoding: JSONEncoding.default,
            headers: header
        ).responseData { response in
            switch response.result{
            case let .success(data):
                if let json = try? JSONSerialization.jsonObject(with: data),
                   let value = json as? [String : String]{
                    if value["Status"] == "Success"{
                        completion(true, nil)
                    }else if let msg = value["Message"]{
                        completion(false, msg)
                    }
                }else{
                    completion(false, "Data parse error")
                }
            case .failure(_):
                completion(false,"experiencing technical problems now which will be fixed soon. Thanks for your patience.")
            }
        }
    }
    
//    func getReferalTransactionHistory(_ completion : @escaping (_ data : ReferalTransactionHistory?)->()){
//        var header = API_HEADER
//        header["X-Compatibility"] = X_Compatibility
//        URLCache.shared.removeCachedResponse(for:  URLRequest(url: URL(string: REFERAL_TRANSACTION_HISTORY)!))
//        AF.request(
//            REFERAL_TRANSACTION_HISTORY,
//            method: .get,
//            parameters: nil,
//            encoding: JSONEncoding.default,
//            headers: header
//        ).responseDecodable(of: ReferalTransactionHistory.self) { response in
//            switch response.result{
//            case let .success(data):
//                completion(data)
//            case let .failure(error):
//                Log.error(error.localizedDescription)
//                completion(nil)
//            }
//        }
//    }
    
    func getUserStreamingPoints(
        _ completion : @escaping (_ count : Int)->()){
            AF.request(
                USER_STREAMING_POINTS,
                method: .get,
                parameters: nil,
                encoding: JSONEncoding.default,
                headers: API_HEADER
            ).responseData { response in
                switch response.result{
                case let .success(data):
                    if let value = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                       let count = value["data"] as? Int{
                        completion(count)
                    }else{
                        completion(0)
                    }
                case let .failure(error):
                    completion(0)
                    Log.error(error.localizedDescription)
                }
            }
        }
    
    func getCashBackStatus(_ completion: @escaping (String) -> Void ){
        var header = API_HEADER
        header["X-Compatibility"] = X_Compatibility
        AF.request(USER_CASH_BACK_STATUS,
                          method: .get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: header
        ).responseData { response in
            switch response.result{
            case let .success(data):
                if let value = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                   let message = value["Status"] as? String {
                    completion(message)
                }else{
                    completion("unknown")
                }
            case let .failure(error):
                completion("We are experiencing technical problems now which will be fixed soon. Thanks for your patience.")
                Log.error(error.localizedDescription)
            }
        }
    }
    
    func setCashBackNumber(
        number: String,
        _ completion: @escaping (String, String) -> Void ){
        var header = API_HEADER
        header["X-Compatibility"] = X_Compatibility
        AF.request(
            "\(CASH_BACK_NUMBER_SET)+880\(number)",
            method: .post,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: header
        ).responseData { response in
            switch response.result{
            case let .success(data):
                if let value = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                   let status = value["Status"] as? String,
                   let message = value["Message"] as? String {
                    completion(status, message)
                }else{
                    completion("Error", "Unable to parse Data")
                }
            case let .failure(error):
                completion("We are experiencing technical problems now which will be fixed soon. Thanks for your patience.",error.localizedDescription)
            }
        }
    }
    
    func giveUserLoginPoint(){
        var header = API_HEADER
        header["X-Compatibility"] = X_Compatibility
        AF.request(
            GIVE_LOGIN_POINT,
            method: .post,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: header
        ).response { (response) in
            //ignore response
        }
    }
    
    func redeemCoupon(
        _ couponCode: String,
        _ completion : @escaping (_ success : Bool, _ msg : String)->()){
        AF.request(
            "\(ADD_COUPON)\(couponCode)",
            method: .post, parameters: [:],
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseData { response in
            switch response.result{
            case let .success(data):
                if let value = try? JSONSerialization.jsonObject(with: data) as? [String : Any] ,
                   let message = value["message"] as? String,
                   let status = value["status"] as? String{
                    if status.lowercased() == "success"{
                        completion(true, message)
                    }else{
                        completion(false, message)
                    }
                }else{
                    completion(false, "Data parse error")
                }
            case .failure(_):
                completion(false,"experiencing technical problems now which will be fixed soon.Thanks for your patience.")
            }
        }
    }
    
    func getConcertEventsDetails(
        _ completion : @escaping (_ eventData: ConcertEventObj?)->Void){
        AF.request(
            CONCERT_TICKET_DETAILS,
            method: .get,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: ConcertEventObj.self) { response in
            switch response.result{
            case let .success(data):
                completion(data)
            case let .failure(error):
                completion(nil)
                Log.error(error.localizedDescription)
            }
        }
    }
    
    func getConcertTicketPurchaseUrl(
        campaignID    : Int = 1,
        userName      : String,
        userEmail     : String,
        idType        : String,
        idNumber      : String,
        ticketType    : String,
        quantity      : Int,
        phoneNumber   : String,
        paymentMethod : Int,
        _ completion : @escaping (_ data: TicketPurchaseUrlObj?, _ err: String?)-> Void)
    {
          
        let body :[String : Any] = [
            "campaignId"   : campaignID,
            "userName"     : userName,
            "userEmail"    : userEmail,
            "idType"       : idType,  // NID, PHOTOID, BCERT
            "idNumber"     : idNumber,
            "ticketType"   : ticketType, //ALL ACCESS,VIP,GENERAL
            "quantity"     : quantity,
            "phoneNumber"  : phoneNumber
        ]
        
        var url = ""
        if paymentMethod == 0{
            url = INITIATE_TICKET_PAYMENT_BKASH
        }else{
            url = INITIATE_TICKET_PAYMENT_SSL
        }
        
        AF.request(
            url,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: TicketPurchaseUrlObj.self) { response in
            switch response.result{
            case let .success(data):
                completion(data, nil)
            case let .failure(error):
                completion(nil, error.localizedDescription)
            }
        }
    }
    
    func checkTicketPurchase(
        purchaseCode: String,
        paymentMethod: Int,
        _ completion : @escaping (_ success: Bool)->Void
    ){
        var url = ""
        if paymentMethod == 0{
            url = CHECK_TICKET_PAYMENT_BKASH
        }else{
            url = CHECK_TICKET_PAYMENT_SSL
        }
        
        AF.request(
            "\(url)\(purchaseCode)",
            method: .get,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseData { response in
            switch response.result{
            case let .success(data):
                if let value = try? JSONSerialization.jsonObject(with: data) as? [String : Any] ,
                   let status = value["status"] as? String,
                   status.lowercased() == "success"{
                    completion(true)
                }else{
                    completion(false)
                }
            case let .failure(error):
                completion(false)
                Log.error(error.localizedDescription)
            }
        }
    }
    
    func getPurchasedTicket(
        _ completion : @escaping (_ data: PurchasedTicketObj?, _ err: String?)-> Void
    ){
        AF.request(
            GET_PURCHASED_TICKETS,
            method: .get,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: PurchasedTicketObj.self) { response in
            switch response.result{
            case let .success(data):
                completion(data, nil)
            case let .failure(error):
                completion(nil, error.localizedDescription)
            }
        }
    }
    
    //huda campaign
    func getStreamAndWinCampaignData(complete : @escaping ((Result<StreamNwinCampaignResponse,AFError>) ->Void)){
        guard let url = URL(string: CAMPAIGN_RUNNING) else {
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.method = .get
        
        AF.request(urlRequest)
            .responseDecodable(of: StreamNwinCampaignResponse.self) { response in
                switch response.result{
                case .success(let result):
                    complete(.success(result))
                case .failure(let error):
                    complete(.failure(error))
                }
            }
    }
    
    func getStreamAndWinCampaignActiveData(complete : @escaping ((Result<CampaignResponseNew,AFError>) ->Void)){
        guard let url = URL(string: CAMPAIGN_ACTIVE) else {
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.method = .get
        urlRequest.headers = API_HEADER
        AF.request(urlRequest)
            .responseDecodable(of: CampaignResponseNew.self) { response in
                switch response.result{
                case .success(let result):
                    complete(.success(result))
                case .failure(let error):
                    complete(.failure(error))
                }
            }
    }
    
    func getStreamAndWinCampaignDetailsData(campaignID: String, complete : @escaping ((Result<CampaignResponseNew,AFError>) ->Void)){
        guard let url = URL(string: CAMPAIGN_DETAILS+campaignID) else {
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.method = .get
        urlRequest.headers = API_HEADER
        
        AF.request(urlRequest)
            .responseDecodable(of: CampaignResponseNew.self) { response in
                switch response.result{
                case .success(let result):
                    complete(.success(result))
                case .failure(let error):
                    complete(.failure(error))
                }
            }
    }
    
    func getStreamAndWinCampaignDailyData(campaignID: String, complete : @escaping ((Result<CampaignResponseNew,AFError>) ->Void)){
        guard let url = URL(string: CAMPAIGN_DAILY+campaignID+"&days=1") else {
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.method = .get
        urlRequest.headers = API_HEADER
        AF.request(urlRequest)
            .responseDecodable(of: CampaignResponseNew.self) { response in
                switch response.result{
                case .success(let result):
                    complete(.success(result))
                case .failure(let error):
                    complete(.failure(error))
                }
            }
    }
    
    func getStreamAndWinCampaignMonthlyData(campaignID: String, complete : @escaping ((Result<CampaignResponseNew,AFError>) ->Void)){
        guard let url = URL(string: CAMPAIGN_MONTHLY+campaignID+"&days=30") else {
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.method = .get
        urlRequest.headers = API_HEADER

        AF.request(urlRequest)
            .responseDecodable(of: CampaignResponseNew.self) { response in
                switch response.result{
                case .success(let result):
                    complete(.success(result))
                case .failure(let error):
                    complete(.failure(error))
                }
            }
    }
    
}
