//
//  SearchCommonCollectionViewCell.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 28/4/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit


class SearchCommonCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageDynamicHeight: NSLayoutConstraint!
    @IBOutlet weak var playVideoIcon: UIImageView!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    static var sizeForVedios : CGSize{
        let aspectRatio = (156.0 / 100.0)
        let w = (UIScreen.main.bounds.width - 48)/2
        let h = (w/aspectRatio) + 34
        return .init(width: w, height: h)
    }
    
    static var sizeForLargeVideos : CGSize{
        let aspectRatio = (260.0 / 146)
        let w = (UIScreen.main.bounds.width - 48)/1.5
        let h = (w/aspectRatio) + 48
        return .init(width: w, height: h)
    }
    
    static var sizeForAlbums : CGSize{
        let aspectRatio = (156.0 / 206)
        let w = (UIScreen.main.bounds.width - 48)/2
        let h = (w/aspectRatio)
        return .init(width: w, height: h)
    }
    
    static var sizeForCommon : CGSize{
        let aspectRatio = (136.0 / 188.0)
        let w = (SCREEN_WIDTH-32)/2.5
        let h = (w/aspectRatio)
        return .init(width: w, height: h)
    }

    static var sizeForTwoColumn : CGSize {
        return .init(width:(SCREEN_WIDTH - 48)/2 , height:230)
    }
    
    static var size2 : CGSize {
        return .init(width:(SCREEN_WIDTH - 32 - 12)/2 , height:240.0)
    }
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        playVideoIcon.isHidden = true
        // Calculate aspect ratio of the image
    }
    func bindData(data:SearchV2Content, forAll: Bool) {
        if data.contentType == "V"{
            if !forAll {
                imageSetUpForVedios()
            }
            
            playVideoIcon.isHidden = false
        } else {
            if !forAll {
                imageSetUpForAlbumsAndPlaylists()
            } else {
                imageSetUpForCommon()
            }
            playVideoIcon.isHidden = true
        }
        let imgUrlString = data.imageUrl.replacingOccurrences(of: "<$size$>", with: "300")
        let imgUrl = URL(string: imgUrlString)
        imageView.kf.setImage(with: imgUrl)
        artistName.text = data.artist
        songName.text = data.title
    }
    
    private func imageSetUpForVedios() {
        let aspectRatio = 16.0/9.0
        imageDynamicHeight.constant = SearchCommonCollectionViewCell.sizeForVedios.width/(aspectRatio)
        imageDynamicHeight.priority = .must
        imageDynamicHeight.isActive = true

    }
    private func imageSetUpForAlbumsAndPlaylists() {
        let aspectRatio = 1.0/1.0
        imageDynamicHeight.constant = SearchCommonCollectionViewCell.sizeForAlbums.width/(aspectRatio)
    }
    
    private func imageSetUpForCommon() {
        let aspectRatio = 1.0/1.0
        imageDynamicHeight.constant = SearchCommonCollectionViewCell.sizeForCommon.width/(aspectRatio)
    }

}

