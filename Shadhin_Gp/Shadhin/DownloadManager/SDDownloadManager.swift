//
//  CircularProgress.swift
//  Video Player Example
//
//  Created by Gakk Media Ltd on 7/29/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

final public class SDDownloadManager: NSObject {
    
    public typealias DownloadCompletionBlock = (_ error : Error?, _ fileUrl:URL?) -> Void
    public typealias DownloadProgressBlock = (_ progress : CGFloat) -> Void
    public typealias BackgroundDownloadCompletionHandler = () -> Void
    
    // MARK :- Properties
    
    private var session: URLSession!
    private var ongoingDownloads: [String : SDDownloadObject] = [:]
    private var backgroundSession: URLSession!
    
    public var backgroundCompletionHandler: BackgroundDownloadCompletionHandler?
    public var showLocalNotificationOnBackgroundDownloadDone = true
    public var localNotificationText: String?

    public static let shared: SDDownloadManager = { return SDDownloadManager() }()

    //MARK:- Public methods
    
    public func downloadFile(withRequest request: URLRequest,
                            inDirectory directory: String? = nil,
                            withName fileName: String? = nil,
                             isSingle : Bool? = true,
                            shouldDownloadInBackground: Bool = true,
                            onProgress progressBlock:DownloadProgressBlock? = nil,
                            onCompletion completionBlock:@escaping DownloadCompletionBlock) -> String? {
        
//        let path = URL(string: url)!.lastPathComponent
//        let path2 = URL(string: dataValue.playUrl!)?.lastPathComponent
//        print("Check this -> \(path) path for non url -> \(path2)")
        
        guard let key = request.url?.lastPathComponent else {return nil}
        Log.info(request.url!.lastPathComponent)
        if let _ = self.ongoingDownloads[key] {
            return nil
        }
        var downloadTask: URLSessionDownloadTask
        if shouldDownloadInBackground {
            downloadTask = self.backgroundSession.downloadTask(with: request)
        } else{
            downloadTask = self.session.downloadTask(with: request)
        }
        
        let download = SDDownloadObject(downloadTask: downloadTask,
                                        progressBlock: progressBlock,
                                        completionBlock: completionBlock,
                                        fileName: fileName,
                                        directoryName: directory, isSingle: isSingle)
        
        
        self.ongoingDownloads[key] = download
        downloadTask.resume()
        return key;
    }
     func downloadObjectFile(withRequest request: URLRequest,
                            inDirectory directory: String? = nil,
                            withName fileName: String? = nil,
                             isSingle : Bool? = true,
                            shouldDownloadInBackground: Bool = true,
                            onProgress progressBlock:DownloadProgressBlock? = nil,
                            onCompletion completionBlock:@escaping DownloadCompletionBlock) -> SDDownloadObject? {
        
//        let path = URL(string: url)!.lastPathComponent
//        let path2 = URL(string: dataValue.playUrl!)?.lastPathComponent
//        print("Check this -> \(path) path for non url -> \(path2)")
        
        guard let key = request.url?.lastPathComponent else {return nil}
        Log.info(request.url!.lastPathComponent)
        if let _ = self.ongoingDownloads[key] {
            return nil
        }
        var downloadTask: URLSessionDownloadTask
        if shouldDownloadInBackground {
            downloadTask = self.backgroundSession.downloadTask(with: request)
        } else{
            downloadTask = self.session.downloadTask(with: request)
        }
        
        let download = SDDownloadObject(downloadTask: downloadTask,
                                        progressBlock: progressBlock,
                                        completionBlock: completionBlock,
                                        fileName: fileName,
                                        directoryName: directory, isSingle: isSingle)
        
        
        self.ongoingDownloads[key] = download
        downloadTask.resume()
        return download
    }
    
    public func currentDownloads() -> [String] {
        return Array(self.ongoingDownloads.keys)
    }
    
    public func cancelAllDownloads() {
        for (_, download) in self.ongoingDownloads {
            let downloadTask = download.downloadTask
            downloadTask.cancel()
        }
        self.ongoingDownloads.removeAll()
    }
    
    public func cancelDownload(forUniqueKey key:String?) {
        let downloadStatus = self.isDownloadInProgress(forUniqueKey: key)
        let presence = downloadStatus.0
        if presence {
            if let download = downloadStatus.1 {
                download.downloadTask.cancel()
                self.ongoingDownloads.removeValue(forKey: key!)
            }
        }
    }
    
    public func isDownloadInProgress(forKey key:String?) -> Bool {
        guard let key = key,
              let url = URL(string: key) else {return false}
        let downloadStatus = self.isDownloadInProgress(forUniqueKey: url.lastPathComponent)
        return downloadStatus.0
    }
    
//    public func isDownloading(forKey key: String?) -> Bool {
//        let downloadStatus = self.isDownloadInProgress(forUniqueKey: key)
//        return downloadStatus.0
//    }
    func currentDownload(forKey key:String?) -> SDDownloadObject? {
        guard let key = key,
              let url = URL(string: key) else {return nil}
        let downloadStatus = self.isDownloadInProgress(forUniqueKey: url.lastPathComponent)
        return downloadStatus.1
    }
    public func alterBlocksForOngoingDownload(withUniqueKey key:String?,
                                     setProgress progressBlock:DownloadProgressBlock?,
                                     setCompletion completionBlock:@escaping DownloadCompletionBlock) {
        let downloadStatus = self.isDownloadInProgress(forUniqueKey: key)
        let presence = downloadStatus.0
        if presence {
            if let download = downloadStatus.1 {
                download.progressBlock = progressBlock
                download.completionBlock = completionBlock
            }
        }
    }
    //MARK:- Private methods
    
