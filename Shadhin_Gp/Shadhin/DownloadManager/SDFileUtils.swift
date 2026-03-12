//
//  CircularProgress.swift
//  Video Player Example
//
//  Created by Gakk Media Ltd on 7/29/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class SDFileUtils: NSObject {
    
    // MARK:- Helpers
    
    static func moveFile(fromUrl url:URL,
                         toDirectory directory:String? ,
                         withName name:String) -> (Bool, Error?, URL?) {
        var newUrl:URL
        if let directory = directory {
            let directoryCreationResult = self.createDirectoryIfNotExists(withName: directory)
            guard directoryCreationResult.0 else {
                return (false, directoryCreationResult.1, nil)
            }
            newUrl = self.cacheDirectoryPath().appendingPathComponent(directory).appendingPathComponent(name)
        } else {
            newUrl = self.cacheDirectoryPath().appendingPathComponent(name)
        }
        
        
        if FileManager.default.fileExists(atPath: newUrl.path) {
            return (true, nil, newUrl)
        }
        do {
            try FileManager.default.moveItem(at: url, to: newUrl)
            return (true, nil, newUrl)
        } catch {
            return (false, error, nil)
        }
    }
    
    static func cacheDirectoryPath() -> URL {
        let cachePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return URL(fileURLWithPath: cachePath)
    }
    
    static func createDirectoryIfNotExists(withName name:String) -> (Bool, Error?)  {
        let directoryUrl = self.cacheDirectoryPath().appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: directoryUrl.path) {
            return (true, nil)
        }
        do {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
            return (true, nil)
        } catch  {
            return (false, error)
        }
    }
    
    static func checkFileExists(urlName: String)->(isExists: Bool,fileString: String) {
        guard let decodedUrlName = urlName.decryptUrl(),
              let url = URL(string: decodedUrlName) else {return (false,"")}
        let directoryUrl = self.cacheDirectoryPath().appendingPathComponent(url.lastPathComponent)
        Log.info("SHADHIN LOG checking file exist for ->\(directoryUrl)")
        if FileManager.default.fileExists(atPath: directoryUrl.path) {
            return (true,directoryUrl.absoluteString)
        }else {
            return (false,"empty")
        }
    }
    
    static func removeItemFromDirectory(urlName: String) {
        guard let url = URL(string: urlName) else {return}
        let directoryUrl = self.cacheDirectoryPath().appendingPathComponent(url.lastPathComponent)
        do {
            try FileManager.default.removeItem(atPath: directoryUrl.path)
        }catch {
            Log.error(error.localizedDescription)
        }
    }
    
    
}
