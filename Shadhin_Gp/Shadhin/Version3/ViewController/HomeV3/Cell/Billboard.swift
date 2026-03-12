//
//  HomeBannerCell.swift
//  Shadhin
//
//  Created by Joy on 10/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//
//

import UIKit
import AVFoundation

class Billboard: UICollectionViewCell {
   
    @IBOutlet weak var greetingsMsg: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var imageSliderShow: FSPagerView!
    @IBOutlet weak var pageControl: FSPageControl!
    
    private var patch : HomeV3Patch!
    var isBeingDragged = false
    var pendingRequestWorkItem: DispatchWorkItem?
    weak var previousCell: BillboardSub? = nil
    var isMute = true
    var videoPlayer: AVPlayer?
    weak var currentCell: BillboardSub?{
        didSet{
            if oldValue == nil{
                setVideoCountDown(2)
                return
            }
            setVideoCountDown()
        }
    }

    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var height : CGFloat{
        let w = (UIScreen.main.bounds.width - 32)
        let h = ((400 / 330) * w).rounded(.toNearestOrAwayFromZero)
        return h + 64 + 16
    }
    var autoScrollTimer: Timer?
    var onClick : (HomeV3Content)-> Void = {_ in}
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(patch : HomeV3Patch) {
        if(self.patch != nil && self.patch.patch.id == patch.patch.id){
           return
        }
        
        self.patch = patch
        let fsTransfromer = FSPagerViewTransformer(type: .crossFading)
        fsTransfromer.minimumAlpha = 1
        fsTransfromer.minimumScale = 1
        imageSliderShow.transformer =  fsTransfromer
        imageSliderShow.isInfinite = true
        pageControl.numberOfPages = patch.contents.count
        pageControl.contentHorizontalAlignment = .trailing
        pageControl.setFillColor( #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), for: .selected)
        imageSliderShow.register(BillboardSub.nib, forCellWithReuseIdentifier: BillboardSub.identifier)
        imageSliderShow.dataSource = self
        imageSliderShow.delegate = self
        imageSliderShow.reloadData()
        greetingsMessageShow()
        startAutoScroll()
    }

    private func greetingsMessageShow() {
        let dateComponents = Calendar.current.dateComponents([.hour], from: Date())
         if let hour = dateComponents.hour {
           let greetingString: String
           switch hour {
           case 0..<12:
             greetingString = "Good Morning"
           case 12..<17:
             greetingString = "Good Afternoon"
           default:
             greetingString = "Good Evening"
           }
             greetingsMsg.text = greetingString
             
        }
        let fullName = ShadhinCore.instance.defaults.userName
        if !fullName.isEmpty{
            let nameFormatter = PersonNameComponentsFormatter()
            if let nameComps  = nameFormatter.personNameComponents(from: fullName), let firstName = nameComps.givenName{
                userName.text = "\(firstName)!"
            }
        }
    }
    
    func startAutoScroll() {
        stopAutoScroll()
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            guard !self.isBeingDragged else { return }
            let nextIndex = (self.imageSliderShow.currentIndex + 1) % self.patch.contents.count
            self.imageSliderShow.scrollToItem(at: nextIndex, animated: true)
            self.pageControl.currentPage = nextIndex
        }
    }
    
    func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
}

extension Billboard: FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        patch.contents.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let content = patch.contents[index]
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: BillboardSub.identifier, at: index) as! BillboardSub
        cell.contentView.layer.shadowOpacity = 0
        cell.billboardImage.kf.indicatorType = .activity
        let imageUrlStr =  content.image?.safeUrl(.BillboardBanner) ?? ""
        cell.billboardImage.kf.setImage(with: URL(string: imageUrlStr),
                                        placeholder: UIImage(named: "default_billboard",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        cell.bilboardLblName.text = patch.contents[index].title
        cell.billboarsSubLbl.text = patch.contents[index].artist
        cell.noLabel.text = "#\(index + 1)"
        if currentCell == nil, index == 0 {
            cell.tag = 0
            currentCell = cell
        }
        let contentType = SMContentType(rawValue: content.contentType)
        if contentType == .video || contentType == .podcastVideo{
            cell.muteButton.isHidden = false
        }else {
            cell.muteButton.isHidden = true
        }
        return cell
    }
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        onClick(patch.contents[index])
    }
}