    private override init() {
        super.init()
        let sessionConfiguration = URLSessionConfiguration.default
        self.session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: Bundle.main.bundleIdentifier!)
        backgroundConfiguration.sessionSendsLaunchEvents = true
        self.backgroundSession = URLSession(configuration: backgroundConfiguration, delegate: self, delegateQueue: OperationQueue())
    }

    private func isDownloadInProgress(forUniqueKey key:String?) -> (Bool, SDDownloadObject?) {
        guard let key = key else { return (false, nil) }
        for (uniqueKey, download) in self.ongoingDownloads {
            if key == uniqueKey {
                return (true, download)
            }
        }
        return (false, nil)
    }
    
    private func showLocalNotification(withText text:String) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else {
                Log.warning("Not authorized to schedule notification")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = text
            content.sound = UNNotificationSound.default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1,
                                                            repeats: false)
            let identifier = "SDDownloadManagerNotification"
            let request = UNNotificationRequest(identifier: identifier,
                                                content: content, trigger: trigger)
            notificationCenter.add(request, withCompletionHandler: { (error) in
                if let error = error {
                    Log.error("Could not schedule notification, error : \(error)")
                }
            })
        }
    }
}

extension SDDownloadManager : URLSessionDelegate, URLSessionDownloadDelegate {
    
    // MARK:- Delegates
    
    public func urlSession(_ session: URLSession,
                             downloadTask: URLSessionDownloadTask,
                             didFinishDownloadingTo location: URL) {
        
        let key = (downloadTask.originalRequest?.url?.lastPathComponent)!
        if let download = self.ongoingDownloads[key]  {
            if let response = downloadTask.response {
                let statusCode = (response as! HTTPURLResponse).statusCode
                
                guard statusCode < 400 else {
                    let error = NSError(domain:"HttpError", code:statusCode, userInfo:[NSLocalizedDescriptionKey : HTTPURLResponse.localizedString(forStatusCode: statusCode)])
                    OperationQueue.main.addOperation({
                        download.completionBlock(error,nil)
                    })
                    return
                }
                
                let fileName = download.fileName ?? downloadTask.response?.suggestedFilename ?? (downloadTask.originalRequest?.url?.lastPathComponent)!
                let directoryName = download.directoryName
                
                let fileMovingResult = SDFileUtils.moveFile(fromUrl: location, toDirectory: directoryName, withName: fileName)
                let didSucceed = fileMovingResult.0
                let error = fileMovingResult.1
                let finalFileUrl = fileMovingResult.2
                
                OperationQueue.main.addOperation({
                    (didSucceed ? download.completionBlock(nil,finalFileUrl) : download.completionBlock(error,nil))
                })
            }
        }
        self.ongoingDownloads.removeValue(forKey:key)
    }
    
    public func urlSession(_ session: URLSession,
                             downloadTask: URLSessionDownloadTask,
                             didWriteData bytesWritten: Int64,
                             totalBytesWritten: Int64,
                             totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else {
            Log.warning("Could not calculate progress as totalBytesExpectedToWrite is less than 0")
            return;
        }
        
        if let download = self.ongoingDownloads[(downloadTask.originalRequest?.url?.lastPathComponent)!],
            let progressBlock = download.progressBlock {
            let progress : CGFloat = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
            OperationQueue.main.addOperation({
                progressBlock(progress)
            })
        }
    }
    
    public func urlSession(_ session: URLSession,
                             task: URLSessionTask,
                             didCompleteWithError error: Error?) {
        
        if let error = error {
            let downloadTask = task as! URLSessionDownloadTask
            Log.error("Download key error : \(downloadTask.originalRequest?.url?.absoluteString ?? "nil")")
            Log.error(error.localizedDescription)
            guard let key = (downloadTask.originalRequest?.url?.lastPathComponent) else {return}
            if let download = self.ongoingDownloads[key] {
                OperationQueue.main.addOperation({
                    download.completionBlock(error,nil)
                })
            }
            
        }
    }

    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            if downloadTasks.count == 0 {
                OperationQueue.main.addOperation({
                    if let completion = self.backgroundCompletionHandler {
                        completion()
                    }
                    
                    if self.showLocalNotificationOnBackgroundDownloadDone {
                        var notificationText = "Download completed"
                        if let userNotificationText = self.localNotificationText {
                            notificationText = userNotificationText
                        }
                        
                        self.showLocalNotification(withText: notificationText)
                    }
                    
                    self.backgroundCompletionHandler = nil
                })
            }
        }
    }
    
}
