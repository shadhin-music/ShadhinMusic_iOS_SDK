//
//  PodcastHeaderOneViewCell.swift
//  Shadhin
//
//  Created by Rezwan on 2/10/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class PodcastHeaderOneViewCell: UITableViewCell {
    
    @IBOutlet weak var toolbarTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bgImg: UIImageView!
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var mainImgWidth: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var shareBtnC: UIButton!
    @IBOutlet weak var playOverlayBtn: UIImageView!
    
    var content : CommonContentProtocol?
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var height: CGFloat {
        //return 374 + (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
        return UITableView.automaticDimension

    }
    
    override func awakeFromNib() {
//        self.toolbarTopConstraint.constant = (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
        NotificationCenter.default.addObserver(self, selector: #selector(onPlay), name: .MUSIC_PLAY, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onPause), name: .MUSIC_PAUSE, object: nil)
    }
    
    func bind(content : CommonContentProtocol){
        self.content = content
        onPlay()
    }
    
    @objc
    private func onPlay(){
        DispatchQueue.main.async {[weak self] in
            guard let self = self else {return}
            if let root = MusicPlayerV3.shared.rootContent{
                if  root.contentID == self.content?.contentID, root.contentType == self.content?.contentType,MusicPlayerV3.audioPlayer.state == .playing{
                    self.playBtn.setImage(UIImage(named: "ic_Pause1",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                }else{
                    self.playBtn.setImage(UIImage(named: "ic_Play",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                }
            }else{
                self.playBtn.setImage(UIImage(named: "ic_Play",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
            }
        }
    }
    @objc
    private func onPause(){
        DispatchQueue.main.async {[weak self] in
            guard let self = self else {return}
            if let root = MusicPlayerV3.shared.rootContent{
                if  root.contentID == self.content?.contentID, root.contentType == self.content?.contentType,MusicPlayerV3.audioPlayer.state == .playing{
                    self.playBtn.setImage(UIImage(named: "ic_Pause1",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                }else{
                    self.playBtn.setImage(UIImage(named: "ic_Play",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                }
            }else{
                self.playBtn.setImage(UIImage(named: "ic_Play",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
            }
        }
    }
    
}
