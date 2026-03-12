//
//  LocationDTO.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/7/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation


struct LocationObj: Codable {
    let query,
        status,
        country,
        countryCode: String?
    let region,
        regionName,
        city, zip: String?
    let lat, lon: Double?
    let timezone,
        isp,
        org,
        locationDTOAs: String?

    enum CodingKeys: String, CodingKey {
        case query, status, country, countryCode, region, regionName, city, zip, lat, lon, timezone, isp, org
        case locationDTOAs = "as"
    }
}
