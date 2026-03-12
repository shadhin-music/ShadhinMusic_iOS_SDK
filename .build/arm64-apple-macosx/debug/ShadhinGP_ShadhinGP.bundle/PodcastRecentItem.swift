//
//  MyMusicRecentlyPlayedCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/24/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class PodcastRecentItem: UITableViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
       
//       static var size: CGFloat {
//           return 73
//       }
    
    @IBOutlet weak var circularProgress: CircularProgress!
    @IBOutlet weak var songsImgView: UIImageView!
    @IBOutlet weak var songTitleLbl: UILabel!
    @IBOutlet weak var songArtistLbl: UILabel!
    
    @IBOutlet weak var songsDurationLbl: UILabel!
    
    @IBOutlet weak var threeDotBtn: UIButton!
    
    private var threeDotMenuClick: (()->())?
    
    func configureCell(model: CommonContentProtocol,isFav: Bool) {
        songTitleLbl.text = model.title ?? ""
        songArtistLbl.text = model.artist ?? ""
        //songsDurationLbl.text = formatSecondsToString(TimeInterval(model.duration ?? "") ?? 123)
        songsDurationLbl.text = ""
        if let imgStr = model.image{
            songsImgView.kf.indicatorType = .activity
            songsImgView.kf.setImage(with: ShadhinApi.getImageUrl(url: imgStr, size: 300),placeholder: UIImage(named: "default_song"))
        }
        circularProgress.font = .systemFont(ofSize: 8)
        checkSongsIsDownloading(data: model)
    }
    
    private func checkSongsIsDownloading(data: CommonContentProtocol) {
        
        let isDownloading = SDDownloadManager.shared.isDownloadInProgress(forKey: data.playUrl)
        if isDownloading {
            guard let obj = SDDownloadManager.shared.currentDownload(forKey: data.playUrl) else {
                return
            }
            self.threeDotBtn.isHidden = isDownloading
            self.circularProgress.isHidden = !isDownloading
            //work it when download all song
            obj.progressBlock = { progress in
                Log.info("\(progress)")
                self.circularProgress.setProgress(progress: progress, animated: true)
                if progress == 1.0{
                    self.threeDotBtn.isHidden = false
                    self.circularProgress.isHidden = true
                    self.circularProgress.setProgress(progress: 0.0)
                   // let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    self.makeToast("File successfully downloaded.")
                    DatabaseContext.shared.addPodcast(content: data)
                }
            }
            
        }else{
            self.threeDotBtn.isHidden = false
            self.circularProgress.isHidden = true
        }
    }
    
    private func hideCellItem() {
        self.songTitleLbl.isHidden = true
        self.songsImgView.isHidden = true
        self.songArtistLbl.isHidden = true
        self.songsDurationLbl.isHidden = true
        self.threeDotBtn.isHidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        songTitleLbl.textColor = .customLabelColor(color: #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1))
        songsDurationLbl.textColor = .customLabelColor(color: #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1))
    }
    
    @IBAction func threeDotMenuAction(_ sender: Any) {
        threeDotMenuClick?()
    }
    
    func didThreeDotMenuTapped(completion: @escaping (()->())) {
        threeDotMenuClick = completion
    }
}
