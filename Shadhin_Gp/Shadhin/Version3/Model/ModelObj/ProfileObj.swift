//
//  ProfileDTO.swift
//  Shadhin
//
//  Created by Gakk Alpha on 7/14/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

struct ProfileObj: Codable {
    let message: String?
    let success: Bool?
    let data: UserProfileData?
    let title: String?
    let responseCode: Int?
    let error: String?
}

struct UserProfileData: Codable {
    
    let userCode: String?
    let userFullName: String?
    let phoneNumber: String?
    let birthDate: String?
    let gender: String?
    let country: String?
    let countryCode: String?
    let city: String?
    let userPic: String?
    
    let registerWith: [String]?
    let hasFavoriteArtist: Bool?
    let hasFavoriteGenre: Bool?
    
    let appleId: String?
    let facebookId: String?
    let googleId: String?
    let linkedinId: String?
    let twitterId: String?
    let emailId: String?
    
    enum CodingKeys: String, CodingKey {
        case userCode
        case userFullName
        case phoneNumber
        case birthDate
        case gender
        case country
        case countryCode
        case city
        case userPic
        case registerWith
        case hasFavoriteArtist
        case hasFavoriteGenre
        case appleId
        case facebookId
        case googleId
        case linkedinId
        case twitterId
        case emailId
    }
}
