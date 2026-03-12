//
//  MyMusicPlaylistCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/24/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit
import MediaPlayer

class MyMusicPlaylistCell: UITableViewCell {

    @IBOutlet var imgs: [UIImageView]!
    @IBOutlet weak var playlistNameLbl: UILabel!
    @IBOutlet weak var songsCountLbl: UILabel!
    @IBOutlet weak var threeDotMenu: UIButton!
    private var threeDotMenuClick: (()->())?
    
    func configureCell(model: PlaylistsObj.PlaylistDetails,songCount: Int) {
        playlistNameLbl.text = model.name
        songsCountLbl.text = "\(model.Data?.count ?? 0) songs"
        imgs[0].image = UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        imgs[1].image = UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        imgs[2].image = UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        imgs[3].image = UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        if let array = model.Data{
            for (i , item) in array.enumerated(){
                if i > 3 {
                    break
                }
                let imgUrl = item.image.replacingOccurrences(of: "<$size$>", with: "300")
                imgs[i].kf.indicatorType = .activity
                imgs[i].kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
            }
        }
    }
    
    @IBAction func threeDotMenuAction(_ sender: Any) {
        threeDotMenuClick?()
    }
    
    func didThreeDotMenuTapped(completion: @escaping (()->())) {
        threeDotMenuClick = completion
    }
}
