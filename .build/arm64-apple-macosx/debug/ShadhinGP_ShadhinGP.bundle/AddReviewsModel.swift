//
//  AddReviewsModel.swift
//  Shadhin
//
//  Created by Maruf on 4/11/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import Foundation

struct AudioBookReviewResponse: Codable {
    let data: Int
    let error: ErrorResponse?
    let responseCode: Int
    let success: Bool
    let title: String
}

struct ErrorResponse: Codable {
    let source: String?
    let message: String?
    let details: String?
    let errorCode: String?
}

struct AudioBookReviews: Codable {
    let bookEpisodeId: Int
    let description: String
    let fullName: String
    let imageUrl: String
    let rating: Float
    let usercode: String
    
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return dictionary
    }
}



