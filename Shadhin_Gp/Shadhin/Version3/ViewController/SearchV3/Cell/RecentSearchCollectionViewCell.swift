//
//  RecentSearchCollectionViewCell.swift
//  Shadhin
//
//  Created by Maruf on 7/2/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class RecentSearchCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var xmarkButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    var historyId = ""
    var refreshHistories:(()->Void)?
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    static var size : CGSize{
        return .init(width: 136, height: 136)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        hideActivityIndicator()
    }
    
    func bindData(data: RecentSearchHistoriesContent){
        historyId = data.id
        let imgUrlString = data.imageUrl.replacingOccurrences(of: "<$size$>", with: "300")
        let imgUrl = URL(string: imgUrlString)
        nameLabel.text = data.artist + " • " + getTypeDescription(type: data.type)
        titleLabel.text = data.title
        image.kf.setImage(with: imgUrl, placeholder: UIImage(named: "default_artist",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
    }
    
    func getTypeDescription(type:String)->String {
        if type == "A" {
            return "Artist"
        }
        else if type == "S" {
            return "Track"
        }
        else if type == "R" {
            return "Album"
        }
        else if type == "P" {
            return "Playlist"
        }
        else if type == "V" {
            return "Video"
        }
        else if type == "VD" {
            return "Video Podcast"
        }else if type.starts(with: "PD"){
            return "Podcast"
        } else if type.starts(with: "VD") {
            return "Video Podcast"
        }
        
        return ""
    }

    @IBAction func deleteSearchHistoryButton(_ sender: Any) {
        showActivityIndicator()
        ShadhinCore.instance.api.deleteSearchHistory_V2(id: historyId) {[weak self] responseModel in
            self?.hideActivityIndicator()
            
            switch responseModel {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print(failure)
            }
            
            if let refresh = self?.refreshHistories {
                refresh()
            }
        }
    }
    
    private func showActivityIndicator() {
        xmarkButton.isHidden = true
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
    }
    
    private func hideActivityIndicator() {
        xmarkButton.isHidden = false
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
    }
}
