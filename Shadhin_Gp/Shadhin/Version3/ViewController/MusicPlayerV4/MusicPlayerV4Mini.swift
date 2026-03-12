//
//  MusicPlayerMini.swift
//  Shadhin
//
//  Created by Gakk Alpha on 3/15/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class MusicPlayerV4Mini: UIViewController,NIBVCProtocol {
    @IBOutlet weak var playPauseBtn: PlayPauseButton!
    @IBOutlet weak var playPauseHolder: UIView!
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var artistTitle: UILabel!
    @IBOutlet weak var circularView: CircularProgress!
    @IBOutlet weak var songImage: UIImageView!
    
    var content: CommonContentProtocol?
    var isContentFav = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = CGSize(width: -1, height: 69)
        playPauseBtn.color = .primaryTextColor()
        playPauseHolder.setClickListener { [weak self] in
           // guard !MusicPlayerV3.shared.isChorkiAdIsPlaying else {return}
            self?.togglePlayPause()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(checkFav), name: .init(rawValue: "FavDataUpdateNotify"), object: nil)
        favBtn.setClickListener { [weak self] in
            self?.favoritesAction()
        }
        playPauseBtn.showLoading()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func togglePlayPause(){
        if AudioPlayer.shared.state.isPlaying{
            AudioPlayer.shared.pause()
        }else{
            AudioPlayer.shared.resume()
        }
    }
    
    func updateContent(content: CommonContentProtocol){
       // print(content.image!)
        let imgUrl = content.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        songImage.kf.setImage(with:URL(string: imgUrl))
        songTitle.text = content.title ?? ""
        artistTitle.text = content.artist ?? ""
        self.content = content
        checkFav()
    }
    
    @objc func checkFav(){
        self.favBtn.setImage(UIImage(named: "ic_fav_t",in:Bundle.ShadhinMusicSdk,compatibleWith:nil), for: .normal)
        self.isContentFav = false

        guard var contentType = content?.contentType else {return}
        if contentType.prefix(2).uppercased() == "PD"{
            contentType = "PD"
        }
        ShadhinCore.instance.api.getAllFavoriteByType(
            type: SMContentType.init(rawValue: contentType))
        { (favs, error) in
            guard let favt = favs else {return}
            if favt.contains(where: {$0.contentID == self.content?.contentID}) {
                self.favBtn.setImage(UIImage(named: "ic_mymusic_favorite",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                self.isContentFav = true
            }else {
                self.favBtn.setImage(UIImage(named: "ic_fav_t",in:Bundle.ShadhinMusicSdk,compatibleWith: nil), for:.normal)
                self.isContentFav = false
            }
        }
    }
    
    func favoritesAction() {
//        guard ShadhinCore.instance.isUserPro else {
//            NavigationHelper.shared.navigateToSubscription(from: self)
//            return
//        }
        guard let item = content else {return}
        ShadhinCore.instance.api.addOrRemoveFromFavorite(
            content: item,
            action: isContentFav ? .remove : .add)
        { (err) in
            if err != nil {
                ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                return
            }else {
                self.view.makeToast(self.isContentFav ? "Removed from Favorites" : "Added To Favorites")
                self.updateFavorite()
                NotificationCenter.default.post(name: .init("FavDataUpdateNotify"), object: nil)
            }
           
        }
    }
    
    func updateFavorite(){
        guard let popVC = MainTabBar.shared?.popupContentViewController as? MusicPlayerV3 else {return}
        popVC.checkFav()
    }


}
