//
//  VideoPlayerCell.swift
//  Shadhin
//
//  Created by Gakk Alpha on 11/25/21.
//  Copyright © 2021 Cloud 7 Limited. All rights reserved.
//

import UIKit

class VideoPlayerCell: UICollectionViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var videoImg: UIImageView!
    @IBOutlet weak var playPauseImg: UIImageView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var circularProgressView: CircularProgress!
    @IBOutlet weak var menuBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        circularProgressView.isHidden = true
        circularProgressView.font = .systemFont(ofSize: 8)
    }
    
    func checkSongsIsDownloading(data: CommonContentProtocol) {
        
        let isDownloading = SDDownloadManager.shared.isDownloadInProgress(forKey: data.playUrl)
        self.menuBtn.isHidden = isDownloading
        self.circularProgressView.isHidden = !isDownloading
        
        if isDownloading {
            guard let obj = SDDownloadManager.shared.currentDownload(forKey: data.playUrl) else {
                return
            }
            //work it when download all song
            obj.progressBlock = { progress in
                self.circularProgressView.setProgress(progress: progress, animated: true)
                if progress == 1.0{
                    let isExist = SDFileUtils.checkFileExists(urlName: data.playUrl ?? "")
                    guard isExist.isExists else {return}
                    self.menuBtn.isHidden = false
                    self.circularProgressView.isHidden = true
                    self.circularProgressView.setProgress(progress: 0.0)
                    self.makeToast("File successfully downloaded.")
                    VideosDownloadDatabase.instance.saveDataToDatabase(musicData: data)
                    ShadhinApi().downloadCompletePost(model: data)
                }
            }
            
        }
    }

}
