//
//  VGPlayerCacheAction.swift
//  Pods
//
//  Created by Vein on 2017/6/27.
//
//

import Foundation

 enum VGPlayerCacheActionType: Int {
    case local
    case remote
}

 struct VGPlayerCacheAction: Hashable, CustomStringConvertible {
     var type: VGPlayerCacheActionType
     var range: NSRange
    
     var description: String {
        return "type: \(type)  range:\(range)"
    }
    
     var hashValue: Int {
        return String(format: "%@%@", NSStringFromRange(range), String(describing: type)).hashValue
    }
    
     static func ==(lhs: VGPlayerCacheAction, rhs: VGPlayerCacheAction) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    init(type: VGPlayerCacheActionType, range: NSRange) {
        self.type = type
        self.range = range
    }
    
}
