//
//  UIViewControllerV3++.swift
//  Shadhin
//
//  Created by Joy on 23/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

extension UIViewController{
    func openMusicPlayerV3(
        musicData: [CommonContentProtocol],
        songIndex: Int,
        isRadio: Bool = false,
        playlistId: String = "",
        rootModel: CommonContentProtocol? = nil) {
            
            var popVC = tabBarController?.popupContainerViewController as? MusicPlayerV3
            if popVC == nil {
                popVC = MusicPlayerV3.shared
            }
            guard let popVC = popVC else { return }
            
            popVC.loadViewIfNeeded()
            popVC.songsIndex = songIndex
            popVC.musicdata = musicData
            popVC.playlistId = playlistId
            popVC.rootContent = rootModel
            popVC.initplayer(rootModel, songIndex)
            
            self.tabBarController?.popupController.delegate = popVC
            
            if let popupBar = self.tabBarController?.popupBar {
                popupBar.dataSource = popVC
                popupBar.progressViewStyle = .top
                popupBar.pbBackgroundColor = .tintColor
                popupBar.progressView.tintColor = UIColor.red
                
                // ✅ Only recreate mini player if not already set
                if !(popupBar.customPopupBarViewController is MusicPlayerV4Mini) {
                    popupBar.customPopupBarViewController = MusicPlayerV4Mini.instantiateNib()
                    popupBar.backgroundView.applyDropShadow(
                        withOffset: .init(width: 0, height: -1),
                        opacity: 0.5, radius: 2, color: .label)
                }
            }
            
            if let container = self.tabBarController?.popupContentView {
                container.popupPresentationStyle = .fullScreen
                container.popupCloseButtonStyle = .none
            }
            
            self.tabBarController?.presentPopupBar(
                withPopupContentViewController: popVC,
                animated: true,
                completion: nil)
            
            // ✅ NEVER manually call viewDidLoad() — iOS manages this lifecycle
            // popVC.viewDidLoad()  ← DELETE THIS
            
            let gesturesEnabled = !isRadio
            tabBarController?.popupBar.popupTapGestureRecognizer.isEnabled = gesturesEnabled
            tabBarController?.popupController.popupBarPanGestureRecognizer.isEnabled = gesturesEnabled
            
            guard !isRadio,
                  let rootModel = rootModel,
                  let rootId = rootModel.contentID,
                  let rootType = rootModel.contentType,
                  musicData[songIndex].trackType?.uppercased() != "LM"
            else { return }
            
            if RecentlyPlayedDatabase.instance.checkRecordExists(contentID: rootId) {
                RecentlyPlayedDatabase.instance.updateDataToDatabase(musicData: rootModel)
            } else {
                RecentlyPlayedDatabase.instance.saveDataToDatabase(musicData: rootModel)
            }
            ShadhinCore.instance.api.recentlyPlayedPost(with: rootId, contentType: rootType)
        }
    
