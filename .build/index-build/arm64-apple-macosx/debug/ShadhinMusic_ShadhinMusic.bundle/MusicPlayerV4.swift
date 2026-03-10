////
////  MusicPlayerV4.swift
////  Shadhin
////
////  Created by Gakk Alpha on 1/3/23.
////  Copyright © 2023 Cloud 7 Limited. All rights reserved.
////
//
//import UIKit
//
//
//class MusicPlayerV4: UIViewController,NIBVCProtocol {
//    
//    static private var instance : MusicPlayerV4!
//    static var shared : MusicPlayerV4{
//        if instance == nil{
//            instance =  MusicPlayerV4()
//        }
//        return instance
//    }
//    public var isAudioPlaying = false
//    public var audioPlayer : AudioPlayer = AudioPlayer.shared
//    
//    @IBOutlet weak var pager: UICollectionView!
//    weak var playPauseView: UIView?{
//        didSet{
//            playPauseBtn = playPauseView?.viewWithTag(1) as? PlayPauseButton
//            audioPlayer(audioPlayer,didChangeStateFrom: .waitingForConnection, to: audioPlayer.state)
//        }
//    }
//    weak var playPauseBtn: PlayPauseButton?
//    
//    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        if #available(iOS 13.0, *) {
//            return .lightContent
//        } else {
//            return .default
//        }
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        pager.register(MusicItemV4.nib, forCellWithReuseIdentifier: MusicItemV4.identifier)
//        pager.dataSource = self
//        pager.delegate = self
//        audioPlayer.delegate = self
//        audioPlayer.delayedItemChange = true
//        audioPlayer.clearQueueWhenStopped = false
//        audioPlayer.trackItemPlayedAndEnableRetry = true
//    }
//    
//    func initMusic(
//        items           : [CommonContentProtocol],
//        rootItem        : CommonContentProtocol? = nil,
//        selectedIndex   : Int = 0
//    ) -> Bool{
//        var audioItems = [AudioItem]()
//        items.forEach { item in
//            if let audioItem = AudioItem(track: item){
//                audioItem.rootData = rootItem
//                audioItems.append(audioItem)
//            }else{
//                Log.error("Couldn't create AudioItem for ContentDataProtocol -> \(item)")
//            }
//        }
//        if(audioItems.isEmpty){
//            return false
//        }
//        var _selectedIndex = selectedIndex
//        if(_selectedIndex >= audioItems.count){
//            _selectedIndex = 0
//            MainTabBar.shared?.showError(title: "Content Error", msg: "Audio track list contains error, playing from the start")
//        }
//        audioPlayer.play(items: audioItems, startAtIndex: _selectedIndex)
//        if pager != nil{ // to handle calls made before the vc's viewDidLoad called
//            pager.reloadData()
//        }
//        return true
//    }
//    
//    func getCurrentAudioItem() -> AudioItem?{
//        audioPlayer.currentItem
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        guard let currentIndex = audioPlayer.currentItemIndexInQueue else {return}
//        scrollToIndex(index: currentIndex)
//    }
//    
//    func scrollToIndex(index: Int){
//        let indexPath = IndexPath(item: index, section: 0)
//        self.pager.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: false)
//        setCurrentCell(index: index)
//    }
//    
//    func setCurrentCell(index: Int){
//        let indexPath = IndexPath(item: index, section: 0)
//        let item = pager.cellForItem(at: indexPath) as? MusicItemV4
//        item?.startAnimation()
//        self.playPauseView = item?.playPauseView
//        self.playPauseView?.tag = index
//        self.playPauseView?.setClickListener {
//            self.togglePlayPause()
//        }
//        item?.seekbar.value = 0
//        item?.updateTrackProgress(progress: 0, time: .nan)
//        item?.seekbar.addTarget(self, action: #selector(playerSliderAction), for: .valueChanged)
//    }
//    
//    func togglePlayPause(){
//        
//        if audioPlayer.state.isPlaying{
//            audioPlayer.pause()
//        }else if audioPlayer.state.isStopped,
//              let items = audioPlayer.items{
//            audioPlayer.play(items: items, startAtIndex: getCurrentPage())
//        } else{
//            audioPlayer.resume()
//        }
//    }
//    
//    @objc func playerSliderAction(_ sender: UISlider) {
//        guard self.audioPlayer.currentItem?.trackType?.lowercased() != "lm" else {return}
//        let value = Float(audioPlayer.currentItemDuration ?? 1) * sender.value / 100
//        audioPlayer.seek(to: TimeInterval(value))
//    }
//    
//    func updateMiniPlayerInfo(content: CommonContentProtocol){
//        guard let popupbar = self.popupBar.customPopupBarViewController as? MusicPlayerV4Mini else {return}
//        popupbar.updateContent(content: content)
//    }
//    
//    private func userHistoryTracking(item: AudioItem) {
//        if let contentID = item.contentId,
//           let type = item.contentType,
//           let showCode = item.podcastShowCode,
//           let start_time = item.startDate,
//           item.trackType?.uppercased() != "LM"
//        {
//            let playCount = item.playedSeconds > 1 ? "1" : "0"
//            
////            Analytics.logEvent("sm_content_played",
////                               parameters: [
////                                "content_type"  : type.lowercased() as NSObject,
////                                "content_id"    : contentID as NSObject,
////                                "user_type"     : ShadhinCore.instance.defaults.shadhinUserType.rawValue  as NSObject,
////                                "content_name"  : item.contentData?.title?.lowercased() ?? "" as NSObject,
////                                "duration_sec"  : item.playedSeconds as NSObject,
////                                "platform"      : "ios" as NSObject
////                               ])
//            
//            ShadhinCore.instance.api.trackUserHistory(
//                contentID: contentID,
//                type: "\(type)\(showCode)",
//                playCount: playCount,
//                totalPlayInSeconds: item.playedSeconds,
//                playInDate: getCurrentDateAndTime(start_time),
//                playOutDate: getCurrentDateAndTime(),
//                playlistId: item.rootData?.contentID ?? "") { (success) in
//            }
//            ShadhinCore.instance.api.trackUserHistoryV6(
//                contentID: contentID,
//                type: "\(type)\(showCode)",
//                playCount: playCount,
//                totalPlayInSeconds: item.playedSeconds,
//                playInDate: getCurrentDateAndTime(start_time),
//                playOutDate: getCurrentDateAndTime(),
//                playlistId: item.rootData?.contentID ?? "") { (success) in
//            }
//        }
//    }
//    
//}
//
//extension MusicPlayerV4: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        self.audioPlayer.items?.count ?? 0
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MusicItemV4.identifier, for: indexPath) as! MusicItemV4
//        if let item = audioPlayer.items?[indexPath.row]{
//            cell.setItem(audioItem: item)
//            
//        }
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
//        return MusicItemV4.size
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        (cell as? MusicItemV4)?.startAnimation()
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        (cell as? MusicItemV4)?.stopAnimation()
//    }
//    
//    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let index = getCurrentPage()
//        let indexPath = IndexPath(row: index, section: 0)
//        if let currentIndex = audioPlayer.currentItemIndexInQueue,
//           indexPath.row != currentIndex{
//            audioPlayer.playItem(at: index)
//            //audioPlayer.indexToPlay(index: index, from: currentIndex)
//            setCurrentCell(index: index)
//        }else{
//            if index < audioPlayer.items?.count ?? 0,
//               audioPlayer.currentItemIndexInQueue == nil{
//                audioPlayer.queue?.nextPosition = index
//                audioPlayer.next()
//            }
//        }
//    }
//    
////    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
////        audioPlayer.cancelPreviousRequest()
////    }
//    
//
//    
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        if let currentIndex = audioPlayer.currentItemIndexInQueue,
//           currentIndex != playPauseView?.tag{
//            setCurrentCell(index: currentIndex)
//        }
//    }
//    
//    func getCurrentPage() -> Int{
//        let x = pager.contentOffset.y
//        let w = pager.bounds.size.height
//        return Int(ceil(x/w))
//    }
//}
//
//
//
//extension MusicPlayerV4: AudioPlayerDelegate {
//    
//    func audioPlayer(
//        _ audioPlayer: AudioPlayer,
//        didUpdateProgressionTo time: TimeInterval,
//        percentageRead: Float
//    ){
//        if let popupbar = MainTabBar.shared?.popupBar.customPopupBarViewController as? MusicPlayerV4Mini{
//            popupbar.circularView.setProgress(progress: CGFloat(percentageRead) / 100)
//            if popupbar.artistTitle.text == "Loading...",
//               let content = audioPlayer.currentItem?.contentData,
//               percentageRead > 0{
//                    updateMiniPlayerInfo(content: content)
//            }
//            if let playPauseBtnMini = (MainTabBar.shared?.popupBar.customPopupBarViewController as? MusicPlayerV4Mini)?.playPauseBtn,
//               !playPauseBtnMini.isEnabled,
//                percentageRead > 0{
//                self.audioPlayer(audioPlayer, didChangeStateFrom: .buffering, to: audioPlayer.state)
//            }
//        }
//        guard let currentIndex = audioPlayer.currentItemIndexInQueue,
//        let cell = pager.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? MusicItemV4 else {return}
//        if playPauseView == nil{
//            setCurrentCell(index: currentIndex)
//        }
//        cell.updateTrackProgress(progress: percentageRead, time: time)
//    }
//    
//    func audioPlayer(_ audioPlayer: AudioPlayer, willStartPlaying item: AudioItem) {
//        guard let currentIndex = audioPlayer.currentItemIndexInQueue,
//              let content =  item.contentData,
//              !(pager.isDragging || pager.isDecelerating) else {return}
//        
//        if getCurrentPage() != currentIndex{
//            let indexPath = IndexPath(item: currentIndex, section: 0)
//            self.pager.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
//            playPauseView = nil
//        }
//        updateMiniPlayerInfo(content: content)
//    }
//    
//    func audioPlayer(
//        _ audioPlayer: AudioPlayer,
//        didChangeStateFrom from: AudioPlayerState,
//        to state: AudioPlayerState
//    ){
//        
//        let playPauseBtnMini = (MainTabBar.shared?.popupBar.customPopupBarViewController as? MusicPlayerV4Mini)?.playPauseBtn
//        print("playPauseBtnMini \(state)")
//        switch state{
//        case .buffering:
//            playPauseBtn?.showLoading()
//            playPauseBtnMini?.showLoading()
//        case .playing:
//            playPauseBtn?.hideLoading()
//            playPauseBtn?.setPlaying(true)
//            playPauseBtnMini?.hideLoading()
//            playPauseBtnMini?.setPlaying(true)
//        case .paused:
//            playPauseBtn?.hideLoading()
//            playPauseBtn?.setPlaying(false)
//            playPauseBtnMini?.hideLoading()
//            playPauseBtnMini?.setPlaying(false)
//        case .stopped:
//            playPauseBtn?.hideLoading()
//            playPauseBtn?.setPlaying(false)
//            playPauseBtnMini?.hideLoading()
//            playPauseBtnMini?.setPlaying(false)
//        case .waitingForConnection:
//            playPauseBtn?.showLoading()
//            playPauseBtnMini?.showLoading()
//        case .failed(_):
//            playPauseBtn?.hideLoading()
//            playPauseBtn?.setPlaying(false)
//            playPauseBtnMini?.hideLoading()
//            playPauseBtnMini?.setPlaying(false)
//        }
//    }
//    
//    func audioPlayer(finishedPlaying item: AudioItem) {
//        Log.info("Song played:\(String(describing: item.contentData?.title))")
//        self.userHistoryTracking(item: item)
//    }
//    
//}
