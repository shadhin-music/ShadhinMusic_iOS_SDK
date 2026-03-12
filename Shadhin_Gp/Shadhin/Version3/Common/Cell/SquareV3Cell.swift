//
//  SquareV3Cell.swift
//  Shadhin
//
//  Created by Joy on 18/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit
//

class SquareV3Cell: UICollectionViewCell {

    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var sizeForLatestRelease : CGSize{
        return .init(width: 136, height: 180)
    }
    static var sizeForFevouritePlaylist : CGSize{
        return .init(width: 136, height: 160)
    }
    static var sizeForTrendyPop : CGSize{
        return .init(width: 136, height: 195)
    }
    @IBOutlet weak var imageIV: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageIV.cornerRadius = 8
        titleLabel.textColor = .textColor
        subtitleLabel.textColor = .textColorSecoundery
        subtitleLabel.numberOfLines = 0
    }
    
    func bind(with content : CommonContentProtocol){
        self.titleLabel.text = content.title
        if let artist = content.artist{
            self.subtitleLabel.text = artist
            self.subtitleLabel.isHidden = false
        }else{
            self.subtitleLabel.isHidden = true 
        }
        
        self.imageIV.kf.setImage(with: URL(string: content.image?.image300 ?? ""),placeholder: AppImage.songPlaceholder.uiImage)
    }
    func bindForFavouroteArtist(with content : CommonContentProtocol){
        self.titleLabel.text = content.title
        self.subtitleLabel.isHidden = true
        self.imageIV.kf.setImage(with: URL(string: content.image?.imageURL ?? ""),placeholder: AppImage.artistPlaceholder.uiImage)
    }
    func bindForTrendyPop(with content : CommonContentProtocol){
        self.titleLabel.text = content.title
        self.subtitleLabel.text = content.artist
        self.imageIV.kf.setImage(with: URL(string: content.image?.imageURL ?? ""))
        
    }
    func bindForTopArtistSongs(with content : CommonContentProtocol){
        self.subtitleLabel.isHidden = true
        self.titleLabel.text = content.title
        self.imageIV.kf.setImage(with: URL(string: content.image?.imageURL ?? ""),placeholder: AppImage.songPlaceholder.uiImage)
    }
}
