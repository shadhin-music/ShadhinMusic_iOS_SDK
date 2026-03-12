//
//  SongsDownloadManager.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/29/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit
import Foundation




protocol DownloadManagerDelegate: AnyObject {
    func didFinishDownload()
    func didUpdateDownloadProgress(_ progress: CGFloat)
}

class SongsDownloadManager: NSObject {

    static var instance = SongsDownloadManager()

    weak var delegate: DownloadManagerDelegate?
    
    private var audioURLString: String?
    
    func startDownloadSongWithURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {return}
        self.audioURLString = urlString
        
        let config = URLSessionConfiguration.background(withIdentifier: "com.example.DownloadTaskExample.background")
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: url)
        task.resume()
    }
    
    static func returnDocumentoryURL(urlString: String) -> URL {
        let audioUrl = URL(string: urlString)
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl!.lastPathComponent)
        return destinationUrl
    }
}

extension SongsDownloadManager: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        self.delegate?.didUpdateDownloadProgress(CGFloat(progress))
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
            let destinationUrl = SongsDownloadManager.returnDocumentoryURL(urlString: audioURLString!)
        do {
            try FileManager.default.moveItem(at: location, to: destinationUrl)
                delegate?.didFinishDownload()
        } catch let error as NSError {
            Log.error(error.localizedDescription)
        }
       
    }
}
