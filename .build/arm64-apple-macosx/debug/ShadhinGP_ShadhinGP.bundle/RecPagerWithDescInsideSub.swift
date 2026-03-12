//
//  NewReleaseSubCell.swift
//  Shadhin
//
//  Created by Joy on 18/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class RecPagerWithDescInsideSub: UICollectionViewCell {
    
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var height : CGFloat{
        return 196
    }
    
    @IBOutlet weak var newReleaseLabel: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var artistImageIV: UIImageView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var songImageIV: UIImageView!
    
    @IBOutlet weak var songDuration: UILabel!
    private var content: CommonContentProtocol?
    
    var onPlaySong : ((CommonContentProtocol)-> Bool)?
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        artistName.textColor = .textColor
        songName.textColor = .textColor
        songDuration.textColor = .textColorSecoundery
        
        artistImageIV.cornerRadius = artistImageIV.width / 2
        songImageIV.cornerRadius =  8
        
        playButton.setImage(UIImage(named: "ic_play_overlay",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
        playButton.setImage(UIImage(named: "pause",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .selected)
        
        NotificationCenter.default.addObserver(self, selector: #selector(musicPlay), name: .MUSIC_PLAY, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(musicPause), name: .MUSIC_PAUSE, object: nil)
    }
    
    @objc
    func musicPlay(){
        if MusicPlayerV3.audioPlayer.state == .playing{
            if MusicPlayerV3.audioPlayer.currentItem?.contentData?.getRoot() == self.content?.getRoot(){
                // pause icon
                playButton.isSelected = true
            }else{
                //play icon
                playButton.isSelected = false
                
            }
        }
    }
    @objc
    func musicPause(){
        playButton.isSelected = false
    }
    
    func formatTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60
        
        var timeString = ""
        
        if hours > 0 {
            timeString += "\(hours)h "
        }
        if minutes > 0 {
            timeString += "\(minutes)m "
        }
        if remainingSeconds > 0 || timeString.isEmpty {
            timeString += "\(remainingSeconds)s"
        }
        return timeString.trimmingCharacters(in: .whitespaces)
    }

    func bind(with content : CommonContentProtocol){
        self.content = content
        artistName.text = content.artist
        songName.text = content.title
        songDuration.text = self.formatTime(seconds: (Int(content.duration ?? "") ?? 0))

        artistImageIV.kf.setImage(with: URL(string: content.image?.image300 ?? ""))
        songImageIV.kf.setImage(with: URL(string: content.image?.image300 ?? ""))
        
        if MusicPlayerV3.audioPlayer.state == .playing{
            if MusicPlayerV3.audioPlayer.currentItem?.contentData?.getRoot() == content.getRoot(){
                // pause icon
                playButton.isSelected = true
            }else{
                //play icon
                playButton.isSelected = false
                
            }
        }
    }

    @IBAction func onPlayPressed(_ sender: Any) {
        guard let pp = onPlaySong, let content = content, let contentType = content.contentType,let cType = SMContentType(rawValue: contentType), cType == .song else {return}
        let playerRoot = MusicPlayerV3.audioPlayer.currentItem?.contentData?.getRoot()
        if playerRoot == content.getRoot(){
            // pause icon
            if MusicPlayerV3.isAudioPlaying{
                playButton.isSelected = false
                MusicPlayerV3.audioPlayer.pause()
            }else{
                playButton.isSelected = true
                MusicPlayerV3.audioPlayer.resume()
            }
        }else{
            //play icon
            playButton.isSelected = pp(content)
            
        }
        
        
    }
}
