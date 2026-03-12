//
//  VGPlayerCacheMedia.swift
//  Pods
//
//  Created by Vein on 2017/6/23.
//
//

import Foundation

 class VGPlayerCacheMedia: NSObject, NSCoding {
     var contentType: String?
     var isByteRangeAccessSupported: Bool = false
     var contentLength: Int64 = 0
     var downloadedLength: UInt64 = 0
    
     override init() {
        
    }
    
     override var description: String {
        return "contentType: \(String(describing: contentType))\n isByteRangeAccessSupported: \(isByteRangeAccessSupported)\n contentLength: \(contentLength)\n downloadedLength: \(downloadedLength)\n"
    }
    
     func encode(with aCoder: NSCoder) {
        aCoder.encode(contentType, forKey: "contentType")
        aCoder.encode(isByteRangeAccessSupported, forKey: "isByteRangeAccessSupported")
        aCoder.encode(contentLength, forKey: "contentLength")
        aCoder.encode(downloadedLength, forKey: "downloadedLength")
    }
    
     required init(coder aDecoder: NSCoder) {
        super.init()
        contentType = aDecoder.decodeObject(forKey: "contentType") as? String
        isByteRangeAccessSupported = aDecoder.decodeBool(forKey: "isByteRangeAccessSupported")
        contentLength = aDecoder.decodeInt64(forKey: "contentLength")
        if let downloadedLength = aDecoder.decodeObject(forKey: "downloadedLength") as? UInt64 {
            self.downloadedLength = downloadedLength
        } else {
            downloadedLength = 0
        }
        
    }
}
