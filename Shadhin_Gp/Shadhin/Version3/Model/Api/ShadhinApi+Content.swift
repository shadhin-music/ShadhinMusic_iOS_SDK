//
//  ShadhinApi+ContentCommon.swift
//  Shadhin
//
//  Created by Gakk Alpha on 7/27/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi{
    
    func getAlbumOrPlaylistOrSingleDataById(
        ContentID: String,
        contentType: String = "S",
        mediaType: SMContentType,
        completion: @escaping (_ data: [CommonContentProtocol]?, Error? ,_ image : String? )-> Void,
        imageCompletion: ((String?)->Void)? = nil,
        parentContentCompletion: ((ReleaseContent?)->Void)? = nil,
        isPaidComletion: ((Bool?)->Void)? = nil )
    {
        
        var api = GET_ALBUM_PLAYLIST(mediaType,ContentID)
        if mediaType == .album || mediaType == .song {
            api = "https://connect.shadhinmusic.com/api/v1/contents/releases?Id=\(ContentID)"
        } else if mediaType == .playlist {
            api = "https://connect.shadhinmusic.com/api/v1/contents/playlist?Id=\(ContentID)"
            
        } else if mediaType == .artist {
            api = "https://connect.shadhinmusic.com/api/v1/contents/artists?Id=\(ContentID)&ContentType=\(contentType)"
        }
        
        AF.request(
            api,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseData{ response in
            switch response.result{
            case let .success(data):
                    
                if mediaType == .album || mediaType == .playlist || mediaType == .artist ||  mediaType == .song,
                          let response = try? JSONDecoder().decode(ReleaseResponse.self, from: data),
                          var releaseData = response.data {
                    
                    releaseData.contents = releaseData.contents.map { item in
                        var updated = item
                        if updated.artist == nil {
                            updated.artist = updated.artists?.first?.name
                        }

                        if updated.artistId == nil {
                            updated.artistId = "\(updated.artists?.first?.id ?? 0)"
                        }
                        return updated
                    }

                    var items: [CommonContentProtocol] = []
                    items.append(contentsOf: releaseData.contents)
                    
                    completion(items, nil, releaseData.parentContents.first?.image)
                    parentContentCompletion?(releaseData.parentContents.first)

                } else if let contentData = try? JSONDecoder().decode(AlbumOrPlaylistObj.self, from: data) {
                    imageCompletion?(contentData.image)
                    isPaidComletion?(contentData.isPaid)
                    completion(contentData.data,nil, contentData.image)
                } else {
                    let error = NSError(domain: "shadhin.com", code: 0, userInfo: [NSLocalizedDescriptionKey: "experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                    completion(nil, error, nil)
                }
            case .failure(_):
                let error = NSError(domain: "", code: 400, userInfo: [ NSLocalizedDescriptionKey: "experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                completion(nil,error,"experiencing technical problems now which will be fixed soon.Thanks for your patience.")
            }
        }
    }
    
    func getContentLikeCount(
        contentID: String,
        contentType: String, //for PD needs full string
        completion: @escaping (Int, String, String)->Void)
    {
        AF.request(
            GET_FAV_COUNT(contentID,contentType),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseData{ response in
            switch response.result{
            case let .success(data):
                if let data = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                   let data0 = data["data"] as? [String : Any],
                   let count = data0["TotalFav"] as? Int{
                    completion(count, contentID, contentType)
                }else{
                    completion(0, contentID, contentType)
                }
            case let .failure(error):
                completion(0, contentID, contentType)
                Log.error(error.localizedDescription)
            }
        }
    }
    
    @available(*, deprecated, message: "data in get songs by artist id")
    func getMonthlyListenerCount(
        contentID: String,
        type: SMContentType = .artist,
        completion: @escaping (Int)->Void){
            guard type == .artist || type == .album || type == .playlist else { return Log.error("Wrong type called on api")}
            AF.request(
                GET_MONTHLY_LISTENER_COUNT(contentID,type.rawValue),
                method: .get,
                parameters: nil,
                encoding: JSONEncoding.default,
                headers: API_HEADER
            ).responseData { response in
                switch response.result{
                case let .success(data):
                    if let data = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
                       let data0 = data["data"] as? [String : Any],
                       let count = data0["TotalPlayCount"] as? Int{
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
    
}
