//
//  ArtistSongsViewCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/16/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class ArtistSongsViewCell: UITableViewCell {

    public typealias FollowButtonTapped = ()->()
    public typealias ShareButtonTapped = ()->()
    
    @IBOutlet weak var viewTitleLbl: UILabel!
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var effectView: UIVisualEffectView!
    @IBOutlet weak var songsImgView: UIImageView!
    @IBOutlet weak var songTitleLbl: UILabel!
    @IBOutlet weak var songArtistLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var biographyLbl: UILabel!
    @IBOutlet weak var artistBioDescription: ReadMoreLessView!
    @IBOutlet var bioTopConstraint: NSLayoutConstraint!
    private var backParent: BackParentController?
    private var followButtonTap: FollowButtonTapped?
    private var shareButtonTap: ShareButtonTapped?
    
    var isFollow = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.biographyLbl.isHidden = true
        self.artistBioDescription.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func confifureCell(model: CommonContentProtocol, index: Int,favs: String,artistImg: String, follow: String, monthlyListener: Int) {
        
        let imgUrl = artistImg.replacingOccurrences(of: "<$size$>", with: "300")
        bgImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()))
        songsImgView.kf.indicatorType = .activity
        songsImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: AppImage.artistPlaceholder.uiImage)
        songTitleLbl.text = model.title ?? ""
        var follow_listener = "\(follow) Following"
        if monthlyListener > 0 {
            follow_listener  = "\(follow_listener) • \(monthlyListener) Monthly Listeners"
        }
        songArtistLbl.text = follow_listener
        viewTitleLbl.text = "Artist"
        
        if favs == "1" {
            isFollow = true
            followBtn.isEnabled = true
            followBtn.setTitle("Following", for: .normal)
        }else if favs == "0" {
            isFollow = false
            followBtn.isEnabled = true
            followBtn.setTitle("Follow", for: .normal)
        }else{
            followBtn.isEnabled = false
        }
    }
    
    func didTapFollowButton(completion: @escaping FollowButtonTapped) {
        followButtonTap = completion
    }
    
    func didTapShareButton(completion: @escaping ShareButtonTapped) {
        shareButtonTap = completion
    }
    
    @IBAction func followAction(_ sender: Any) {
        followButtonTap?()
    }
    
    func didTapBackButton(completion: @escaping BackParentController) {
        backParent = completion
    }
    
    @IBAction func backAction(_ sender: Any) {
        backParent?()
    }
    
    @IBAction func shareAction(_ sender: Any) {
        shareButtonTap?()
    }

}
