//
//  PodcastItemViewCell.swift
//  Shadhin
//
//  Created by Rezwan on 2/11/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class PodcastItemViewCell: UITableViewCell {
    
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var trackSubTitile: UILabel!
    @IBOutlet weak var shortStoryImage: UIImageView!
    @IBOutlet weak var shortStoryImageWidth: NSLayoutConstraint! //42/75
    @IBOutlet weak var circularProgressView: CircularProgress!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var proIc: UIImageView!
    @IBOutlet weak var downloadMark: UIImageView!
    
    private var threeDotMenuClick: (()->())?
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var height: CGFloat {
        return 74
    }
    
    override func awakeFromNib() {
        circularProgressView.isHidden = true
        circularProgressView.font = .systemFont(ofSize: 8)
    }
    
    @IBAction func didTappedThreeDotMenu(_ sender: UIButton) {
        threeDotMenuClick?()
    }
    
    func didThreeDotMenuTapped(completion: @escaping (()->())) {
        threeDotMenuClick = completion
    }
    
    func checkPodcastIsDownloading(data: CommonContentProtocol) {
        
        let isDownloading = SDDownloadManager.shared.isDownloadInProgress(forKey: data.playUrl)
        self.menuButton.isHidden = isDownloading
        self.circularProgressView.isHidden = !isDownloading
        if isDownloading {
            guard let obj = SDDownloadManager.shared.currentDownload(forKey: data.playUrl) else {
                return
            }
            //work it when download all song
            obj.progressBlock = { progress in
                self.circularProgressView.setProgress(progress: progress, animated: true)
                if progress == 1.0{
                    self.menuButton.isHidden = false
                    self.circularProgressView.isHidden = true
                    self.circularProgressView.setProgress(progress: 0.0)
                    DatabaseContext.shared.addPodcast(content: data)
                   self.makeToast("File successfully downloaded.")
                    DatabaseContext.shared.addPodcast(content: data)
                }
            }
            
        }else{
            self.menuButton.isHidden = false
            self.circularProgressView.isHidden = true 
        }
    }
}
