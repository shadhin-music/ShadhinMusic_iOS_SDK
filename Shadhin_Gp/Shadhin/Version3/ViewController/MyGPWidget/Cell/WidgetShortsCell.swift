//
//  WidgetShortsCell.swift
//  Shadhin_Gp
//
//  Created by MD Murad Hossain on 25/11/25.
//

import UIKit
import AVFoundation
import AVKit
import AVFAudio

class WidgetShortsCell: UICollectionViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var muteUnmuteBtn: UIButton!
    
    var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    var isMuted: Bool = true {
        didSet {
            player?.isMuted = isMuted
            updateMuteButton()
        }
    }
    
    private var timeObserver: Any?
    private var isThumbnailHiding = false
    private var isCurrentlyPlaying = false
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    var didTapMuteUnmute: ((Int, Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    private func setupCell() {
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        bgView.backgroundColor = .black
        imgView.isHidden = false
        updateMuteButton()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        isCurrentlyPlaying = false
        stopVideo()
        NotificationCenter.default.removeObserver(self)
        
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil
        
        imgView.isHidden = true
        imgView.alpha = 1.0
        imgView.transform = .identity
        imgView.image = nil
        isThumbnailHiding = false
        bgView.startShimmer()
        updateMuteButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bgView.bounds
        bgView.layer.sublayers?
            .filter { $0.name == "shimmerLayer" }
            .forEach { $0.frame = bgView.bounds }
    }
    
    func configure(with reelsContent: ReelsContent?) {

        bgView.startShimmer()
        imgView.isHidden = true

        if let thumbUrl = reelsContent?.imageURL,
           let url = URL(string: thumbUrl) {

            imgView.kf.setImage(with: url) { [weak self] result in
                guard let self = self else { return }
                self.bgView.stopShimmer()
                self.imgView.isHidden = false
            }
        }

        guard let videoUrlString = reelsContent?.streamingURL,
              let videoUrl = URL(string: videoUrlString) else {
            return
        }

        let playerItem = AVPlayerItem(url: videoUrl)
        player = AVPlayer(playerItem: playerItem)

        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = bgView.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        player?.isMuted = isMuted

        if let playerLayer = playerLayer {
            bgView.layer.insertSublayer(playerLayer, at: 0)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )

        updateMuteButton()
    }
    
    func play() {
        guard let player = player,
              player.currentItem?.status == .readyToPlay,
              !isCurrentlyPlaying else {
            return
        }
        
        isCurrentlyPlaying = true
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback,
                                           mode: .default,
                                           options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
        
        imgView.isHidden = false
        playerLayer?.isHidden = true
        player.play()
        
        if timeObserver == nil {
            addThumbnailHideObserver()
        }
    }
    
    private func addThumbnailHideObserver() {
        removeExistingTimeObserver()
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self,
                  let currentItem = self.player?.currentItem,
                  currentItem.currentTime().seconds > 0.3,
                  !self.isThumbnailHiding else {
                return
            }
            
            self.hideThumbnailWithSmoothAnimation()
        }
    }
    
    private func hideThumbnailWithSmoothAnimation() {
        guard !isThumbnailHiding else { return }
        
        isThumbnailHiding = true
        
        UIView.animate(withDuration: 0.25,
                      delay: 0.0,
                      options: [.beginFromCurrentState, .curveEaseOut],
                      animations: {
            self.imgView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.imgView.alpha = 0.0
        }) { completed in
            self.imgView.isHidden = true
            self.imgView.alpha = 1.0
            self.imgView.transform = .identity
            self.playerLayer?.isHidden = false
            self.isThumbnailHiding = false
            
            self.removeExistingTimeObserver()
        }
    }
    
    private func removeExistingTimeObserver() {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }
    
    func pause() {
        isCurrentlyPlaying = false
        removeExistingTimeObserver()
        player?.pause()
        
        imgView.isHidden = false
        imgView.alpha = 1.0
        imgView.transform = .identity
        playerLayer?.isHidden = true
        isThumbnailHiding = false
    }
    
    func stopVideo() {
        isCurrentlyPlaying = false
        removeExistingTimeObserver()
        player?.pause()
        player?.seek(to: .zero)
        
        imgView.isHidden = false
        imgView.alpha = 1.0
        imgView.transform = .identity
        playerLayer?.isHidden = true
        isThumbnailHiding = false
    }
    
    func updateMuteButton() {
        let bundle = Bundle.ShadhinMusicSdk
        let imageName = isMuted ? "noSound" : "sound"
        
        if let image = UIImage(named: imageName, in: bundle, compatibleWith: nil) {
            muteUnmuteBtn.setBackgroundImage(image, for: .normal)
        } else {
            let symbol = isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill"
            muteUnmuteBtn.setBackgroundImage(UIImage(systemName: symbol), for: .normal)
            muteUnmuteBtn.tintColor = .white
        }
    }
    
    @IBAction func muteUnMuteBtnAction(_ sender: UIButton) {
        self.didTapMuteUnmute?(sender.tag, isMuted)
    }
    
    @objc private func playerDidFinishPlaying() {
        player?.seek(to: .zero)
        player?.play()
    }
}
