//
//  LatestAlbumCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/10/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class RecentCell: UICollectionViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size: CGSize {
        return CGSize(width: 120, height: 157)
    }
    
    @IBOutlet weak var albumImgView: UIImageView!
    @IBOutlet weak var albumTitleLbl: UILabel!
    @IBOutlet weak var albumArtistLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        albumTitleLbl.textColor = .customLabelColor(color: #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1))
    }
    
    func configureCell(model: CommonContentProtocol) {
        var placeHolderImage = "default_album"
        albumImgView.cornerRadius = 5
        albumTitleLbl.textAlignment = .natural
        switch SMContentType.init(rawValue: model.contentType) {
        case .artist:
            albumArtistLbl.text = ""
            albumImgView.cornerRadius = 55
            albumTitleLbl.textAlignment = .center
            placeHolderImage = "default_artist"
        case .album:
            albumArtistLbl.text = model.artist?.isEmpty ?? true ? "Album" : model.artist
        case .song:
            albumArtistLbl.text = model.artist?.isEmpty ?? true ? "Single" :  model.artist
            placeHolderImage = "default_song"
        case .podcast:
            albumArtistLbl.text = "Podcast"
        case .playlist:
            albumArtistLbl.text = "" //model.artist?.isEmpty ?? true ? "Playlist" :  model.artist
        default:
            albumArtistLbl.text = ""
        }
        albumTitleLbl.text = model.title ?? ""
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        albumImgView.kf.indicatorType = .activity
        albumImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: placeHolderImage,in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
    }
    
    
}
