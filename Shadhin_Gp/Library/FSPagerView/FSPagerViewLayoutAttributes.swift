//
//  FSPagerViewLayoutAttributes.swift
//  FSPagerViewExample
//
//  Created by Wenchao Ding on 26/02/2017.
//  Copyright © 2017 Wenchao Ding. All rights reserved.
//

import UIKit

 class FSPagerViewLayoutAttributes: UICollectionViewLayoutAttributes {

     var position: CGFloat = 0
    
     override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? FSPagerViewLayoutAttributes else {
            return false
        }
        var isEqual = super.isEqual(object)
        isEqual = isEqual && (self.position == object.position)
        return isEqual
    }
    
     override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! FSPagerViewLayoutAttributes
        copy.position = self.position
        return copy
    }
    
}
