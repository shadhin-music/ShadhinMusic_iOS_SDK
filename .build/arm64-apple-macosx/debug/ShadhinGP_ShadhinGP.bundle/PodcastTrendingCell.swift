//
//  PodcastTrendingCell.swift
//  Shadhin
//
//  Created by Rezwan on 8/4/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class PodcastTrendingCell: UITableViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size: CGFloat {
        return 200
    }
    
    @IBOutlet weak var circularProgress: CircularProgress!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var textPrimary: UILabel!
    @IBOutlet weak var textSecondary: UILabel!
    @IBOutlet weak var textDes: UILabel!
    @IBOutlet weak var textDate: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var downloadBtn: UIButton!
    
    var podcastExploreVC : PodcastExploreVC?
    
    var patchItem : PatchItem!
    var track : CommonContentProtocol!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        circularProgress.isHidden = true
        circularProgress.font = .systemFont(ofSize: 8)
    }
    
    func bind(patchItem : PatchItem){
        self.patchItem = patchItem
        let imgUrl = patchItem.imageURL.replacingOccurrences(of: "<$size$>", with: PodcastAPI.getImgSize("tn"))
        img.kf.indicatorType = .activity
        img.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        textPrimary.text = patchItem.trackName
        textSecondary.text = patchItem.showName
        //textDes.text = patchItem.about.htmlToString
        textDate.text = patchItem.duration
        circularProgress.font = .systemFont(ofSize: 8)
        patchItem.about.attributedStringFromHTML(completionBlock: { attrStr in
            DispatchQueue.main.async { [weak self] in
                if let attrStr = attrStr{
                    //cell?.aboutLabel.attributedText = attrStr
                    self?.textDes.attributedText = attrStr
                }else{
                    self?.textDes.text = ""
                    self?.textDes.textColor = .primaryLableColor()
                }
             }
        })
        
        track = CommonContent_V5.init(id: Int(patchItem.tracktID) ?? 0, showID: patchItem.showID, episodeID: patchItem.episodeID, name: patchItem.trackName, imageURL: patchItem.imageURL, playUrl: patchItem.playURL, starring: patchItem.showName, duration: patchItem.duration, seekable: true, details: patchItem.about, ceateDate: patchItem.ceateDate, contentType: patchItem.contentType, sort: 0, trackType: patchItem.TrackType, isPaid: patchItem.IsPaid)
        
        contentView.setClickListener {
            if (patchItem.IsPaid ?? false) && !ShadhinCore.instance.isUserPro {
                self.podcastExploreVC?.goSubscriptionTypeVC()
                return
            }
            self.podcastExploreVC?.navigationController?.openMusicPlayerV3(musicData: [self.track], songIndex: 0, isRadio: false,rootModel: self.track)
        }
        ShadhinCore.instance.api.getAllFavoriteByType(
            type: .podcast) { (data, error) in
                guard let data = data else{
                    return
                }
               
                if data.contains(where: {$0.contentID == patchItem.tracktID}) {
                    self.likeBtn.tag = 1
                    self.likeBtn.setImage(UIImage(named: "ic_favorite_a",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                }else {
                    self.likeBtn.tag = 0
                    self.likeBtn.setImage(UIImage(named: "ic_favorite_n",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                }
                
            }
        
        likeBtn.setClickListener {
            self.addDeleteFav()
        }
        
        downloadBtn.setClickListener {
            self.download(self.track)
        }
        
        downloadIconChange()
        checkSongsIsDownloading(url: track.playUrl!, content: track)
        
        
    }
    
    func addDeleteFav(){
        if likeBtn.tag == 1{
            deleteFav()
        }else{
            addFav()
        }
    }
    
    func addFav(){
        var content         = CommonContent_V0()
        content.contentID   = patchItem.tracktID
        content.albumId     = patchItem.episodeID
        content.contentType = patchItem.contentType
        content.title       = patchItem.trackName
        content.image       = patchItem.imageURL
        content.isPaid      = patchItem.IsPaid
        content.playCount   = patchItem.totalPlayCount
        content.fav         = patchItem.fav
        content.playUrl     = patchItem.playURL
        content.duration    = patchItem.duration
        content.artist      = patchItem.presenter
        
        ShadhinCore.instance.api.addOrRemoveFromFavorite(
            content: content,
            action: .add) { (err) in
                if err != nil {
                    ConnectionManager.shared.networkErrorHandle(err: err, view: self.contentView)
                }else {
                    self.likeBtn.tag = 1
                    self.likeBtn.setImage(UIImage(named: "ic_favorite_a",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                }
            }
    }
    
    func deleteFav(){
        var content         = CommonContent_V0()
        content.contentID   = patchItem.tracktID
        content.albumId     = patchItem.episodeID
        content.contentType = patchItem.contentType
        content.title       = patchItem.trackName
        content.image       = patchItem.imageURL
        content.isPaid      = patchItem.IsPaid
        content.playCount   = patchItem.totalPlayCount
        content.fav         = patchItem.fav
        content.playUrl     = patchItem.playURL
        content.duration    = patchItem.duration
        content.artist      = patchItem.presenter
        
        ShadhinCore.instance.api.addOrRemoveFromFavorite(
            content: content,
            action: .remove) { (err) in
                if err != nil {
                    ConnectionManager.shared.networkErrorHandle(err: err, view: self.contentView)
                }else {
                    self.likeBtn.tag = 0
                    self.likeBtn.setImage(UIImage(named: "ic_favorite_n",in: Bundle.ShadhinMusicSdk,compatibleWith:nil), for: .normal)
                }
            }
    }
    
    
    func download(_ track : CommonContentProtocol){
        guard try! Reachability().connection != .unavailable else {return}
        
        guard ShadhinCore.instance.isUserPro
            //&& LoginService.instance.isChangedLoggedIn == false
            else {
                self.podcastExploreVC?.goSubscriptionTypeVC()
                return
        }
        ShadhinCore.instance.api.getDownloadUrl(track) {
            url, error in
            guard let url = url else {return}
            //self.track.playUrl = url
            self.startDowload(url: url, content: track)
        }
        
        
    }
    
    private func startDowload(url : String,content : CommonContentProtocol){
        self.contentView.makeToast("Downloading \(String(describing: patchItem.trackName ))")
        
        //send to server
        ShadhinCore.instance.api.downloadCompletePost(model: track)
        //send data to firebase analytics
        AnalyticsEvents.downloadEvent(with: track.contentType, contentID: track.contentID, contentTitle: track.title)
        
        let request = URLRequest(url: URL(string: url)!)
        self.downloadBtn.isHidden = true
        self.circularProgress.isHidden = false
        _ = SDDownloadManager.shared.downloadFile(withRequest: request, onCompletion: { error, fileUrl in
            
        })
        checkSongsIsDownloading(url: url, content: content)

    }
    func checkSongsIsDownloading(url: String,content : CommonContentProtocol) {
        
        let isDownloading = SDDownloadManager.shared.isDownloadInProgress(forKey: url)
        self.circularProgress.isHidden = !isDownloading
        
        if isDownloading {
            //if download is on going then its needs to exicute
            guard let obj = SDDownloadManager.shared.currentDownload(forKey: url) else {
                return
            }
            self.downloadBtn.isHidden = true
            self.circularProgress.isHidden = false
            //for all download songs
            obj.progressBlock = { progress in
                Log.error("Progress : \(progress)")
                self.circularProgress.setProgress(progress: progress, animated: true)
                if progress == 1.0{
                    self.circularProgress.setProgress(progress: 0.0)
                    self.downloadBtn.isHidden = false
                    self.circularProgress.isHidden = true
                    self.makeToast("File successfully downloaded.")
                    DatabaseContext.shared.addPodcast(content: content)
                    self.downloadIconChange()
                }
            }
        }
    }
    private func downloadIconChange(){
        circularProgress.isHidden = true
        downloadBtn.isHidden = false
        if DatabaseContext.shared.isPodcastExist(where: track.contentID ?? ""){
            downloadBtn.setImage(AppImage.checkCircelFill.uiImage, for: .normal)
            downloadBtn.isUserInteractionEnabled = false
        }else{
            downloadBtn.isUserInteractionEnabled = true
            downloadBtn.setImage(AppImage.downloadPodcast.uiImage, for: .normal)
        }
    }
}
