//
//  ShadhinApi+Search.swift
//  Shadhin
//
//  Created by Gakk Alpha on 5/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi{
    
    func getSearchResult(
        searchText: String,
        completion: @escaping (_ data: SearchObj.SearchData?,Error?)-> Void)
    {
        let url = SEARCH_CONTENT(searchText.replacingOccurrences(of: " ", with: "%20"))
        AF.request(
            url,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER)
        .responseDecodable(of: SearchObj.self) { response in
            switch response.result{
            case let .success(data):
                completion(data.data,nil)
            case .failure(_):
                let error = NSError(domain: "", code: 400, userInfo: [ NSLocalizedDescriptionKey: "experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                completion(nil,error)
            }
        }
    }
    
    func addSearchHistoryToServer(
        _ data : CommonContentProtocol)
    {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formatedDate = dateFormatter.string(from: date)
        
        guard let id = data.contentID,
              let type = data.contentType else {
            return
        }
        
        let body: [String : Any] = [
            "ContentId" : id,
            "Type" : type,
            "CreateDate" : formatedDate
        ]
        
        AF.request(
            ADD_SEARCH_HISTORY,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: API_HEADER)
        .response { (response) in
            //ignored
        }
    }
    
    func getSearchHistory(
        completion : @escaping (UserSearchedItemsObj?, Error?) -> Void)
    {
        AF.request(
            GET_SEARCH_HISTORY,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER)
        .responseDecodable(of: UserSearchedItemsObj.self) { response in
            switch response.result{
            case let .success(data):
                completion(data,nil)
            case .failure(_):
                let error = NSError(domain: "", code: 400, userInfo: [ NSLocalizedDescriptionKey: "experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                completion(nil,error)
            }
        }
    }
    
    // VERISON 2
    
    func getToPlayList(
        _ completion : @escaping (_ responseModel: Result<GetToPlayListModel,AFError> )->()){
            AF.request(
                NEW_SEARCH_GET_TO_PLAYLIST,
                method: .get,
                parameters: nil,
                encoding: JSONEncoding.default,
                headers: API_HEADER
            ).responseDecodable(of: GetToPlayListModel.self) { response in
                completion(response.result)
            }
        }
    
    func getSearchResultV2(searchText: String, contentType: String,
                           _ completion : @escaping (_ responseModel: Result<SearchV2ContentResponseObj,AFError> )->()){
        AF.request(
            SEARCH_ALL_V2(searchText, contentType).safeUrl(),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: SearchV2ContentResponseObj.self) { response in
            
            completion(response.result)
        }
    }
    
    func getSpecificSearchResultV2(searchText: String, contentType: String,
                                   _ completion : @escaping (_ responseModel: Result<SearchV2ContentResponseObj,AFError> )->()){
        AF.request(
            SEARCH_SPECIFIC_CONTENT_V2(searchText, contentType).safeUrl(),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: SearchV2ContentResponseObj.self) { response in
            
            completion(response.result)
        }
    }
    
    func getSearchResultFromDatabaseV2(searchText: String,
                                       _ completion : @escaping (_ responseModel: Result<GetResultFromDatabaseObj,AFError> )->(),sendSearchTerm: @escaping(_ searchTerm: String)->()){
        AF.request(
            GET_RESULT_FROM_DATABASE(searchText).safeUrl(),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: GetResultFromDatabaseObj.self) { response in
            sendSearchTerm(searchText)
            completion(response.result)
        }
    }
    
    func getSearchResultFromHistory_V2(searchText: String, userCode: String,
                                       _ completion : @escaping (_ responseModel: Result<SearchFromHistoryObj,AFError> )->(), sendSearchTerm: @escaping(_ searchTerm: String)->()){
        AF.request(
            GET_RESULT_FROM_HISTORY(searchText, userCode).safeUrl(),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: SearchFromHistoryObj.self) { response in
            sendSearchTerm(searchText)
            completion(response.result)
        }
    }
    
    func getSearchHistories_V2(userCode: String,
                               _ completion : @escaping (_ responseModel: Result<RecentSearchHistoriesResponseObj,AFError> )->()){
        print(GET_SEARCH_HISTORIES_V2(userCode))
        AF.request(
            GET_SEARCH_HISTORIES_V2(userCode),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: RecentSearchHistoriesResponseObj.self) { response in
            completion(response.result)
        }
    }
    
    func postSearchHistories_V2(userName: String, searchText: String,
                                _ completion : @escaping (_ responseModel: Result<PostHistoryModel,AFError> )->()){
        let body = [
            "userName"   : userName,
            "searchText" : searchText
        ]
        AF.request(
            POST_SEARCH_HISTORIES_V2(),
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of:PostHistoryModel.self) { response in
            completion(response.result)
        }
    }
    
    func createSearchHistories_V2(userCode: String, contentId: String, contentType: String, trackType: String,
                                _ completion : @escaping (_ responseModel: Result<CreateSearchHistoryResponse,AFError> )->()){
        let body = [
            "userCode"   : userCode,
            "contentId" : contentId,
            "contentType" : contentType,
            "trackType" : trackType
        ]
        
        print(body)
        
        AF.request(
            CREATE_SEARCH_HISTORIES_V2(),
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of:CreateSearchHistoryResponse.self) { response in
            completion(response.result)
        }
    }
    
    func deleteSearchHistory_V2(id: String,
                                _ completion : @escaping (_ responseModel: Result<DeleteSearchHistoryResponse,AFError> )->()){
        
        AF.request(
            DELETE_SEARCH_HISTORY_V2(id, ShadhinCore.instance.defaults.userIdentity),
            method: .delete,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of:DeleteSearchHistoryResponse.self) { response in
            completion(response.result)
        }
    }
    
    func deleteAllSearchHistory_V2(
                                _ completion : @escaping (_ responseModel: Result<CreateSearchHistoryResponse,AFError> )->()){
        
        AF.request(
            DELETE_ALL_SEARCH_HISTORY_V2(ShadhinCore.instance.defaults.userIdentity),
            method: .delete,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of:CreateSearchHistoryResponse.self) { response in
            completion(response.result)
        }
    }
    
    func getUpdatedSearchResult_V2(searchText: String, limit: String = "40",
                                       _ completion : @escaping (_ responseModel: Result<UpdatedSearchResponseModel_V2,AFError> )->(), sendSearchTerm: @escaping(_ searchTerm: String)->()){
        AF.request(
            GET_UPDATED_SEARCH_RESULT_V2(searchText, limit).safeUrl(),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: UpdatedSearchResponseModel_V2.self) { response in
            sendSearchTerm(searchText)
            completion(response.result)
        }
    }
    
}
