//
//  PodcastCollectionCell.swift
//  Shadhin
//
//  Created by Rezwan on 8/3/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class PodcastCollectionCell: UITableViewCell {
    
    enum CellType {
        case SquareBig
        case SquareSmall
        case Portrait
        case LandscapeWithLabel
        case SquareSmallWithLabel
        case VideoPortrait
        case VideoLandscape
        case VideoLandscapeV2
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static func size(_ cellType:CellType) -> CGFloat {
        return PodcastAPI.size(cellType).height + 10 + 15
    }
    
    
    var patchData : Patch!
    var podcastExploreVC : PodcastExploreVC?
    var indexPath : IndexPath = IndexPath.init()
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(SquareBigCell.nib, forCellWithReuseIdentifier: SquareBigCell.identifier)
        collectionView.register(LandscapeCell.nib, forCellWithReuseIdentifier: LandscapeCell.identifier)
        collectionView.register(PortraitCell.nib, forCellWithReuseIdentifier: PortraitCell.identifier)
        collectionView.register(SquareCell.nib, forCellWithReuseIdentifier: SquareCell.identifier)
        collectionView.register(VideoPortraitCell.nib, forCellWithReuseIdentifier: VideoPortraitCell.identifier)
        collectionView.register(VideoLandscapeCell.nib, forCellWithReuseIdentifier: VideoLandscapeCell.identifier)
        collectionView.register(VideoLandscapeV2Cell.nib, forCellWithReuseIdentifier: VideoLandscapeV2Cell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func bind(_ patch : Patch, _ indexPath : IndexPath){
        self.collectionView.setContentOffset(CGPoint(x:0,y:0), animated: false)
        self.patchData = patch
        self.indexPath = indexPath
        self.collectionView.reloadData()
    }
    
}

extension PodcastCollectionCell : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return patchData.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let patchItem = patchData.data[indexPath.row]
        
        switch patchData.patchType.lowercased() {
        case "le":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SquareCell.identifier, for: indexPath) as! SquareCell
            cell.primaryLabel.text = patchItem.episodeName
            cell.secondaryLabel.text = patchItem.showName

            let imgUrl = patchItem.imageURL.replacingOccurrences(of: "<$size$>", with: PodcastAPI.getImgSize(patchData.patchType))
            cell.img.kf.indicatorType = .activity
            cell.img.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
            cell.setClickListener {
                
                self.podcastExploreVC?.openPodcast(patchItem: patchItem)
            }
            return cell
        case "vl":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoLandscapeCell.identifier, for: indexPath) as! VideoLandscapeCell
            cell.primaryLabel.text = patchItem.episodeName
            //cell.secondaryLabel.text = "\(patchItem.presenter) • \(patchItem.duration)"
            cell.secondaryLabel.text = "\(patchItem.duration)"
            
            let imgUrl = patchItem.imageURL.replacingOccurrences(of: "<$size$>", with: PodcastAPI.getImgSize(patchData.patchType))
            cell.img.kf.indicatorType = .activity
            cell.img.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
            cell.setClickListener {
                
//                if !LoginService.instance.isLoggedIn{
//                    guard let mainVc = AppDelegate.shared?.mainHome else {return}
//                    mainVc.showNotUserPopUp(callingVC: mainVc)
//                    return
//                }
                
                let track = CommonContent_V5(id: Int(patchItem.tracktID) ?? 0,
                                      showID: patchItem.showID,
                                      episodeID: patchItem.episodeID,
                                      name: patchItem.trackName,
                                      imageURL: patchItem.imageURL,
                                      playUrl: patchItem.playURL,
                                      starring: patchItem.presenter,
                                      duration: patchItem.duration,
                                      seekable: patchItem.seekable,
                                      details: patchItem.about,
                                      ceateDate: patchItem.ceateDate,
                                      contentType: patchItem.contentType,
                                      sort: 0,
                                      trackType: patchItem.TrackType,
                                      isPaid: patchItem.IsPaid)
                //self.podcastExploreVC?.openPodcast(patchItem: patchItem)
                PodcastYoutubeVC.openLivePodcast(self.podcastExploreVC, track)
            }
            return cell
        case "pp", "news":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SquareBigCell.identifier, for: indexPath) as! SquareBigCell

            let imgUrl = patchItem.imageURL.replacingOccurrences(of: "<$size$>", with: PodcastAPI.getImgSize(patchData.patchType))
            cell.img.kf.indicatorType = .activity
            cell.img.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))

            cell.setClickListener {
                self.podcastExploreVC?.openPodcast(patchItem: patchItem)
            }

            return cell
        case "vp":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoLandscapeV2Cell.identifier, for: indexPath) as! VideoLandscapeV2Cell
            
            let imgUrl = patchItem.imageURL.replacingOccurrences(of: "<$size$>", with: PodcastAPI.getImgSize(patchData.patchType))
            cell.img.kf.indicatorType = .activity
            cell.img.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
            cell.imgBg.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
            cell.primaryLabel.text = patchItem.showName
            cell.secondaryLabel.text = patchItem.presenter
//            let index = indexPath.row % 3
//            cell.imgBg.image = #imageLiteral(resourceName: "pdvdbg_\(index)")
            cell.setClickListener {
                self.podcastExploreVC?.openPodcast(patchItem: patchItem)
            }
            
            return cell
        case "ps":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LandscapeCell.identifier, for: indexPath) as! LandscapeCell
            
            let imgUrl = patchItem.imageURL.replacingOccurrences(of: "<$size$>", with: PodcastAPI.getImgSize(patchData.patchType))
            cell.img.kf.indicatorType = .activity
            cell.img.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
            cell.setClickListener {
                self.podcastExploreVC?.openPodcast(patchItem: patchItem)
            }
            return cell
        case "ss", "tpc":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PortraitCell.identifier, for: indexPath) as! PortraitCell
            cell.primaryLabel.text = patchItem.episodeName
            cell.secondaryLabel.text = patchItem.showName
            
            let imgUrl = patchItem.imageURL.replacingOccurrences(of: "<$size$>", with: PodcastAPI.getImgSize(patchData.patchType))
            cell.img.kf.indicatorType = .activity
            cell.img.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
            
            cell.setClickListener {
                self.podcastExploreVC?.openPodcast(patchItem: patchItem)
            }
            
            return cell
        default:
            return UICollectionViewCell()
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return PodcastAPI.size(patchData.patchType)
    }
    
}
