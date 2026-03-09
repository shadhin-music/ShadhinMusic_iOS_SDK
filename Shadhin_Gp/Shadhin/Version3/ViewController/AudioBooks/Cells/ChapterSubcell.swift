//
//  ChapterSubcell.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 6/6/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class ChapterSubcell: UICollectionViewCell {
    private var threeDotMenuClick: (()->())?
    @IBOutlet weak var progressView: CustomProgressView!
    
    @IBOutlet weak var downloadIconImg: UIImageView!
    @IBOutlet weak var threeDotButton: UIButton!
    @IBOutlet weak var downloadProgress: CircularProgress!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var episodeNameLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var proImage: UIImageView!
    var audioBookContent: AudioBookContent?
    
    static var identifier: String {
        String(describing: self)
    }
    
    var onThreeDotTap: (CommonContentProtocol) -> Void = {_ in }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var size: CGSize {
        let aspectRatio = 360.0/69.0
        let width = SCREEN_WIDTH
        let height = width/aspectRatio
        return CGSize(width: width, height: height)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        downloadProgressViewSetup()
    }
    
    private func downloadProgressViewSetup() {
        downloadProgress.isHidden = true
        downloadProgress.font = .systemFont(ofSize: 8)
        downloadProgress.progressShapeColor = .tintColor
        downloadProgress.titleColor = .gray
        downloadProgress.lineWidth = 1.5
        downloadProgress.backgroundShapeColor = .gray
        if #available(iOS 13.0, *) {
            downloadProgress.percentColor = UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? .lightGray : .gray
            }
        } else {
            // Fallback on earlier versions
        }
    }
    @IBAction func threeDotMenuAction(_ sender: Any) {
        threeDotMenuClick?()
    }
    func didThreeDotMenuTapped(completion: @escaping (()->())) {
        threeDotMenuClick = completion
    }
    private func updateProgressView(with percentage: Int) {
        progressView.setProgress(percentage: percentage)
    }
    
    func dataBindProgressComplete(data:AudioBookProgress) {
        updateProgressView(with: data.completionPercentage ?? 0)
        
    }
    func bind(data: AudioBookContent) {
        audioBookContent = data
        episodeNameLabel.text = data.titleBn
        durationLabel.text = (data.track?.duration ?? 5).formatTime()
        proImage.isHidden = !(data.isPaid ?? false)
        if ShadhinCore.instance.isUserPro {
            proImage.isHidden = true
        } else {
            proImage.isHidden = false
        }
        setImage(urlString: data.imageUrl)
    }
    
    func setImage(urlString: String?) {
        let url = URL(string: (urlString ?? "").image300)
        imageView.cornerRadius = 2
        imageView.kf.setImage(with: url)
    }
    
    
//    func checkAudioBookIsDownloading(data: CommonContentProtocol) {
//        let isDownloading = SDDownloadManager.shared.isDownloadInProgress(forKey: data.playUrl)
//                
//        self.threeDotButton.isHidden = isDownloading
//        self.downloadProgress.isHidden = !isDownloading
//        if isDownloading {
//            guard let obj = SDDownloadManager.shared.currentDownload(forKey: data.playUrl) else {
//                return
//            }
//            //work it when download all song
//            obj.progressBlock = { progress in
//                self.downloadProgress.setProgress(progress: progress, animated: true)
//                if progress == 1.0{
//                    self.threeDotButton.isHidden = false
//                    self.downloadProgress.isHidden = true
//                    self.downloadProgress.setProgress(progress: 0.0)
//                    DatabaseContext.shared.addPodcast(content: data)
//                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                    appDelegate.window?.rootViewController?.view.makeToast("File successfully downloaded.")
//                    self.downloadIconImg.image = UIImage(named: "downloadCompleteV3")
//                    DatabaseContext.shared.addPodcast(content: data)
//                }
//            }
//            
//        }else{
//            self.threeDotButton.isHidden = false
//            self.downloadProgress.isHidden = true
//        }
//    }
    
//    func checkAudioBookIsDownloading(data: CommonContentProtocol) {
//        let isDownloadingOrExists = SDDownloadManager.shared.isDownloadInProgressOrExists(forKey: data.playUrl)
//        
////        self.threeDotButton.isHidden = isDownloadingOrExists
//        self.downloadProgress.isHidden = !isDownloadingOrExists
//        
//        if isDownloadingOrExists {
//            if let obj = SDDownloadManager.shared.currentDownload(forKey: data.playUrl) {
//                obj.progressBlock = { progress in
//                    self.downloadProgress.setProgress(progress: progress, animated: true)
//                    if progress == 1.0 {
//                        self.threeDotButton.isHidden = false
//                        self.downloadProgress.isHidden = true
//                        self.downloadProgress.setProgress(progress: 0.0)
//                        DatabaseContext.shared.addPodcast(content: data)
//                        UIApplication.shared.delegate?.window??.rootViewController?.view.makeToast("File successfully downloaded.")
//                        self.downloadIconImg.image = UIImage(named: "downloadCompleteV3")
//                    }
//                }
//            } else {
//                self.threeDotButton.isHidden = false
//                self.downloadProgress.isHidden = true
//                self.downloadIconImg.image = UIImage(named: "downloadCompleteV3")
//            }
//        } else {
//            self.threeDotButton.isHidden = false
//            self.downloadProgress.isHidden = true
//        }
//    }
    
    func removeDownalodedSong() {
        self.downloadIconImg.image = UIImage(named: "ic_download_small",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
    }
}

extension Int {
    func formatTime() -> String {
        let hours = self / 3600
        let minutes = (self % 3600) / 60
        let remainingSeconds = self % 60

        if hours > 0 {
            return String(format: "%dh %02dm %02ds", hours, minutes, remainingSeconds)
        } else if remainingSeconds > 0 {
            return String(format: "%dm %02ds", minutes, remainingSeconds)
        } else {
            return String(format: "%dm", minutes)
        }
    }
}
