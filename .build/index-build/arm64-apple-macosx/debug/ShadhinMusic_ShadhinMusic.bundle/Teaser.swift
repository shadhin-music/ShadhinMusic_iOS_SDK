//
//  VideoTeserCell.swift
//  Shadhin
//
//  Created by Joy on 19/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class Teaser: UICollectionViewCell {
    
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var height : CGFloat{
        return  184
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageIV: UIImageView!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var fullscreenButton: UIButton!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playerContentView: UIView!
    @IBOutlet weak var playButton: UIButton!
    
    var content : CommonContentProtocol?
    private var vgPlayer : VGPlayer?
    var isNewContent = true
    var isFullScreenTapped = false
    var onPaidContent : ()-> Void  = {}
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isNewContent = true
      //  vgPlayer?.cleanPlayer()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let playeView = CustomVideoPlayerView()
//        playeView.isTeaser = true
        self.vgPlayer = VGPlayer(playerView: playeView)
        self.vgPlayer?.gravityMode = .resizeAspectFill
        if let pView = vgPlayer?.displayView{
            playerContentView.addSubview(pView)
            pView.snp.makeConstraints { [weak self] (make) in
                guard let strongSelf = self else { return }
                make.top.equalTo(strongSelf.playerContentView.snp.top)
                make.left.equalTo(strongSelf.playerContentView.snp.left)
                make.right.equalTo(strongSelf.playerContentView.snp.right)
                make.bottom.equalTo(strongSelf.playerContentView.snp.bottom)
            }
        }
        vgPlayer?.delegate = self
        vgPlayer?.displayView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(muteTeaser(_:)), name: .shouldMuteTeaser, object: nil)
    }
    @objc func muteTeaser(_ notification: Notification) {
        if !(self.vgPlayer?.player?.isMuted ?? true ){
            self.vgPlayer?.player?.isMuted = true
            soundButton.isSelected = true
        }
        
    }
    
    
    func bind(with content : CommonContentProtocol ){
        self.titleLabel.text = content.title
        self.subtitleLabel.text = content.artist
        if let img = content.image?.image1280 , let url = URL(string: img) {
            print("my img",img)
            imageIV.kf.setImage(with: url)
        }
        if(self.content?.contentID != content.contentID){
            isNewContent = true
        }
        self.content = content
    }
    // "Podcast/VideoFile/TomakeChai_S2_EP32.mp4"
    func startVideo(isErrorReport : Bool = false ){
        guard let content = self.content, isNewContent, !isFullScreenTapped else {return}
        isNewContent = false
        if let playUrl = content.playUrl, playUrl.lowercased().starts(with: "http"){
            self.playVideo(urlString: playUrl, title: content.title ?? "")
        }else{
            ShadhinCore.instance.api.getPlayUrl(content, reportError: isErrorReport) { playUrl, error in
                guard let playUrl = playUrl else {
                    self.isNewContent = true
                    return
                }
                self.playVideo(urlString: playUrl, title: content.title ?? "")
                
            }
        }
    }
    
    func hideMainImgAni(){
        if self.imageIV.tag == 0{
            self.imageIV.tag = 1
            UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseIn) {
                self.imageIV.alpha = 0
                self.playButton.alpha = 0
                self.containerView.isHidden = true
            }
        }
    }
    
    func showMainImgAni(){
        if self.imageIV.tag == 1{
            self.imageIV.tag = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                self.imageIV.alpha = 1
                self.playButton.alpha = 1
                self.containerView.isHidden = false
            }
        }
    }
    
    func clearPlayer(){
        vgPlayer?.cleanPlayer()
    }
    
    private func playVideo(urlString: String,title: String) {
        let decodedUrlString = urlString.decryptUrl() ?? ""
        guard let vgPlayer = self.vgPlayer else {return}
        #if DEBUG
        print("Content play url -> \(decodedUrlString)")
        //decodedUrlString = "https://shadhinmusiccontent.sgp1.digitaloceanspaces.com/VideoMainFile/bhalobeshejebhulejay_imranandpuja.mp4"
        //decodedUrlString = "https://shadhinmusiccontent.sgp1.digitaloceanspaces.com/test_video_url/test_5.mp4"
        //"https://shadhinmusiccontent.sgp1.digitaloceanspaces.com/VideoMainFile/BhalobesheJeBhuleJay_ImranAndPuja.mkv"
        #endif
        
        guard let url = URL(string: decodedUrlString) else {return}
        
        vgPlayer.replaceVideo(url)
        vgPlayer.player?.isMuted = true
        soundButton.isSelected = true
        vgPlayer.play()
    }
    
    @IBAction func onPlayPressed(_ sender: Any) {
        guard let content = self.content else {return}
        if content.isPaid ?? false , !ShadhinCore.instance.isUserPro{
            onPaidContent()
            return
        }
        if self.vgPlayer?.playerItem == nil{
            self.startVideo(isErrorReport: true)
        }else{
            if self.vgPlayer?.player?.rate == 0{
                self.vgPlayer?.play()
            }else{
                self.vgPlayer?.pause()
            }
        }
        
    }
    
    @IBAction func onSoundPressed(_ sender: Any) {
        guard let player = vgPlayer?.player else {return}
        player.isMuted = !player.isMuted
        soundButton.isSelected = !soundButton.isSelected
    }
}
extension Teaser: VGPlayerDelegate {
    
