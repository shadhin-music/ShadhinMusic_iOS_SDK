//
//  ShadhinApi+Artist.swift
//  Shadhin
//
//  Created by Gakk Alpha on 5/18/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi{
    
    func getTopArtistsBySkipping(
        artistId : String = "",
        completion : @escaping (ArtistsInPlaylistObj?)->Void)
    {
        AF.request(
            GET_TOP_ARTISTS(artistId),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: ArtistObj.self){ response in
            switch response.result{
            case let .success(data):
                completion(data.data?.artist)
            case let .failure(error):
                completion(nil)
                Log.error(error.localizedDescription)
            }
        }
    }
    
    func getSongsBy(
        artistId: String,
        completion: @escaping (_ data: ArtistTracks?,Error?)-> Void)
    {
        AF.request(
            GET_SONGS_OF_ARTIST(artistId),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: ArtistTracks.self){ response in
            switch response.result{
            case let .success(data):
                completion(data,nil)
            case .failure(_):
                let error = NSError(domain: "", code: 400, userInfo: [ NSLocalizedDescriptionKey: "experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                completion(nil,error)
            }
        }
    }
    
    func getSongsOrAblumsBy(
        artistId: String,
        type: SMContentType,
        completion: @escaping (_ data: ArtistTracks?,Error?)-> Void)
    {
        guard type == .album || type == .song else{ return Log.error("Wrong type called on api")}
        AF.request(
            GET_SONGS_OR_ALBUMS_OF_ARTIST(artistId, type.rawValue),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: ArtistTracks.self){ response in
            switch response.result{
            case let .success(data):
                completion(data,nil)
            case let .failure(error):
                completion(nil,error)
            }
        }
    }
    
    func getArtistBioFromLastFm(
        artistName: String,
        completion: @escaping (_ data: String?,Error?)-> Void) {
        let name = artistName.replacingOccurrences(of: " ", with: "%20")
        if let val = customArtistBio[name.lowercased()] {
            return completion(val,nil)
        }
        AF.request(
            GET_ARTIST_BIO(name),
            method: .get,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: ArtistBioObj.self){ response in
            switch response.result{
            case let .success(data):
                completion(data.artist.bio.summary,nil)
            case let .failure(error):
                completion(nil,error)
            }
        }
    }
    
    func getAllArtistPaged(
        _ pageNumber: Int ,
        _ token: String? = nil,
        _ completion: @escaping (_ data: Artists?)-> Void)
    {

        var header = API_HEADER
        if let token = token{
            header["Token"] = token
            header["Authorization"] = "Bearer \(token)"
        }
        
        AF.request(
            GET_ALL_ARTIST_PAGED(pageNumber),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: header
        ).responseDecodable(of: Artists.self){ response in
            switch response.result{
            case let .success(data):
                if data.data.count > 0{
                    completion(data)
                }else{
                    completion(nil)
                }
            case let .failure(error):
                completion(nil)
                Log.error(error.localizedDescription)
            }
        }
    }
    
    func searchArtist(_ searchText: String,
                      _ completion: @escaping (_ data: Artists?)-> Void){
        AF.request(
            ARTIST_SEARCH(searchText),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: Artists.self){ response in
            switch response.result{
            case let .success(data):
                if data.data.count > 0{
                    completion(data)
                }else{
                    completion(nil)
                }
            case let .failure(error):
                completion(nil)
                Log.error(error.localizedDescription)
            }
        }
    }
    
    func getArtistFeaturedPlaylist(
        _ artistId: String,
        completion: @escaping (_ data: FeaturedPlaylistOfArtistObj?)-> Void)
    {
        AF.request(
            GET_ARTIST_FEATURED_PLAYLIST(artistId),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: FeaturedPlaylistOfArtistObj.self){ response in
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
