//
//  NewReleaseMain.swift
//  Shadhin
//
//  Created by Rezwan on 20/6/21.
//  Copyright © 2021 Cloud 7 Limited. All rights reserved.
//

import UIKit


class NewReleaseMain: UITableViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var height: CGFloat {
        return 218
    }

    @IBOutlet weak var pagerView: FSPagerView!
    @IBOutlet weak var pagerControl: FSPageControl!
    
    var array: [CommonContent_V0] = []
    
    
    func bind(array : [CommonContent_V0]){
        if self.array.count == array.count{
            return
        }
        self.array.removeAll()
        self.array.append(contentsOf: array)
        pagerControl.numberOfPages = array.count
        pagerControl.contentHorizontalAlignment = .center
        pagerControl.setFillColor( #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), for: .selected)
        pagerView.transformer = FSPagerViewTransformer(type: .crossFading)
        self.pagerView.register(NewReleaseSub.nib, forCellWithReuseIdentifier: NewReleaseSub.identifier)
        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.reloadData()
    }
    
}

extension NewReleaseMain: FSPagerViewDataSource{
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        array.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let item = array[index]
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: NewReleaseSub.identifier, at: index) as! NewReleaseSub
        cell.contentView.layer.shadowOpacity = 0
        cell.artistName.text = item.artist
        cell.trackName.text = item.title
        if let duration =  Int(item.duration ?? "0"){
            let seconds = duration % 60
            let minutes = (duration / 60) % 60

             // return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
            cell.trackPlayCount.text = String(format: "Duration : %d:%02d", minutes, seconds)
        }
        if let imgUrl = item.image?.replacingOccurrences(of: "<$size$>", with: "300"){
            cell.trackImg.kf.indicatorType = .activity
            cell.trackImg.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        }
        
        if let imgUrl = item.bannerImg?.replacingOccurrences(of: "<$size$>", with: "300"){
            cell.artistImg.kf.indicatorType = .activity
            cell.artistImg.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        }
        
        if item.contentID == MusicPlayerV3.audioPlayer.currentItem?.contentId, !MusicPlayerV3.isAudioPlaying{
            cell.playPauseImg.image = #imageLiteral(resourceName: "ic_pause_new_release")
            cell.playPauseImg.tag = 1
        }else{
            cell.playPauseImg.image = #imageLiteral(resourceName: "ic_play_new_release")
            cell.playPauseImg.tag = 0
        }
        cell.playPauseImg.setClickListener {
            self.playPause(index: index)
        }
        
        cell.contentView.setClickListener {
//            if !LoginService.instance.isLoggedIn{
//                guard let mainVc = AppDelegate.shared?.mainHome else {return}
//                mainVc.showNotUserPopUp(callingVC: mainVc)
//                return
//            }
//            if let vc = AppDelegate.shared?.mainHome {
//                let playlistVc = vc.goPlaylistVC(content: self.array[index])
//                vc.navigationController?.pushViewController(playlistVc, animated: true)
//            }
        }
        
        
        return cell
    }
    
    func playPause(index: Int){
//        if !LoginService.instance.isLoggedIn{
//            guard let mainVc = AppDelegate.shared?.mainHome else {return}
//            mainVc.showNotUserPopUp(callingVC: mainVc)
//            return
//        }
        let cell = pagerView.cellForItem(at: index) as! NewReleaseSub
        if  cell.playPauseImg.tag == 0{
            if MusicPlayerV3.audioPlayer.state == .stopped || MusicPlayerV3.audioPlayer.currentItem?.contentId != array[index].contentID {
//                if let vc = AppDelegate.shared?.mainHome{
//                    vc.openMusicPlayerV3(musicData: array, songIndex: index, isRadio: false)
//                }
            }else {
                MusicPlayerV3.audioPlayer.resume()
            }
            cell.playPauseImg.tag = 1
            cell.playPauseImg.image = #imageLiteral(resourceName: "ic_pause_new_release")
            MusicPlayerV3.isAudioPlaying = false
        }else {
            MusicPlayerV3.audioPlayer.pause()
            cell.playPauseImg.image = #imageLiteral(resourceName: "ic_play_new_release")
            cell.playPauseImg.tag = 0
            MusicPlayerV3.isAudioPlaying = true
        }
    }
    
    
}

extension NewReleaseMain: FSPagerViewDelegate{
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.pagerControl.currentPage = targetIndex
        let cell = pagerView.cellForItem(at: targetIndex) as! NewReleaseSub
        if array[targetIndex].contentID == MusicPlayerV3.audioPlayer.currentItem?.contentId, !MusicPlayerV3.isAudioPlaying{
            cell.playPauseImg.image = #imageLiteral(resourceName: "ic_pause_new_release")
            cell.playPauseImg.tag = 1
        }else{
            cell.playPauseImg.image = #imageLiteral(resourceName: "ic_play_new_release")
            cell.playPauseImg.tag = 0
        }
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        self.pagerControl.currentPage = pagerView.currentIndex
        let cell = pagerView.cellForItem(at: pagerView.currentIndex) as! NewReleaseSub
        if array[pagerView.currentIndex].contentID == MusicPlayerV3.audioPlayer.currentItem?.contentId, !MusicPlayerV3.isAudioPlaying{
            cell.playPauseImg.image = #imageLiteral(resourceName: "ic_pause_new_release")
            cell.playPauseImg.tag = 1
        }else{
            cell.playPauseImg.image = #imageLiteral(resourceName: "ic_play_new_release")
            cell.playPauseImg.tag = 0
        }
    }
    
}
