//
//  ShadhinDefaults+ShuffleList.swift
//  Shadhin
//
//  Created by Maruf on 29/1/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinDefaults {
    
    static var shuffleItems: Set<String> = []
    func addShuffle(contentId: String, contentType: String) {
        let str = "\(contentId)+\(contentType.uppercased())"
        ShadhinDefaults.shuffleItems.insert(str)
        print(Array(ShadhinDefaults.shuffleItems))
        
        userDefault.set(Array(ShadhinDefaults.shuffleItems), forKey: "shuffleItems")
        print(userDefault.stringArray(forKey: "shuffleItems"))
    }
    
    func checkShuffle(contentId: String, contentType: String)-> Bool {
        let str = "\(contentId)+\(contentType.uppercased())"
        return ShadhinDefaults.shuffleItems.contains(str)
    }
     
    func removeShuffle(contentId:String, contentType: String) {
        let str = "\(contentId)+\(contentType.uppercased())"
         (ShadhinDefaults.shuffleItems.remove(str))
        userDefault.set(Array(ShadhinDefaults.shuffleItems),forKey: "shuffleItems")
    }
}
