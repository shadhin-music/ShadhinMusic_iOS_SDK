//
//  ShadhinAPI+GeoLocation.swift
//  Shadhin
//
//  Created by Joy on 27/3/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi{
    
    class GeoLocation{
        private static let IP_URL = "http://ip-api.com/json"
        
        static func getCountryCode(complete :@escaping (_ code : String?,_ error : String?)->Void){
            guard let url = URL(string: IP_URL) else {
                return
            }
            let urlRequest = URLRequest(url: url)
            
            AF.request(urlRequest)
                .responseDecodable(of: IPLocationResponse.self) { response in
                    switch response.result{
                    case .success(let success):
                        let code = success.countryCode
                        complete(code,nil)
                    case .failure(let error):
                        complete(nil,error.localizedDescription)
                    }
                }
        }
    }
    
}
struct IPLocationResponse: Codable {
    let status, country, countryCode, region: String
    let regionName, city, zip: String
    let lat, lon: Double
    let timezone, isp, org, ipLocationResponseAs: String
    let query: String

    enum CodingKeys: String, CodingKey {
        case status, country, countryCode, region, regionName, city, zip, lat, lon, timezone, isp, org
        case ipLocationResponseAs = "as"
        case query
    }
}
