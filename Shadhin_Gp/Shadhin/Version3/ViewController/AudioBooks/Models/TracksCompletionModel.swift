//
//  TracksCompletionModel.swift
//  Shadhin
//
//  Created by Maruf on 31/10/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import Foundation

struct AudioBookProgressResponse: Codable {
    let success: Bool
    let responseCode: Int
    let title: String
    let data: [AudioBookProgress]?
    let error: String?
}

struct AudioBookProgress: Codable {
    let id: Int
    let completionPercentage: Int?
    let currentDurationCursor: Int?
}
