//
//  MusicSongsViewCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/13/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit


class UserPlaylistHeaderCell: UITableViewCell {
    
    public typealias PlayButtonClicked = ()->()
    public typealias ShareButtonClicked = ()->()

    @IBOutlet weak var viewTitleLbl: UILabel!
    
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var effectView: UIVisualEffectView!
    
    @IBOutlet weak var aiMoodImageView: UIImageView!
    
    @IBOutlet var songsImgViews: [UIImageView]!
    
    @IBOutlet weak var songTitleLbl: UILabel!
    @IBOutlet weak var songArtistLbl: UILabel!
    
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var favouriteBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    
    
    
    private var backParent: BackParentController?
    private var playButtonClick: PlayButtonClicked?
    private var shareButtonClick: ShareButtonClicked?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func songListCountText(_ count: Int)-> String {
        let txt = count > 1 ? "Songs" : "Song"
        return "\(count) \(txt)"
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
        playButtonClick?()
    }
}
