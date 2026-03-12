//
//  SSLCancelResponse.swift
//  Shadhin_Gp_Examaple
//
//  Created by MD Murad Hossain  on 6/10/25.
//


import Foundation

struct SSLCancelResponse: Codable {
    let status: Bool
    let message: String?
    let data: String?
}
