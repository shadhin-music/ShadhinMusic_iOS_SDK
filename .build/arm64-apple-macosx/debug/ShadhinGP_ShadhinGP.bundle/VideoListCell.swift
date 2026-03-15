//
//  VideoListCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/18/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit
class VideoListCell: UITableViewCell {
    
    @IBOutlet weak var musicVideoImgView: UIImageView!
    @IBOutlet weak var musicVideoTitleLbl: UILabel!
    @IBOutlet weak var musicVideoArtistLbl: UILabel!
    @IBOutlet weak var videoDurationLbl: UILabel!
    @IBOutlet weak var threeDotBtn: UIButton!
    @IBOutlet weak var circularProgressView: CircularProgress!
    
    private var threeDotMenuClick: (()->())?
    
    func configureCell(model: CommonContentProtocol) {
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "1280") ?? ""
        musicVideoImgView.kf.indicatorType = .activity
        musicVideoImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_video",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        musicVideoTitleLbl.text = model.title ?? ""
        musicVideoArtistLbl.text = model.artist ?? ""
        videoDurationLbl.text = formatSecondsToString(Double(model.duration ?? "") ?? 234)
        checkSongsIsDownloading(data: model)
    }
    
    func checkSongsIsDownloading(data: CommonContentProtocol) {
        
        let isDownloading = SDDownloadManager.shared.isDownloadInProgress(forKey: data.playUrl)
        self.threeDotBtn.isHidden = isDownloading
        self.circularProgressView.isHidden = !isDownloading
        
        if isDownloading {
            guard let obj = SDDownloadManager.shared.currentDownload(forKey: data.playUrl) else {
                return
            }
            //work it when download all song
            obj.progressBlock = { progress in
                self.circularProgressView.setProgress(progress: progress, animated: true)
                if progress == 1.0{
                    self.threeDotBtn.isHidden = false
                    self.circularProgressView.isHidden = true
                    self.circularProgressView.setProgress(progress: 0.0)
                    self.makeToast("File successfully downloaded.")
                    VideosDownloadDatabase.instance.saveDataToDatabase(musicData: data)
                }
            }
            
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            self.musicVideoTitleLbl.textColor = #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1)
        }else {
            self.musicVideoTitleLbl.textColor = .customLabelColor(color: #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        circularProgressView.isHidden = true
        circularProgressView.font = .systemFont(ofSize: 8)
    }
    
    @IBAction func threeDotMenuAction(_ sender: Any) {
        threeDotMenuClick?()
    }
    
    func didThreeDotMenuTapped(completion: @escaping (()->())) {
        threeDotMenuClick = completion
    }
}
