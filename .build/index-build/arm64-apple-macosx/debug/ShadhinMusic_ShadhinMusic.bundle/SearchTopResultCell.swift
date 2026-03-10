//
//  SearchTopResultCell.swift
//  Shadhin
//
//  Created by Maruf on 25/4/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit


class SearchTopResultCell: UICollectionViewCell {
    
    @IBOutlet weak var playVedio: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var dotHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dotWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidthConstrain: NSLayoutConstraint!
    @IBOutlet weak var imageVIewHeightConstrain: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var dynamicImgIcon: UIImageView!
    @IBOutlet weak var dynamicImgView: UIImageView!
    @IBOutlet weak var artistLblOne: UILabel!
    @IBOutlet weak var artistIdLbl: UILabel!
    @IBOutlet weak var artistNameLbl: UILabel!
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    static var size : CGSize {
        return .init(width:SCREEN_WIDTH - 32 , height: 96)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dynamicImgIcon.isHidden = true
    }
    func bind(data:SearchV2Content) {
        let imgUrlString = data.imageUrl.replacingOccurrences(of: "<$size$>", with: "300")
        let imgUrl = URL(string: imgUrlString)
        
        imageView.kf.setImage(with: imgUrl)
        dotHeightConstraint.constant = 14
        dotHeightConstraint.constant = 14
        dynamicImgView.layer.cornerRadius = 0
        dynamicImgIcon.isHidden = true
        if data.contentType == "A" {
            imageViewWidthConstrain.constant = 72
            imageVIewHeightConstrain.constant = 72
            imageView.layer.cornerRadius = 36
            artistNameLbl.text = data.artist
            dynamicImgIcon.isHidden = false
            dynamicImgView.image = UIImage(named: "person_ic",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            dynamicImgView.isHidden = false
            artistIdLbl.text = data.albumId
            artistIdLbl.isHidden = false
            artistLblOne.isHidden = true
            playVedio.isHidden = true
        } else if data.contentType == "S" || data.contentType == "R" {
            dynamicImgIcon.isHidden = true
            imageViewWidthConstrain.constant = 72
            imageVIewHeightConstrain.constant = 72
            imageView.layer.cornerRadius = 8
            artistNameLbl.text = data.title
            artistIdLbl.text = data.albumTitle
            dynamicImgView.image = UIImage(named: "dot_ic",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            dotHeightConstraint.constant = 4
            dotHeightConstraint.constant = 4
            dynamicImgView.layer.cornerRadius = 2
            artistIdLbl.text = data.albumTitle
            playVedio.isHidden = true
            artistLblOne.text = data.artist
            artistLblOne.isHidden = false
            dynamicImgView.isHidden = false
            artistIdLbl.isHidden = false
            
        } else if data.contentType == "Show" {
            imageViewWidthConstrain.constant = 72
            imageVIewHeightConstrain.constant = 72
            imageView.layer.cornerRadius = 8
            artistNameLbl.text = data.title
            artistLblOne.text = data.artist
            dynamicImgView.image = UIImage(named: "dot_ic",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            dotHeightConstraint.constant = 4
            dotHeightConstraint.constant = 4
            dynamicImgView.layer.cornerRadius = 2
            
            artistIdLbl.text = data.albumTitle
            dynamicImgIcon.isHidden = true
            playVedio.isHidden = true
        }
        else if data.contentType == "V" {
            imageViewWidthConstrain.constant = 160
            imageVIewHeightConstrain.constant = 90
            imageView.layer.cornerRadius = 8
            let imgUrlString = data.imageUrl.replacingOccurrences(of: "<$size$>", with: "300")
            let imgUrl = URL(string: imgUrlString)
            imageView.kf.setImage(with: imgUrl)
            artistNameLbl.text = data.title
            artistLblOne.text = data.albumTitle
            dynamicImgView.isHidden = true
            artistIdLbl.isHidden = true
            playVedio.isHidden = false
        }
        else if data.contentType == "P" {
            imageViewWidthConstrain.constant = 72
            imageVIewHeightConstrain.constant = 72
            imageView.layer.cornerRadius = 8
            artistNameLbl.text = data.title
            artistLblOne.text = data.artist
            dynamicImgIcon.isHidden = true
            dynamicImgView.isHidden = true
            artistIdLbl.isHidden = true
            playVedio.isHidden = true
            
        }
        
        if let albumTitle = data.albumTitle, (albumTitle.starts(with: "PD") || albumTitle.starts(with: "VD") ) {
            artistIdLbl.text = data.contentType
        }
    }
    
}
