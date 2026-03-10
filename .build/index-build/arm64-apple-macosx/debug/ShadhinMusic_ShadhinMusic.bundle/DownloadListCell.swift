//
//  DownloadListCell.swift
//  Shadhin
//
//  Created by Admin on 19/6/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class DownloadListCell: UICollectionViewCell {
    @IBOutlet weak var checkButtonn: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var musicNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var subtitleView: UIStackView!
    @IBOutlet weak var downloadMarkIV : UIImageView!
    
    var isSelectMood : Bool = false {
        didSet{
            self.checkButtonn.isHidden = !self.isSelectMood
        }
    }
    
    
    //MARK: Create identifier name for cell
    static var identifier: String {
        return String(describing: self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if #available(iOS 13, *){
            checkButtonn.setImage(AppImage.checkSqure.uiImage, for: .selected)
            checkButtonn.setImage(AppImage.uncheckSqure.uiImage, for: .normal)
        }else{
            checkButtonn.setImage(AppImage.checkSqure12.uiImage, for: .selected)
            checkButtonn.setImage(AppImage.uncheckSqure12.uiImage, for: .normal)
        }
        
    }
    //MARK: create nib for access this view
    static func nib()-> UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
}

//MARK:- populate data
extension DownloadListCell{
    func setItemSelected(isSelect : Bool){
        checkButtonn.isSelected = isSelect
    }
    func setData(with song : CommonContentProtocol ,isSelectMood : Bool,from : DownloadChipType = .Songs){
        musicNameLabel.text = song.title
        if from == .Playlist{
            let songCount = DatabaseContext.shared.numbebrOfSongsInPlaylistBy(playlistID: song.contentID ?? "")
            if songCount > 0{
                self.subtitleView.isHidden = false
                artistNameLabel.text = "\(songCount) Songs Download"
            }else{
                self.subtitleView.isHidden = true
                artistNameLabel.text = ""
            }
        }else if from == .Artist{
            let songCount = DatabaseContext.shared.numberOfSongsForArtistBy(artistId: song.contentID ?? "")
            if songCount > 0{
                self.subtitleView.isHidden = false
                artistNameLabel.text = "\(songCount) Songs Download"
            }else{
                self.subtitleView.isHidden = true
                artistNameLabel.text = ""
            }
        }else {
            var subTitle = "\(song.artist ??  "")"
            if subTitle == ""{
                subtitleView.isHidden  = true
            }else{
                subtitleView.isHidden = false
            }
            if subTitle.count > 17{
                let ss = subTitle.prefix(15)
                subTitle = "\(ss)..."
            }
            if let duration = song.duration, duration != ""{
                let du = formatSecondsToString(Double(duration) ?? 123)
                subTitle = "\(subTitle) • \(du)"
            }
            artistNameLabel.text = subTitle
        }
        
        
        if let imgUrl = song.image, let url = ShadhinApi.getImageUrl(url: imgUrl, size: 300){
            iconImageView.kf.setImage(with: url, placeholder: nil)
        }
        self.isSelectMood = isSelectMood
        
        if from == .History{
            downloadMarkIV.image = AppImage.nonDownload12.uiImage
        }else if from == .Songs{
            if DatabaseContext.shared.isSongExist(contentId: song.contentID ?? ""){
                downloadMarkIV.image = AppImage.downloadIcon.uiImage
            }else {
                downloadMarkIV.image = AppImage.notDownload.uiImage
            }
        }
        else{
            downloadMarkIV.image = AppImage.downloadIcon.uiImage
        }
    }
}
