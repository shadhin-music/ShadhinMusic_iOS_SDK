//
//  ShadhinApi+Favorite.swift
//  Shadhin
//
//  Created by Gakk Alpha on 6/15/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi{
    
    func getAllFavoriteByType(
        type: SMContentType,
        completion: @escaping (_ data: [CommonContentProtocol]?,Error?)-> Void)
    {
        guard ShadhinCore.instance.isUserLoggedIn,
              type != .unknown else {
            return completion([],nil)
        }
        let items = FavoriteCacheDatabase.intance.getAllContentBy(type: type)
        completion(items.reversed(), nil)
    }
    
    func addOrRemoveFromFavorite(
        content: CommonContentProtocol,
        action: UserActionType,
        completion: @escaping (Error?)-> Void)
    {
        guard ShadhinCore.instance.isUserLoggedIn else {
            let error = NSError(domain:"", code:500, userInfo:[ NSLocalizedDescriptionKey: "User not logged in"]) as Error
            completion(error)
            return
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
            headers: API_HEADER
        ).responseData { response in
            switch response.result{
            case let .success(data):
                if let value = try? JSONSerialization.jsonObject(with: data) as? [String : String],
                   let status = value["Status"]{
                    if status.lowercased().contains("successfully"){
                        if action == .add{
                            FavoriteCacheDatabase.intance.addContent(content: content)
                        }else{
                            FavoriteCacheDatabase.intance.deleteContent(content: content)
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
    
    func fetchAllFavoriteByType(
        type: SMContentType,
        completion: @escaping (_ data: [CommonContent_V3]?,Error?)-> Void)
    {
        
        AF.request(
            GET_FAVORITES_BY_TYPE(type.rawValue),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: FavoritesObj.self) { response in
            switch response.result{
            case let .success(data):
                completion(data.data,nil)
            case let .failure(error):
                Log.error(error.localizedDescription)
                completion(nil,error)
            }
        }
    }
    
    
    func fetchAndCacheAllFav(){
        
        DispatchQueue.global().async {
            let dispatchGroup = DispatchGroup()

            if !ShadhinCore.instance.defaults.isFavCached(type: .artist){
                dispatchGroup.enter()
                self.fetchAllFavoriteByType(
                    type: .artist) { data, err in
                        if let favArtists = data{
                            for artist in favArtists{
                                FavoriteCacheDatabase.intance.addContent(content: artist)
                            }
                        }
                        ShadhinCore.instance.defaults.setFavCached(type: .artist, value: true)
                        dispatchGroup.leave()
                    }
                dispatchGroup.wait()
            }
            
            if !ShadhinCore.instance.defaults.isFavCached(type: .album){
                dispatchGroup.enter()
                self.fetchAllFavoriteByType(
                    type: .album) { data, err in
                        if let favAlbums = data{
                            for album in favAlbums{
                                FavoriteCacheDatabase.intance.addContent(content: album)
                            }
                        }
                        ShadhinCore.instance.defaults.setFavCached(type: .album, value: true)
                        dispatchGroup.leave()
                    }
                dispatchGroup.wait()
            }
            
            if !ShadhinCore.instance.defaults.isFavCached(type: .playlist){
                dispatchGroup.enter()
                self.fetchAllFavoriteByType(
                    type: .playlist) { data, err in
                        if let favPlaylists = data{
                            for playlist in favPlaylists{
                                FavoriteCacheDatabase.intance.addContent(content: playlist)
                            }
                        }
                        ShadhinCore.instance.defaults.setFavCached(type: .playlist, value: true)
                        dispatchGroup.leave()
                    }
                dispatchGroup.wait()
            }
            
            if !ShadhinCore.instance.defaults.isFavCached(type: .podcast){
                dispatchGroup.enter()
                self.fetchAllFavoriteByType(
                    type: .podcast) { data, err in
                        if let favPodcasts = data{
                            for podcast in favPodcasts{
                                FavoriteCacheDatabase.intance.addContent(content: podcast)
                            }
                        }
                        ShadhinCore.instance.defaults.setFavCached(type: .podcast, value: true)
                        dispatchGroup.leave()
                    }
                dispatchGroup.wait()
            }
            
            if !ShadhinCore.instance.defaults.isFavCached(type: .podcastVideo){
                dispatchGroup.enter()
                self.fetchAllFavoriteByType(
                    type: .podcastVideo) { data, err in
                        if let favPodcastVideos = data{
                            for podcastVideo in favPodcastVideos{
                                FavoriteCacheDatabase.intance.addContent(content: podcastVideo)
                            }
                        }
                        ShadhinCore.instance.defaults.setFavCached(type: .podcastVideo, value: true)
                        dispatchGroup.leave()
                    }
                dispatchGroup.wait()
            }
            
            if !ShadhinCore.instance.defaults.isFavCached(type: .song){
                dispatchGroup.enter()
                self.fetchAllFavoriteByType(
                    type: .song) { data, err in
                        if let favSongs = data{
                            for song in favSongs{
                                FavoriteCacheDatabase.intance.addContent(content: song)
                            }
                        }
                        ShadhinCore.instance.defaults.setFavCached(type: .song, value: true)
                        dispatchGroup.leave()
                    }
                dispatchGroup.wait()
            }
            
            if !ShadhinCore.instance.defaults.isFavCached(type: .video){
                dispatchGroup.enter()
                self.fetchAllFavoriteByType(
                    type: .video) { data, err in
                        if let favVideos = data{
                            for video in favVideos{
                                FavoriteCacheDatabase.intance.addContent(content: video)
                            }
                        }
                        ShadhinCore.instance.defaults.setFavCached(type: .video, value: true)
                        dispatchGroup.leave()
                    }
                dispatchGroup.wait()
            }
            
            if !ShadhinCore.instance.defaults.isFavCached(type: .audioBook){
                dispatchGroup.enter()
                self.fetchAllFavoriteByType(
                    type: .audioBook) { data, err in
                        if let favAudio = data{
                            for audio in favAudio {
                                FavoriteCacheDatabase.intance.addContent(content: audio)
                            }
                        }
                        ShadhinCore.instance.defaults.setFavCached(type: .video, value: true)
                        dispatchGroup.leave()
                    }
                dispatchGroup.wait()
            }
        }
        
    }
}