    func openGPMusicsInMiniPlayer() {
        let viewModel = GPAudioViewModel.shared

        guard !viewModel.gpMusicContents.isEmpty else {
            print("🔴 openGPMusicsInMiniPlayer: gpMusicContents empty")
            return
        }

        // ✅ সবসময় AudioPlayer এর current item দিয়ে সঠিক index বের করো
        let syncIndex: Int
        if let currentId = AudioPlayer.shared.currentItem?.contentId,
           let matchedIndex = viewModel.gpMusicContents.firstIndex(where: { String($0.contentId ?? 0) == currentId }) {
            syncIndex = matchedIndex
        } else {
            syncIndex = max(0, min(viewModel.selectedIndexInCarousel, viewModel.gpMusicContents.count - 1))
        }
        viewModel.selectedIndexInCarousel = syncIndex

        guard syncIndex < viewModel.gpMusicContents.count else { return }
        let content = viewModel.gpMusicContents[syncIndex].toCommonContentV4()
        let popVC = MusicPlayerV3.shared

        popVC.loadViewIfNeeded()
        popVC.songsIndex = syncIndex
        popVC.musicdata = viewModel.gpMusicContents.compactMap({ $0.toCommonContentV4() })
        
        MusicPlayerV3.audioPlayer.delegate = popVC

        self.tabBarController?.popupController.delegate = popVC

        if let popupBar = self.tabBarController?.popupBar {
            popupBar.dataSource = popVC
            popupBar.progressViewStyle = .bottom
            popupBar.pbBackgroundColor = .appTintColor
            popupBar.progressView.tintColor = .red

            if !(popupBar.customPopupBarViewController is MusicPlayerV4Mini) {
                popupBar.customPopupBarViewController = MusicPlayerV4Mini.instantiateNib()
            }
        }

        if let container = self.tabBarController?.popupContentView {
            container.popupPresentationStyle = .fullScreen
            container.popupCloseButtonStyle = .none
        }

        let popupState = self.tabBarController?.popupController.popupPresentationState
        if popupState == .hidden || popupState == .dismissing {
            self.tabBarController?.presentPopupBar(withPopupContentViewController: popVC, animated: true, completion: nil)
        }

        // ✅ iCarousel সঠিক index এ scroll করো
        popVC.iCarouselView?.scrollToItem(at: syncIndex, animated: false)
        popVC.updateMiniPlayerInfo(content: content, tabBar: self.tabBarController)

        // ✅ Progress sync
        if let duration = AudioPlayer.shared.currentItemDuration,
           duration > 0,
           let currentTime = AudioPlayer.shared.currentItemProgression {
            let percentage = Float(currentTime / duration) * 100
            if let miniPlayer = self.tabBarController?.popupBar.customPopupBarViewController as? MusicPlayerV4Mini {
                miniPlayer.circularView.setProgress(progress: CGFloat(percentage) / 100)
            }
            popVC.playerSlider?.value = percentage / 100
            popVC.playDurationLbl?.text = formatSecondsToString(currentTime)
            popVC.trackDuration?.text = formatSecondsToString(duration)
        }
    }
    
    func openGPMusicsInMiniPlayer2() {
        let viewModel = GPAudioViewModel.shared

        guard !viewModel.gpMusicContents.isEmpty,
              viewModel.selectedIndexInCarousel >= 0,
              viewModel.selectedIndexInCarousel < viewModel.gpMusicContents.count else {
            print("🔴 openGPMusicsInMiniPlayer: index out of range or empty")
            return
        }

        let index = viewModel.selectedIndexInCarousel
        let content = viewModel.gpMusicContents[index].toCommonContentV4()
        let popVC = MusicPlayerV3.shared

        popVC.loadViewIfNeeded()
        popVC.songsIndex = index
        popVC.musicdata = viewModel.gpMusicContents.compactMap({ $0.toCommonContentV4() })

        self.tabBarController?.popupController.delegate = popVC

        if let popupBar = self.tabBarController?.popupBar {
            popupBar.dataSource = popVC
            popupBar.progressViewStyle = .bottom
            popupBar.pbBackgroundColor = .appTintColor
            popupBar.progressView.tintColor = .red
            let miniPlayer = MusicPlayerV4Mini.instantiateNib()
            popupBar.customPopupBarViewController = miniPlayer
        }

        if let container = self.tabBarController?.popupContentView {
            container.popupPresentationStyle = .fullScreen
            container.popupCloseButtonStyle = .none
        }

        // ← Only present if not already showing
        if self.tabBarController?.popupController.popupPresentationState == .hidden ||
           self.tabBarController?.popupController.popupPresentationState == .dismissing {
            self.tabBarController?.presentPopupBar(withPopupContentViewController: popVC, animated: true, completion: nil)
        }

        popVC.iCarouselView.scrollToItem(at: index, animated: false)
        popVC.updateMiniPlayerInfo(content: content, tabBar: self.tabBarController)
    }
}
