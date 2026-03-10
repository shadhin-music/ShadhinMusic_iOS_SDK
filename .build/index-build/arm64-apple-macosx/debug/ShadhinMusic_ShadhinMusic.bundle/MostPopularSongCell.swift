//
//  MostPopuperSongCell.swift
//  Shadhin
//
//  Created by Maruf on 28/4/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class MostPopularSongCell: UICollectionViewCell {
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var videoPlayImage: UIImageView!
    @IBOutlet weak var dotImage: UIImageView!
    @IBOutlet weak var indexLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var albumNameLbl: UILabel!
    @IBOutlet weak var artistNameLbl: UILabel!
    @IBOutlet weak var songNameLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var indexLabel: UILabel!
    static var size : CGSize {
        return .init(width:SCREEN_WIDTH-32 , height:56+8)
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func dataBind(data:SearchV2Content,index:String, isAllSearch: Bool = false) {
        
        if isAllSearch {
            let imgUrlString = data.imageUrl.replacingOccurrences(of: "<$size$>", with: "300")
            let imgUrl = URL(string: imgUrlString)
            imageView.kf.setImage(with: imgUrl)
            dotImage.isHidden = true
            videoPlayImage.isHidden = true
            albumNameLbl.isHidden = true
            songNameLbl.isHidden = false
            artistNameLbl.isHidden = false
            songNameLbl.text = data.contentName
            hideIndex()
            
            imageWidthConstraint.constant = 56.0
            imageHeightConstraint.constant = 56.0
            var artistNameSection = ""
            if let artistName = data.artist, !artistName.isEmpty {
                artistNameSection = " • \(artistName)"
            }
            
            if data.type == "A" {
                artistNameLbl.text = "Artist"
            }
            else if data.type == "S" {
                artistNameLbl.text = "Track" + artistNameSection
            }
            else if data.type == "R" {
                artistNameLbl.text = "Album" + artistNameSection
            }
            else if data.type == "P" {
                artistNameLbl.text = "Playlist" + artistNameSection
            }
            else if data.type == "V" {
                artistNameLbl.text = "Video" + artistNameSection
            }
            else if data.type == "VD" {
                artistNameLbl.text = "Video Podcast" + artistNameSection
            }else if let type = data.type, type.starts(with: "PD"){
                artistNameLbl.text = "Podcast" + artistNameSection
            }
            
            
        } else {
            let resultType: SearchAllResultType = .init(rawValue: data.resultType ?? "") ?? .unknown
            indexLabelWidthConstraint.constant = 16.0
            // Set the priority of the constraint to required
            indexLabelWidthConstraint.priority = .required
            indexLabelWidthConstraint.isActive = true
            indexLabel.isHidden = false
            imageWidthConstraint.constant = 56.0
            imageHeightConstraint.constant = 56.0
            videoPlayImage.isHidden = true
            dotImage.isHidden = false
            albumNameLbl.isHidden = false
            
            if resultType == .tracks {
                hideIndex()
            }
            
            if data.contentType == "V" {
                imageWidthConstraint.constant = 100.0
                imageHeightConstraint.constant = 56.0
                dotImage.isHidden = true
                albumNameLbl.isHidden = true
                videoPlayImage.isHidden = false
            }
            
            let imgUrlString = data.imageUrl.replacingOccurrences(of: "<$size$>", with: "300")
            let imgUrl = URL(string: imgUrlString)
            imageView.kf.setImage(with: imgUrl)
            songNameLbl.text = data.title
            artistNameLbl.text = data.artist
            albumNameLbl.text = data.albumTitle
            indexLabel.text = index
            if let contentType = data.contentType, (contentType.starts(with: "PD") || contentType.starts(with: "VD")){
                albumNameLbl.text = data.albumTitle
            }
        }
        
        func hideIndex(){
            indexLabelWidthConstraint.constant = 0.0
            indexLabelWidthConstraint.priority = .required
            indexLabelWidthConstraint.isActive = true
            indexLabel.isHidden = true
        }
    }
}
