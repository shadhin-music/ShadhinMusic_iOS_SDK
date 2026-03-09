//
//  CircularProgress.swift
//  Video Player Example
//
//  Created by Gakk Media Ltd on 7/29/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//


import UIKit

class SDDownloadObject: NSObject {

    var completionBlock: SDDownloadManager.DownloadCompletionBlock
    var progressBlock: SDDownloadManager.DownloadProgressBlock?
    let downloadTask: URLSessionDownloadTask
    let directoryName: String?
    let fileName:String?
    var isSingle : Bool?
    init(downloadTask: URLSessionDownloadTask,
         progressBlock: SDDownloadManager.DownloadProgressBlock?,
         completionBlock: @escaping SDDownloadManager.DownloadCompletionBlock,
         fileName: String?,
         directoryName: String?, isSingle : Bool?) {
        
        self.downloadTask = downloadTask
        self.completionBlock = completionBlock
        self.progressBlock = progressBlock
        self.fileName = fileName
        self.directoryName = directoryName
        self.isSingle = isSingle
    }
    
}
