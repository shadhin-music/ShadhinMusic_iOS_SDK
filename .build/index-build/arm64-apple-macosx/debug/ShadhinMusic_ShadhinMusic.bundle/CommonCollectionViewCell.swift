//
//  CommonCollectionViewCell.swift
//  Shadhin
//
//  Created by Maruf on 28/4/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class CommonCollectionViewCell: UICollectionViewCell {
    var vc: SearchMainV3?
    
    var searchContent = [SearchV2Content]()
    
    static var sizeForVedios : CGSize{
        let aspectRatio = (360.0 / 232.0)
        let w = (SCREEN_WIDTH - 32)
        let h = (w/aspectRatio)
        return .init(width: w, height: h)
    }
    
    static var commonSize : CGSize{
        let aspectRatio = (360.0 / 221.0)
        let w = (SCREEN_WIDTH - 32)
        let h = (w/aspectRatio)
        return .init(width: w, height: SearchCommonCollectionViewCell.sizeForCommon.height + 36)
    }
    
    static var size : CGSize {
        return .init(width:SCREEN_WIDTH - 32 , height: 280)
    }
    static var size2 : CGSize {
        return .init(width:SCREEN_WIDTH - 32 , height: 280)
    }
    static var size3 : CGSize {
        return .init(width:SCREEN_WIDTH - 32 , height: SCREEN_HEIGHT-210)
    }
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    @IBOutlet weak var collectionView: UICollectionView!
    var contentType : String = ""
    @IBOutlet weak var titleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(SearchCommonCollectionViewCell.nib, forCellWithReuseIdentifier: SearchCommonCollectionViewCell.identifier)
        collectionView.register(ArtistToFollowCell.nib, forCellWithReuseIdentifier: ArtistToFollowCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    func bindData(data:[SearchV2Content], artistName: String = "") {
        searchContent = data
        let resultType: SearchAllResultType = .init(rawValue: contentType) ?? .unknown
        if resultType == .featuring {
            titleLbl.text = "Featuring \(artistName)"
        } else {
            titleLbl.text = contentType
        }
        collectionView.reloadData()
    }

}
extension CommonCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        searchContent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if contentType == SearchAllResultType.artists.rawValue {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtistToFollowCell.identifier, for: indexPath) as? ArtistToFollowCell else {
                fatalError()
            }
            cell.vc = vc
            cell.bindData(data: searchContent[indexPath.item])
            return cell
        } else if contentType != SearchAllResultType.artistToFollow.rawValue {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCommonCollectionViewCell.identifier, for: indexPath) as? SearchCommonCollectionViewCell else {
                fatalError()
            }
            if contentType == SearchAllResultType.videos.rawValue {
                cell.playVideoIcon.isHidden = false
            }
            cell.bindData(data: searchContent[indexPath.item], forAll: true)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtistToFollowCell.identifier, for: indexPath) as? ArtistToFollowCell else {
                fatalError()
            }
            cell.vc = vc
            cell.bindData(data: searchContent[indexPath.item])
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let resultType: SearchAllResultType = .init(rawValue: contentType) ?? .unknown
        
        if resultType == .podcastShows || resultType == .podcastEpisodes{
            vc?.coordinator?.routeToContent(content: searchContent[indexPath.item].toCommonContentForPodcast(shoudlHistoryAPICall: true))
        }else if(resultType == .videoPodcast){
            var item =  searchContent[indexPath.item].toCommonContentForPodcast(shoudlHistoryAPICall: true)
            item.contentID = "0"
            vc?.coordinator?.routeToContent(content: item)
        } else {
            if let item = searchContent[indexPath.item].contentType, (item.starts(with: "PD") || item.starts(with: "VD")) {
                vc?.coordinator?.routeToContent(content: searchContent[indexPath.item].toCommonContentForPodcast(shoudlHistoryAPICall: true))
            } else {
                vc?.coordinator?.routeToContent(content: searchContent[indexPath.item].toCommonContent(shoudlHistoryAPICall: true))
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if contentType == SearchAllResultType.artists.rawValue {
            return SearchCommonCollectionViewCell.size2
        } else if contentType == SearchAllResultType.artistToFollow.rawValue {
            return ArtistToFollowCell.size
        } else if searchContent[indexPath.item].contentType == "V" {
            return SearchCommonCollectionViewCell.sizeForLargeVideos
        }
        
        return SearchCommonCollectionViewCell.sizeForCommon
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}
