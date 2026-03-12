//
//  MusicSongsViewCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/13/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

public typealias BackParentController = ()->()

class MusicSongsViewCell: UITableViewCell {
    
    public typealias PlayButtonClicked = ()->()
    public typealias ShareButtonClicked = ()->()

    @IBOutlet weak var viewTitleLbl: UILabel!
    
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var effectView: UIVisualEffectView!
    
    @IBOutlet weak var songsImgView: UIImageView!
    @IBOutlet weak var songTitleLbl: UILabel!
    @IBOutlet weak var songArtistLbl: UILabel!
    
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var favouriteBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    
    
    
    private var backParent: BackParentController?
    private var playButtonClick: PlayButtonClicked?
    private var shareButtonClick: ShareButtonClicked?
    
    private var content : CommonContentProtocol?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        songTitleLbl.adjustsFontSizeToFitWidth =  true
        songArtistLbl.adjustsFontSizeToFitWidth = true
//        playPauseBtn.setImage(UIImage(named: "ic_Pause1"), for: .selected)
//        playPauseBtn.setImage(UIImage(named: "ic_Play"), for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onPlay), name: .MUSIC_PLAY, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onPause), name: .MUSIC_PAUSE, object: nil)
    }
    
    @objc
    private func onPlay(){
        DispatchQueue.main.async {[weak self] in
            guard let self = self else {return}
            if let root = MusicPlayerV3.shared.rootContent{
                if  root.contentID == self.content?.contentID, root.contentType == self.content?.contentType,MusicPlayerV3.audioPlayer.state == .playing{
                    self.playPauseBtn.setImage(UIImage(named: "ic_Pause1",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                }else{
                    self.playPauseBtn.setImage(UIImage(named: "ic_Play",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                }
            }else{
                self.playPauseBtn.setImage(UIImage(named: "ic_Play",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
            }
        }
    }
    @objc 
    private func onPause(){
        DispatchQueue.main.async {[weak self] in
            guard let self = self else {return}
            if let root = MusicPlayerV3.shared.rootContent{
                if  root.contentID == self.content?.contentID, root.contentType == self.content?.contentType,MusicPlayerV3.audioPlayer.state == .playing{
                    self.playPauseBtn.setImage(UIImage(named: "ic_Pause1",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                }else{
                    self.playPauseBtn.setImage(UIImage(named: "ic_Play",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                }
            }else{
                self.playPauseBtn.setImage(UIImage(named: "ic_Play",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
            }
        }
    }
    
    func configureAlbumCell(model: CommonContentProtocol,albumsAndPlaylistsIndex: Int, totalDurations: String) {
        self.content = model
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        bgImgView.kf.indicatorType = .activity
        bgImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()))
        songsImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_album",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        songTitleLbl.text = model.title ?? ""
        songArtistLbl.text = "\(model.artist ?? "") • \(totalDurations)"
        viewTitleLbl.text = "Album"
        
        onPlay()
    }
    
    
    func configureCell(model: CommonContentProtocol,trackIndex: Int,albumsAndPlaylistsIndex: Int, totalDurations: String) {
        self.content = model
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        songsImgView.kf.indicatorType = .activity
        bgImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()))
        songsImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_playlist"))
        songTitleLbl.text = model.title ?? ""
        
        if model.contentType?.uppercased() == "S" {
            viewTitleLbl.text = "Track"
            songArtistLbl.text = "Single Track" //"\(songListCountText(trackIndex))"
            songsImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        }else {
            viewTitleLbl.text = "Playlist"
            let songText = songListCountText(albumsAndPlaylistsIndex)
            songArtistLbl.text = "\(songText) • \(totalDurations)"
            songsImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_playlist",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        }
        onPlay()
    }
    
    func songListCountText(_ index: Int)-> String {
        let txt = index > 1 ? "Songs" : "Song"
        return "\(index) \(txt)"
    }
    
    
    func didTapBackButton(completion: @escaping BackParentController) {
        backParent = completion
    }

    @IBAction func backAction(_ sender: Any) {
        backParent?()
    }

    @IBAction func shareAction(_ sender: Any) {
        shareButtonClick?()
    }
    
    func didTapShareButton(completion: @escaping ShareButtonClicked) {
        shareButtonClick = completion
    }
    
    func didTapPlayPauseButton(completion: @escaping PlayButtonClicked) {
        playButtonClick = completion
    }
    
    @IBAction func playPauseAction(_ sender: Any) {
     //   NotificationCenter.default.post(name: .shouldMuteTeaser, object: nil)
        playButtonClick?()
        
    }
}
