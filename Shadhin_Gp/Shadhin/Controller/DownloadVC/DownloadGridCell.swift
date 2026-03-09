//
//  DownloadGridCell.swift
//  Shadhin
//
//  Created by Admin on 19/6/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class DownloadGridCell: UICollectionViewCell {

    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var musicNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var checkMarkView: UIView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var subtitleView: UIView!
    @IBOutlet weak var downloadMarkIV: UIImageView!
    
    static let bottomHeight : CGFloat = 4 + 24 + 4 + 20
    
    //MARK: Create identifier name for cell
    static var identifier: String {
        return String(describing: self)
    }
    
    var isSelectMood : Bool = false {
        didSet{
            UIView.animate(withDuration: 0.2) {
                self.checkMarkView.isHidden = !self.isSelectMood
            }
            
        }
    }
    
    override var isSelected: Bool{
        didSet{
            if isSelectMood{
                if isSelected{
                    checkButton.isSelected = true
                }else{
                    checkButton.isSelected = false
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if #available(iOS 13, *){
            checkButton.setImage(AppImage.checkSqure.uiImage, for: .selected)
            checkButton.setImage(AppImage.uncheckSqure.uiImage, for: .normal)
        }else{
            checkButton.setImage(AppImage.checkSqure12.uiImage, for: .selected)
            checkButton.setImage(AppImage.uncheckSqure12.uiImage, for: .normal)
        }
    }

    //MARK: create nib for access this view
    static func nib()-> UINib{
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    @IBAction func onCheckPressed(_ sender: Any) {
        
    }
    
    
    
}
//MARK:- populate data
extension DownloadGridCell{
    func setItemSelected(isSelect : Bool){
        checkButton.isSelected = isSelect
    }
    func setData(with song : CommonContent_V7,isSelectMood : Bool,from : DownloadChipType = .Songs){
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
            topImageView.kf.setImage(with: url, placeholder: nil)
        }
        self.isSelectMood = isSelectMood
        if from == .History{
            downloadMarkIV.image = AppImage.nonDownload12.uiImage
        }else{
            downloadMarkIV.image = AppImage.downloadIcon.uiImage
        }
    }
}
