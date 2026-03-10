//
//  RegistrationDTO.swift
//  Shadhin
//
//  Created by Gakk Alpha on 2/16/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let registrationDTO = try? newJSONDecoder().decode(RegistrationDTO.self, from: jsonData)

// MARK: - RegistrationDTO

public class TokenObj: NSObject, Codable {
    let status, message: String
    let data: DataClass?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case data = "Data"
    }

    init(status: String, message: String, data: DataClass) {
        self.status = status
        self.message = message
        self.data = data
    }
    
    // MARK: - DataClass
    class DataClass: Codable {
        let token, phoneNumber, userFullName, gender: String
        let userPic: String

        enum CodingKeys: String, CodingKey {
            case token = "Token"
            case phoneNumber = "PhoneNumber"
            case userFullName = "UserFullName"
            case gender = "Gender"
            case userPic = "UserPic"
        }

        init(token: String, phoneNumber: String, userFullName: String, gender: String, userPic: String) {
            self.token = token
            self.phoneNumber = phoneNumber
            self.userFullName = userFullName
            self.gender = gender
            self.userPic = userPic
        }
    }
}




