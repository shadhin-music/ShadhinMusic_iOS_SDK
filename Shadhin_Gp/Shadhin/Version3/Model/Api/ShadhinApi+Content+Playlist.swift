//
//  ShadhinApi+Playlist.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/14/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi{
    
    func getArtistsInPlaylistBy(
        playListID : String,
        completion : @escaping (ArtistsInPlaylistObj?)->Void)
    {
        AF.request(
            GET_ARTISTS_IN_PLAYLIST(playListID),
            method: .get,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: ArtistsInPlaylistObj.self){ response in
            switch response.result{
            case let .success(data):
                completion(data)
            case let .failure(error):
                Log.error(error.localizedDescription)
                completion(nil)
            }
        }
    }
}
