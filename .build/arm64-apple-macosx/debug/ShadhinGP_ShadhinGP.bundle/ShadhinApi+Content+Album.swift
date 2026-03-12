//
//  ShadhinApi+Album.swift
//  Shadhin
//
//  Created by Admin on 13/7/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi{
    func getAlbumByContentID(
        contentId id : String,
        complete : @escaping (Result<AlbumResponseObj, Error>)-> Void){
        AF.request(
            GET_ALBUM_PLAYLIST(.album,id),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: AlbumResponseObj.self) { response in
            switch response.result{
            case let .success(data):
                complete(.success(data))
            case .failure(_):
                let error = NSError(domain: "", code: 400, userInfo: [ NSLocalizedDescriptionKey: "experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                complete(.failure(error))
            }
        }
    }
}
