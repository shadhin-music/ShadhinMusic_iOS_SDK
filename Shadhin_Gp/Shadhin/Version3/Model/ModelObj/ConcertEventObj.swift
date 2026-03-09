//
//  ConcertEventObj.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/25/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//
import Foundation

struct ConcertEventObj: Codable {
    let status, message: String
    let data: DataClass
    
    struct DataClass: Codable {
        let id: String
        let banner: String
        let name, campaignDate, campaignTime, dataDescription: String
        let address, addressDetails, faq, terms: String
        let artist: [Artist]
        
        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case banner = "Banner"
            case name = "Name"
            case campaignDate = "CampaignDate"
            case campaignTime = "CampaignTime"
            case dataDescription = "Description"
            case address = "Address"
            case addressDetails = "AddressDetails"
            case faq = "Faq"
            case terms = "Terms"
            case artist
        }
        
        struct Artist: Codable {
            let id, artistName: String
            let image: String
            let follower: String?
            
            enum CodingKeys: String, CodingKey {
                case id = "Id"
                case artistName = "ArtistName"
                case image = "Image"
                case follower = "Follower"
            }
        }
    }
}
