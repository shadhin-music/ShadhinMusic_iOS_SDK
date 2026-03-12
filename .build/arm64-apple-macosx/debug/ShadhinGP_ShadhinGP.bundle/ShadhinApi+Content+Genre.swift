//
//  ShadhinApi+Content+Genre.swift
//  Shadhin
//
//  Created by Maruf on 5/11/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi {
    
    func getGenreList(
        _ token: String? = nil,
        completion: @escaping ([GetGenreListobj.GenreData])-> Void)
    {
        var header = API_HEADER
        if let token = token{
            header["Token"] = token
            header["Authorization"] = "Bearer \(token)"
        }
        AF.request(
            GET_GENRE,
            method: .get,
            encoding: JSONEncoding.default,
            headers: header
        ).responseDecodable(of:GetGenreListobj.self)
        { response in
            switch response.result{
            case let .success(data):
                completion(data.data)
            case let .failure(error):
                Log.error(error.localizedDescription)
                completion([])
            }
        }
    }
    
    func submitSelectedGenre(
        _ token: String? = nil,
        selectedGenre: [GetGenreListobj.GenreData],
        completion: @escaping (Bool, String) -> Void){
            guard let url = URL(string: SET_GENRE) else {return}
            var body: [Any] = []
            selectedGenre.forEach { obj in
                body.append(obj.getData())
            }
            var header = API_HEADER
            if let token = token{
                header["Token"] = token
                header["Authorization"] = "Bearer \(token)"
            }
            let json = try? JSONSerialization.data(withJSONObject: body)
            var urlRequest = URLRequest(url: url)
            urlRequest.method = .post
            urlRequest.httpBody = json
            urlRequest.headers = header
            Log.info(String(data: json!, encoding: String.Encoding.utf8)!)
            
            AF.request(urlRequest)
              .responseData { response in
                    switch response.result{
                    case .success(_):
                        completion(true, "success")
                    case .failure(_):
                        completion(false,"experiencing technical problems now which will be fixed soon. Thanks for your patience.")
                    }
                }
        }
    
    // incomplete
    func addFavoriteArtist(
        token : String?,
        contents: [Artists.Artist],
        _ completion : @escaping (Bool,String)->Void) {
            var items : [[String:String]] = []
            for content in contents{
                let item = [
                    "ContentId": content.id,
                    "ContentType": "A"
                ]
                items.append(item)
            }
            var header = API_HEADER
            if let token = token {
                header["Token"] = token
                header["Authorization"] = "Bearer \(token)"
            }
            var request = URLRequest(url: URL(string: ADD_FAVORITES_ARTIST)!)
            request.httpMethod = "POST"
            request.httpBody = try! JSONSerialization.data(withJSONObject: items)
            request.headers = header
            AF.request(request)
                .responseData{ response in
                    switch response.result{
                    case let .success(data):
                        completion(true,"Successfully Added")
                    case .failure(_):
                        completion(false,"experiencing technical problems now which will be fixed soon. Thanks for your patience.")
                }
            }
        }
    
    func addOrRemoveFromFavorite(
        content: CommonContentProtocol,
        action: UserActionType,
        token: String? = nil,
        addToCache: Bool = true,
        completion: @escaping (Error?)-> Void)
    {
        guard ShadhinCore.instance.isUserLoggedIn || token != nil else {
            let error = NSError(domain:"", code:500, userInfo:[ NSLocalizedDescriptionKey: "User not logged in"]) as Error
            completion(error)
            return
        }
        
        var header = API_HEADER
        if let token = token{
            header["Token"] = token
            header["Authorization"] = "Bearer \(token)"
        }
        
        let method: HTTPMethod
        switch action{
        case .add:
            method = .post
        case .remove:
            method = .delete
        }
        
        guard let contentID: String = content.contentID,
              let contentType: String = content.contentType else {return}
        
        let body = [
            "ContentId": contentID,
            "ContentType":  contentType
        ]
        
        AF.request(
            ADD_AND_DELETE_FAVORITES,
            method: method,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: header
        ).responseData { response in
            switch response.result{
            case let .success(data):
                if let value = try? JSONSerialization.jsonObject(with: data) as? [String : String],
                   let status = value["Status"]{
                    if status.lowercased().contains("successfully"){
                        if addToCache{
                            if action == .add{
                                FavoriteCacheDatabase.intance.addContent(content: content)
                            }else{
                                FavoriteCacheDatabase.intance.deleteContent(content: content)
                            }
                        }
                        completion(nil)
                    }else{
                     //   let error = NSError(domain:"", code:500, userInfo:[ NSLocalizedDescriptionKey: status]) as Error
                        let error = NSError(domain: "", code: 400, userInfo: [ NSLocalizedDescriptionKey: "experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                        completion(error)
                    }
                }
            case let .failure(error):
                completion(error)
            }
        }
    }
}