    func vgPlayer(_ player: VGPlayer, playerFailed error: VGPlayerError) {
        Log.error(error.description)
        showMainImgAni()
    }
    
    func vgPlayer(_ player: VGPlayer, stateDidChange state: VGPlayerState) {
        if state == .playing{
            hideMainImgAni()
        }
        if state == .paused{
            showMainImgAni()
        }
        if state == .playFinished{
            showMainImgAni()
            isNewContent = true
        }
    }
    
    func vgPlayer(_ player: VGPlayer, bufferStateDidChange state: VGPlayerBufferstate) {
        Log.info("buffer State --> \(state)")
    }
    
    func vgPlayer(_ player: VGPlayer, bufferedDidChange bufferedDuration: TimeInterval, totalDuration: TimeInterval) {
        //Log.info("vgPlayer --> bufferedDuration \(bufferedDuration)")
        //self.history_total_duration = Int(bufferedDuration)
    }
    var totalDurationWatched: TimeInterval {
       get {
           var totalDurationWatched = 0.0
           if let accessLog = vgPlayer?.player?.currentItem?.accessLog(), accessLog.events.isEmpty == false {
               for event in accessLog.events where event.durationWatched > 0 {
                   totalDurationWatched += event.durationWatched
               }
           }
           let duration = vgPlayer?.player?.currentItem?.duration.seconds ?? 0
           if totalDurationWatched <= duration{
               return totalDurationWatched
           }
           
           return 0
       }
   }
}

extension Teaser: VGPlayerViewDelegate {
    func vgPlayerView(_ playerView: VGPlayerView, willFullscreen fullscreen: Bool) {
        if fullscreen {
            isFullScreenTapped = true
            self.vgPlayer?.displayView.titleLabel.isHidden = false
            self.vgPlayer?.displayView.closeButton.isHidden = false
        }else {
            self.vgPlayer?.displayView.titleLabel.isHidden = true
            self.vgPlayer?.displayView.closeButton.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.isFullScreenTapped = false
            })
        }
    }
    
    
    
    func vgPlayerView(didTappedClose playerView: VGPlayerView) {
        if playerView.isFullScreen {
            playerView.exitFullscreen()
        }else{
            playerView.enterFullscreen()
        }
    }
    
    func vgPlayer(_ player: VGPlayer, playerDurationDidChange currentDuration: TimeInterval, totalDuration: TimeInterval) {
        //print(currentDuration)
        Log.info("vgPlayer --> currentDuration \(currentDuration)")
        //self.history_total_duration += 1
    }
    
    func vgPlayerView(didDisplayControl playerView: VGPlayerView) {
        //backBtn.isHidden = !playerView.isDisplayControl
    }
}


class CustomVideoPlayerView : VGPlayerView{
   
    override func configurationUI() {
        // do nothing
        super.configurationTeaserUI()
        //topView.isHidden = true
    }
}
