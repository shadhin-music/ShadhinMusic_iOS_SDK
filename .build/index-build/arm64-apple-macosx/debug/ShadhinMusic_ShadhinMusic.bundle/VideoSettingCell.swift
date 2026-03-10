//
//  VideoSettingCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/18/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class VideoSettingCell: UITableViewCell {
    
    public typealias VideoSettingsTapped = (_ index: Int)->()
    
    private var videoSettingsTap: VideoSettingsTapped?
    
    @IBOutlet weak var autoPlayOn: UISwitch!
    @IBOutlet weak var favBtn: UIButton!
    var isFav = false
    
    @IBOutlet weak var nextVideoLbl: UILabel!
    @IBOutlet weak var autoPlayLbl: UILabel!
    static var isAutoPlayOn = true
    
    override func awakeFromNib() {
        self.selectionStyle = .none
        nextVideoLbl.textColor = .customLabelColor(color: #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1))
        autoPlayLbl.textColor = .customLabelColor(color: #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1))
        
        autoPlayOn.isOn = true
        if autoPlayOn.isOn {
            self.autoPlayOn.thumbTintColor = #colorLiteral(red: 0, green: 0.6578746438, blue: 0.9755771756, alpha: 1)
            self.autoPlayOn.onTintColor = #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 0.2191513271)
        } else {
            self.autoPlayOn.thumbTintColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
            self.autoPlayOn.onTintColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 0.5)
        }
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        videoSettingsTap?(sender.tag)
    }
    
    func didTappedVideoSettingsButton(completion: @escaping VideoSettingsTapped) {
        videoSettingsTap = completion
    }
    
    @IBAction func autoPlayAction(_ sender: UISwitch) {
        VideoSettingCell.isAutoPlayOn = sender.isOn
        
        if autoPlayOn.isOn {
            self.autoPlayOn.thumbTintColor = #colorLiteral(red: 0, green: 0.6578746438, blue: 0.9755771756, alpha: 1)
            self.autoPlayOn.onTintColor = #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 0.2191513271)
        } else {
            self.autoPlayOn.thumbTintColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
            self.autoPlayOn.onTintColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 0.5)
        }
    }
    
    
    func checkSongsIsDownloading(data: CommonContentProtocol) {
        
        let isDownloading = SDDownloadManager.shared.isDownloadInProgress(forKey: data.playUrl)
        //self.threeDotBtn.isHidden = isDownloading
        //self.circularProgressView.isHidden = !isDownloading
        
        if isDownloading {
            SDDownloadManager.shared.alterBlocksForOngoingDownload(withUniqueKey:           data.playUrl, setProgress: { (progress) in
                //self.circularProgressView.setProgress(progress: progress, animated: true)
            }, setCompletion: { (err, url) in
                //self.threeDotBtn.isHidden = false
                //self.circularProgressView.isHidden = true
                
                VideosDownloadDatabase.instance.saveDataToDatabase(musicData: data)
                
                self.makeToast("File successfully downloaded.")
            })
        }
    }
}
