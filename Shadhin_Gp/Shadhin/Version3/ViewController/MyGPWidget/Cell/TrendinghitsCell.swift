//
//  RecommendedCell.swift
//  Shadhin_Gp
//
//  Created by Maruf on 7/8/24.
//

import UIKit

class TrendinghitsCell: UICollectionViewCell {
    
    @IBOutlet weak var trendingBtn: UIButton!
    @IBOutlet weak var trendingSongLbl: UILabel!
    @IBOutlet weak var trendingImgView: UIImageView!
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    let viewModel = GPAudioViewModel.shared
    var isPlaying: PlayingState = .neverPlayed
    var audioItem: AudioItem?
    var currentContent: GPContent?
    var reloadCollectionView: ()-> Void = {}
    var index: Int = 0
    var shadhinMusicView: ShadhinMusicView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }
  
    @IBAction func trendingPlayPauseAction(_ sender: Any) {
        if let _ = shadhinMusicView.accessToken, let _ = shadhinMusicView.vc {
            playPauseActionHandler()
        } else {
            shadhinMusicView.gpDeletegate?.gotoShadhinSDK(completionHandler: { vc, accessToken in
                self.shadhinMusicView.vc = vc
                self.shadhinMusicView.accessToken = accessToken
                DispatchQueue.main.async {
                    self.playPauseActionHandler()
                }
            })
        }
    }
    
    func playPauseActionHandler() {
        switch isPlaying {
        case .neverPlayed:
            viewModel.changeAllButtonsToImageName.append(setButtonImage)
            viewModel.whichIndexIsPlayingInTrending = index
//            viewModel.gpMusicContents = viewModel.trendingSongs
            shadhinMusicView.gpCaroselMusicView.reloadData()
            viewModel.startGPContentsAudio(index: index)
            // set other images to notPlaying
            viewModel.changeAllButtonsToImageName.forEach({$0(.neverPlayed, nil)})
            viewModel.setPlayPauseImage(playPauseButton: shadhinMusicView.playPauseButton, isPlaying: .playing)
            isPlaying = .playing
        case .playing:
            AudioPlayer.shared.pause()
            isPlaying = .pause
            viewModel.whichIndexIsPlayingInTrending = nil
            viewModel.setPlayPauseImage(playPauseButton: shadhinMusicView.playPauseButton, isPlaying: .pause)
        case .pause:
            AudioPlayer.shared.resume()
            isPlaying = .playing
            viewModel.whichIndexIsPlayingInTrending = index
            viewModel.setPlayPauseImage(playPauseButton: shadhinMusicView.playPauseButton, isPlaying: .playing)
        }
        
        viewModel.trendingState = isPlaying
        viewModel.trendingSongInteractionContentId = Int(audioItem?.contentId ?? "-")
        shadhinMusicView.collectionView.reloadData()
        setCurrentButtonImage(playingState: isPlaying)
        viewModel.goContentPlayingState = isPlaying
    }
    
    func setCurrentButtonImage(playingState: PlayingState) {
        viewModel.setPlayPauseImage(playPauseButton: trendingBtn, isPlaying: playingState)
    }
    
    func setButtonImage(playingState: PlayingState, contentId: Int?) {
        viewModel.setPlayPauseImage(playPauseButton: trendingBtn, isPlaying: playingState)
        self.isPlaying = .neverPlayed
    }
    
    func dataBind(img: String , title: String) {
        trendingImgView.kf.setImage(with: URL(string: img.image300))
        trendingSongLbl.text = title
        viewModel.setPlayPauseImage(playPauseButton: trendingBtn, isPlaying: isPlaying)
    }

}
