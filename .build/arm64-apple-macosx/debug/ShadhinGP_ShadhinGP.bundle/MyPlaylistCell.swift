//
//  MyPlaylistGridCell.swift
//  Shadhin
//
//  Created by Gakk Alpha on 6/26/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class MyPlaylistCell: UICollectionViewCell {
    
    static var nibList:UINib {
        return UINib(nibName: "MyPlaylistListCell", bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var nibGrid:UINib {
        return UINib(nibName: "MyPlaylistGridCell", bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifierList: String {
        return "MyPlaylistListCell"
    }
    
    static var identifierGrid: String {
        return "MyPlaylistGridCell"
    }
    
    @IBOutlet weak var selectedBtn: UIButton!
    @IBOutlet weak var addImg: UIImageView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var threeDotBtn: UIButton!
    @IBOutlet var img: [UIImageView]!
    @IBOutlet weak var aiImageViewForList: UIImageView!
    
    func configureCell(model: PlaylistsObj.PlaylistDetails, _ inSelectionMode: Bool = false) {
        mainTitle.text = model.name
        subTitle.text = "\(model.Data?.count ?? 0) songs"
        threeDotBtn.isHidden = false
        addImg.isHidden = true
        if inSelectionMode{
            selectedBtn.isHidden = false
            if model.isSelected{
                selectedBtn.setImage(UIImage(resource: ImageResource(name: "ic_artist_check", bundle: Bundle.ShadhinMusicSdk)), for: .normal)
            }else{
                selectedBtn.setImage(UIImage(resource: ImageResource(name: "ic_artist_uncheck", bundle: Bundle.ShadhinMusicSdk)), for: .normal)
            }
        }else{
            selectedBtn.isHidden = true
        }
        
        
        
        if let isAiPlaylist = model.isAIPlayList, isAiPlaylist {
            if let aiImageUrl = model.aiImageUrl {
                aiImageViewForList.isHidden = false
                let url = URL(string: aiImageUrl.safeUrl())
                aiImageViewForList.kf.setImage(with: url)
            }
        } else {
            aiImageViewForList.isHidden = true
            img[0].image = UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            img[1].image = UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            img[2].image = UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            img[3].image = UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            if let array = model.Data{
                for (i , item) in array.enumerated(){
                    if i > 3 {
                        break
                    }
                    let imgUrl = item.image.replacingOccurrences(of: "<$size$>", with: "300")
                    img[i].kf.indicatorType = .activity
                    img[i].kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
                }
            }
        }
    }
    
    func initAddPlaylist(){
        mainTitle.text = "Create Playlist"
        subTitle.text = ""
        threeDotBtn.isHidden = true
        addImg.isHidden = false
        selectedBtn.isHidden = true
        img[0].image = nil
        img[1].image = nil
        img[2].image = nil
        img[3].image = nil
        aiImageViewForList.image = nil
    }

    func configureCell(playList : CommonContent_V7,isSelectMood : Bool){
        let pSongs = DatabaseContext.shared.getPlayListSongsBy(playlistID: playList.contentID ?? "")
        var songs : [CommonContentProtocol] = []
        pSongs.forEach { pls in
            if let song = DatabaseContext.shared.getSongBy(id: pls.songID  ?? ""){
                songs.append(song)
            }
        }
        let images : [String] = songs.map { cdp in
            return cdp.image!
        }
        img[0].image = UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        img[1].image = UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        img[2].image = UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        img[3].image = UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        for i in 0..<images.count{
            if i > 3 {
                break
            }
            img[i].kf.indicatorType = .activity
            let url = ShadhinApi.getImageUrl(url: images[i], size: 300)
            img[i].kf.setImage(with: url,placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
            
        }
        
        mainTitle.text = playList.title
        subTitle.text = "\(songs.count) songs"
        threeDotBtn.isHidden = false
        addImg.isHidden = true
        if isSelectMood{
            selectedBtn.isHidden = false
            if playList.isSelect{
                selectedBtn.setImage(#imageLiteral(resourceName: "ic_artist_check.pdf"), for: .normal)
            }else{
                selectedBtn.setImage(#imageLiteral(resourceName: "ic_artist_uncheck.pdf"), for: .normal)
            }
        }else{
            selectedBtn.isHidden = true
        }
    }
    
}
