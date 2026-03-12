//
//  UserContentPlaylistAndQueueCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/8/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class UserContentPlaylistAndQueueCell: UITableViewCell {

    @IBOutlet weak var songsImgView: UIImageView!
    @IBOutlet weak var songTitleLbl: UILabel!
    @IBOutlet weak var songArtistLbl: UILabel!
    
  //  @IBOutlet weak var songsDurationLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
       // songsDurationLbl.isHidden = true
    }
    
    func configureCellForFav(model: CommonContentProtocol) {
        songTitleLbl.text = model.title ?? ""
        songArtistLbl.text = model.artist ?? ""
        //songsDurationLbl.text = formatSecondsToString(Double(model.duration ?? "123") ?? 123)
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        songsImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        
    }

    func setSelected(_ selected: Bool) {
        if selected {
            self.songTitleLbl.textColor = #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1)
            self.songArtistLbl.textColor = #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1)
            
        }else {
            self.songTitleLbl.textColor = .customLabelColor(color: #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1))
            self.songArtistLbl.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        }
    }
}
