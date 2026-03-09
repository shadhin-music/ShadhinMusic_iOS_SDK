//
//  DownloadManager++.swift
//  Shadhin
//
//  Created by Admin on 23/6/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension Notification.Name{
    static let DownloadStartNotify = Notification.Name(rawValue: "downloadStartNotify")
}
extension SDDownloadManager{
    func checkDatabase(){
        //get remainng downnload file
        guard let dlObject = DatabaseContext.shared.getRemaingDownload() else {return}
        let content = dlObject.getContentProtocal()
        if DatabaseContext.shared.isSongExist(contentId: content.contentID ?? ""){
            DatabaseContext.shared.delete(obj: dlObject)
            checkDatabase()
            return
        }
        //get download url
        ShadhinApi().getDownloadUrl(content) { playUrl, error in
            guard let playUrl = playUrl else {
                //if error change download object flag error true
                // for download next time
                dlObject.error = true
                DatabaseContext.shared.save()
                return
            }
            NotificationCenter.default.post(name: .DownloadStartNotify, object: nil)
            let urlRequest = URLRequest(url: URL(string: playUrl)!)
            let download = self.downloadObjectFile(withRequest: urlRequest,isSingle: content.isSingleDownload) { error, fileUrl in
                
            }
            download?.completionBlock = { error, fileUrl in
                if error != nil {
                    //if error change download object flag error true
                    // for download next time
                    dlObject.error = true
                    DatabaseContext.shared.save()
                    return
                }
                //add songs to download song database with isNotSingle download
                let isPdocast = content.contentType?.prefix(2).uppercased() == "PD" ? true : false
                if isPdocast{
                    DatabaseContext.shared.addPodcast(content: content)
                }else{
                    DatabaseContext.shared.addSong(content: content,isSingleDownload: content.isSingleDownload)
                }
                
                //DatabaseContext.shared.addSong(content: content,isSingleDownload: false)
                //delete download object after finished download
                DatabaseContext.shared.delete(obj: dlObject)
                //check again for download
                self.checkDatabase()
                //log if complete
                NotificationCenter.default.post(name: .DownloadStartNotify, object: nil)
            }
            
        }
    }
}
