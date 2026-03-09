//
//  PodcastNewModel.swift
//  Shadhin
//
//  Created by Rezwan on 8/6/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import Foundation

class PodcastAPI{
    
    static func getImgSize(_ patchType :String) -> String{
        switch patchType.lowercased() {
        case "le":
            return "300"
        case "pp":
            return "320"
        case "ps":
            return "225"
        case "ss","tpc":
            return "450"
        case "tn", "vp":
            return "300"
        case "vl":
            return "1280"
        default:
            return "300"
        }
    }
    
    static func size(_ cellType: PodcastCollectionCell.CellType)-> CGSize {
        switch cellType {
        case .SquareBig:
            return CGSize(width: 136, height: 136)
        case .SquareSmall:
            return CGSize(width: 96, height: 96)
        case .Portrait:
            return CGSize(width: 144, height: 204 + 48)
        case .LandscapeWithLabel:
            return CGSize(width: 280, height: 158)
        case .SquareSmallWithLabel:
            return CGSize(width: 136, height: 136 + 48)
        case .VideoPortrait:
            return VideoPortraitCell.size
        case .VideoLandscape:
            return VideoLandscapeCell.size
        case .VideoLandscapeV2:
            return VideoLandscapeV2Cell.size
        }
    }
    
    static func size(_ patchType: String)-> CGSize {
        switch patchType.lowercased() {
        case "le":
            return CGSize(width: 136, height: 136 + 48)
        case "vl":
            return VideoLandscapeCell.size
        case "pp", "news":
            return CGSize(width: 136, height: 136)
        case "ps":
            return CGSize(width: 280, height: 158)
        case "ss", "tpc":
            return CGSize(width: 144, height: 204 + 48)
//        case "vp":
//            return VideoPortraitCell.size
        case "vp":
            return VideoLandscapeV2Cell.size
        case "tn":
            return CGSize.zero
        default:
            return CGSize.zero
        }
    }
    
    
    struct PodcastLike: Codable {
        let status, message: String
        let data: Bool
        let total: Int
    }

    
   


//    enum PatchType: String, Codable {
//        case le = "LE"
//        case pp = "PP"
//        case ps = "PS"
//        case ss = "SS"
//        case tn = "TN"
//    }
//
    
    // MARK: - PodcastShowModel
   

    
}



