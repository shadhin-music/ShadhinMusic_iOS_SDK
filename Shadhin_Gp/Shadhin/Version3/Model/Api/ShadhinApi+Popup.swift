//
//  ShadhinApi+Popup.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/14/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi{
    func getPopUpData(
        completion  : @escaping (_ data: PopUpObj?,Error?)-> Void) {
        AF.request(
            GET_POP_UP_DATA,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: CONTENT_HEADER
        ).responseDecodable(of: PopUpObj.self) { response in
            switch response.result{
            case let .success(data):
                completion(data,nil)
            case .failure(_):
                let error = NSError(domain: "", code: 400, userInfo: [ NSLocalizedDescriptionKey: "experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                completion(nil,error)
            }
        }
            
    }
}
