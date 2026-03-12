//
//  DiscoverBillboardCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 1/6/20.
//  Copyright © 2020 Gakk Media Ltd. All rights reserved.
//

import UIKit
//import ImageSlideshow


import AVFoundation

class BillboardTableViewCell: UITableViewCell {
    
    public typealias BillboardPageClicked = (_ index: Int)-> Void
    
    @IBOutlet weak var imgeSlideshow: FSPagerView!
    @IBOutlet weak var pageControl: FSPageControl!
    @IBOutlet weak var hiThere: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var greetingsMsg: UILabel!
    @IBOutlet weak var muteBtn: UIButton!
    
    var pendingRequestWorkItem: DispatchWorkItem?
    
    private var models: [CommonContent_V0] = []
    private var billboardPageClicked: BillboardPageClicked?
    var openSeg:  (()-> Void)?
    
    weak var currentCell: BillboardPagerCell?{
        didSet{
            if oldValue == nil{
                setVideoCountDown(2)
                return
            }
            setVideoCountDown()
        }
    }
    weak var previousCell: BillboardPagerCell?
    var isMute = true
    var videoPlayer: AVPlayer?
    var isBeingDragged = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(models: [CommonContent_V0]) {
        guard !models.isEmpty,
              self.models.count != models.count else {
            return
        }
        self.models.removeAll()
        self.models.append(contentsOf: models)
        let fsTransfromer = FSPagerViewTransformer(type: .linear)
        fsTransfromer.minimumAlpha = 1
        fsTransfromer.minimumScale = 1
        imgeSlideshow.transformer =  fsTransfromer
        imgeSlideshow.isInfinite = true
        pageControl.numberOfPages = models.count
        pageControl.contentHorizontalAlignment = .center
        pageControl.setFillColor( #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), for: .selected)
        imgeSlideshow.register(BillboardPagerCell.nib, forCellWithReuseIdentifier: BillboardPagerCell.identifier)
        imgeSlideshow.dataSource = self
        imgeSlideshow.delegate = self
        imgeSlideshow.reloadData()
   
        let dateComponents = Calendar.current.dateComponents([.hour], from: Date())
         if let hour = dateComponents.hour {
           let greetingString: String
           switch hour {
           case 0..<12:
             greetingString = "Good Morning, Enjoy Music"
           case 12..<17:
             greetingString = "Good Afternoon, Enjoy Music"
           default:
             greetingString = "Good Evening, Enjoy Music"
           }
            greetingsMsg.text = greetingString
        }
        
        let fullName = ShadhinCore.instance.defaults.userName
        if !fullName.isEmpty{
            let nameFormatter = PersonNameComponentsFormatter()
            if let nameComps  = nameFormatter.personNameComponents(from: fullName), let firstName = nameComps.givenName{
                hiThere.text = "Hi there,"
                userName.text = " \(firstName)!"
            }
        }
    }
    
    func didTappedBillboardPage(completion: @escaping BillboardPageClicked) {
        self.billboardPageClicked = completion
    }
    
    @IBAction func didTapMuteBtn(_ sender: Any) {
        self.isMute = !self.isMute
        videoPlayer?.isMuted = self.isMute
        if isMute{
            muteBtn.setImage(#imageLiteral(resourceName: "ic_mute_on.pdf"), for: .normal)
        }else{
            muteBtn.setImage(#imageLiteral(resourceName: "ic_mute_off.pdf"), for: .normal)
        }
    }
    
    deinit {
        videoPlayer?.removeObserver(self, forKeyPath: "rate")
        videoPlayer?.pause()
        videoPlayer = nil
        NotificationCenter.default.removeObserver(self)
    }
    
}


extension BillboardTableViewCell: FSPagerViewDataSource{
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        models.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: BillboardPagerCell.identifier, at: index) as! BillboardPagerCell
        cell.contentView.layer.shadowOpacity = 0

        let imgUrl = models[index].newBannerImg?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        cell.mainImg.kf.indicatorType = .activity
        cell.mainImg.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_billboard",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        cell.contentView.setClickListener {
            self.resetPreviousCell()
            self.billboardPageClicked?(index)
        }
        if models[index].RootType?.lowercased() == "lm" || models[index].trackType?.lowercased() == "lm"{
            cell.liveSeg.isHidden = false
//            let animation = Animation.named("live_lottie")
//            cell.liveSegAni.animation = animation
//            cell.liveSegAni.contentMode = .scaleAspectFill
//            cell.liveSegAni.animationSpeed = 0.8
//            cell.liveSegAni.play(fromFrame: 0, toFrame: 41, loopMode: .loop, completion: nil)
        }else{
            cell.liveSeg.isHidden = true
//            cell.liveSegAni.stop()
        }
        if currentCell == nil, index == 0{
            cell.tag = 0
            currentCell = cell
        }
        return cell
    }
    
}

extension BillboardTableViewCell: FSPagerViewDelegate{
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.pageControl.currentPage = targetIndex
        isBeingDragged = false
        guard let cell = pagerView.cellForItem(at: targetIndex) as? BillboardPagerCell else {return}
        cell.tag = targetIndex
        self.currentCell = cell
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        self.pageControl.currentPage = pagerView.currentIndex
        isBeingDragged = false
        guard let cell = pagerView.cellForItem(at: pagerView.currentIndex) as? BillboardPagerCell else {return}
        cell.tag = pagerView.currentIndex
        self.currentCell = cell
       
    }
    
    func pagerViewWillBeginDragging(_ pagerView: FSPagerView) {
        isBeingDragged = true
        resetPreviousCell()
    }
    
    
    func setVideoCountDown(_ delay: Double = 0.5) {
        if MusicPlayerV3.audioPlayer.state == .playing{
            return
        }
        pendingRequestWorkItem?.cancel()
        let requestWorkItem = DispatchWorkItem { [weak self] in self?.playVideoTrailer() }
        pendingRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: requestWorkItem)
    }
    
    @objc func resetPreviousCell(){
        videoPlayer?.pause()
        self.muteBtn.isHidden = true
        if let pCell = self.previousCell{
            pCell.mainImg.layer.removeAllAnimations()
            pCell.mainImg.alpha = 1
            if pCell.mainImg.tag == 1{
                pCell.mainImg.tag = 0
                pCell.mainImg.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
            }
            pCell.videoHolder.layer.sublayers?.removeAll()
            self.previousCell = nil
        }
    }

    
    func playVideoTrailer(){
        //print("Reset previous video and play new for \(String(describing: currentCell?.tag))")
        
        resetPreviousCell()
        
        guard
            let cell = currentCell,
            !isBeingDragged,
            let index = currentCell?.tag,
            let urlStr = models[index].teaserUrl,
            !urlStr.isEmpty,
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
        if keyPath == "rate" {
            if videoPlayer?.rate ?? 0 > 0 {
                //print("video started")
                self.muteBtn.isHidden = false
                self.hideMainImgAni()
            }
        }
    }
    
    func hideMainImgAni(){
        //print("view reset")
        guard let cell = currentCell, !isBeingDragged else {return}
        UIView.animate(withDuration: 1, delay: 0.8, options: .curveEaseOut) {
            cell.mainImg.alpha = 0
            if cell.mainImg.tag == 0{
                cell.mainImg.tag = 1
                cell.mainImg.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
            }
        }
    }
    
}