extension Billboard: FSPagerViewDelegate {
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
       self.pageControl.currentPage = targetIndex
        isBeingDragged = false
        startAutoScroll()
        guard let cell = pagerView.cellForItem(at: targetIndex) as? BillboardSub else {return}
        cell.tag = targetIndex
        self.currentCell = cell
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        self.pageControl.currentPage = pagerView.currentIndex
        isBeingDragged = false
        startAutoScroll()
        guard let cell = pagerView.cellForItem(at: pagerView.currentIndex) as? BillboardSub else {return}
        cell.tag = pagerView.currentIndex
        self.currentCell = cell
       
    }
    
    func pagerViewWillBeginDragging(_ pagerView: FSPagerView) {
        isBeingDragged = true
        stopAutoScroll()
        resetPreviousCell()
    }
    
    func setVideoCountDown(_ delay: Double = 0.5) {
        if MusicPlayerV3.audioPlayer.state == .playing{
            return
        }
        pendingRequestWorkItem?.cancel()
        let requestWorkItem = DispatchWorkItem(block: {self.playVideoTrailer()})
        pendingRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: requestWorkItem)
    }
    
    @objc func resetPreviousCell(){
        videoPlayer?.pause()
        if let pCell = self.previousCell{
            pCell.billboardImage.layer.removeAllAnimations()
            pCell.billboardImage.alpha = 1
            if pCell.billboardImage.tag == 1{
                pCell.billboardImage.tag = 0
                pCell.billboardImage.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
            }
            pCell.videoHolder.layer.sublayers?.removeAll()
            self.previousCell = nil
        }
    }
    
    func playVideoTrailer(){
        guard
            let cell = currentCell,
            !isBeingDragged,
            let index = currentCell?.tag,
            let urlStr = patch.contents[index].teaserUrl,
            !urlStr.isEmpty,
            patch.contents[index].contentType?.uppercased() != "LK",
            let url = NSURL(string: urlStr) as? URL
            else {return}
        
        self.previousCell = cell
        //url = NSURL(string: "https://shadhinmusiccontent.sgp1.cdn.digitaloceanspaces.com/BillBoard/BillboardTeaser/BhootAppBillboardTeaser/index.m3u8") as! URL
        
        let playerItem = AVPlayerItem(url: url)
        playerItem.preferredForwardBufferDuration = 1
        
        if videoPlayer != nil{
            videoPlayer?.pause()
            videoPlayer?.replaceCurrentItem(with: playerItem)
        }else{
            videoPlayer = AVPlayer(playerItem: playerItem)
            videoPlayer?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
            NotificationCenter.default
                .addObserver(self,
                selector: #selector(resetPreviousCell),
                name: .AVPlayerItemDidPlayToEndTime,
                object: nil
            )
            NotificationCenter.default
                .addObserver(self,
                selector: #selector(resetPreviousCell),
                name: UIApplication.willResignActiveNotification,
                object: nil)
        }
        videoPlayer?.isMuted = self.isMute
        let playerLayerAV = AVPlayerLayer(player: videoPlayer)
        playerLayerAV.frame = cell.videoHolder.bounds
        playerLayerAV.videoGravity = .resize
        cell.videoHolder.layer.addSublayer(playerLayerAV)
        videoPlayer?.play()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        self.hideMainImgAni()
    }

    func hideMainImgAni(){
        guard let cell = currentCell, !isBeingDragged else {return}
        UIView.animate(withDuration: 1, delay: 0.8, options: .curveEaseOut) {
            cell.billboardImage.alpha = 0
            if cell.billboardImage.tag == 0{
                cell.billboardImage.tag = 1
                cell.billboardImage.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
            }
        }
    }
}
