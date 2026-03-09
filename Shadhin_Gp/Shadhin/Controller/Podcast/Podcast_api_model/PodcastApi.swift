//
//  PodcastApi.swift
//  Shadhin
//
//  Created by Rezwan on 6/11/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

extension PodcastVC {

    func getPodcastData(completion: (() -> Void)? = nil) {
        tableView.setContentOffset(.zero, animated: false)

        ShadhinCore.instance.api.getPodcastDetails(
            podcastType: podcastType,
            contentType: podcastShowCode,
            episodeId: selectedEpisode
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.podcastModel = response.data
                    self.noInternetView.isHidden = true
                    SwiftEntryKit.dismiss()

                case .failure(let error):
                    print("❌ Podcast API Error: \(error.localizedDescription)")
                    self.makeToast(msg: error.localizedDescription)
                }

                completion?()
            }
        }
    }
    
    func getPodcastTracksData(completion: (() -> Void)? = nil) {
        tableView.setContentOffset(.zero, animated: false)
        ShadhinCore.instance.api.getPodcastTracksDetails(
            podcastType: podcastType,
            contentType: podcastShowCode,
            episodeId: selectedEpisode
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.tracksEpisode = response.data
                    self.noInternetView.isHidden = true
                    SwiftEntryKit.dismiss()

                case .failure(let error):
                    print("❌ Podcast API Error: \(error.localizedDescription)")
                    self.makeToast(msg: error.localizedDescription)
                }

                completion?()
            }
        }
    }
    
    func makeToast(msg: String) {
        self.view?.makeToast(msg, duration: 2, position: .bottom, title: nil, image: nil, style: .init()) { (success) in
        }
    }
    
   
    func getCommentsFromServer(_ completion : (() -> Void)? = nil) {
        currentCommentPage += 1
        ShadhinCore.instance.api.getCommentsBy(
            podcastType,
            currentEpisode,
            currentCommentPage,
            podcastShowCode) {
                _data in
                guard let data = _data else {return}
                if data.data.count > 0{
                    self.updateComments(data: data)
                }else{
                    self.currentCommentPage -= 1
                }
                LoadingIndicator.stopAnimation()
                completion?()
            }
    }
    
    
    private func updateFavouriteCommentServer(_ index: IndexPath, _ completion: (() -> Void)? = nil) {
        guard index.row < userComments?.data.count ?? 0,          // ✅ was: index.row - 1
              let commentID = userComments?.data[index.row].commentID,
              let commentBool = userComments?.data[index.row].commentFavorite else {
            return
        }

        ShadhinCore.instance.api.toggleFavoriteComment(podcastType, commentID) { success in
            guard index.row < self.userComments?.data.count ?? 0, success else { return }
            self.userComments?.data[index.row].commentFavorite = !commentBool
            if self.userComments?.data[index.row].commentFavorite == true {
                self.userComments?.data[index.row].totalCommentFavorite += 1
            } else {
                self.userComments?.data[index.row].totalCommentFavorite -= 1
            }
            self.tableView.reloadRows(at: [index], with: .automatic)
            completion?()
        }
    }

    private func updateLikeCommentServer(_ index: IndexPath, _ completion: (() -> Void)? = nil) {
        guard index.row < userComments?.data.count ?? 0,
              let commentID = userComments?.data[index.row].commentID,
              let likeBool = userComments?.data[index.row].commentLike,
              !likeBool else {
            return
        }

        ShadhinCore.instance.api.likeComment(podcastType, commentID) { success in
            guard success, index.row < self.userComments?.data.count ?? 0 else { return }
            self.userComments?.data[index.row].commentLike = !likeBool
            self.tableView.reloadRows(at: [index], with: .automatic)
            completion?()
        }
    }
    
/*
    private func updateFavouriteCommentServer(_ index : IndexPath, _ completion : (() -> Void)? = nil){
        guard index.row - 1 < userComments?.data.count ?? 0,
              let commentID = userComments?.data[index.row - 1].commentID,
              let commentBool = userComments?.data[index.row - 1].commentFavorite else{
            return
        }
        
        ShadhinCore.instance.api.toggleFavoriteComment(
            podcastType,
            commentID) { success in
                guard index.row - 1 < self.userComments?.data.count ?? 0, success else {return}
                self.userComments?.data[index.row - 1].commentFavorite = !commentBool
                if (self.userComments?.data[index.row - 1].commentFavorite)!{
                    self.userComments?.data[index.row - 1].totalCommentFavorite += 1
                }else{
                    self.userComments?.data[index.row - 1].totalCommentFavorite -= 1
                }

                self.tableView.reloadRows(at: [index], with: .automatic)
                completion?()
            }
    }
    
    private func updateLikeCommentServer(_ index : IndexPath,  _ completion : (() -> Void)? = nil){
        guard index.row - 1 < userComments?.data.count ?? 0,
              let commentID = userComments?.data[index.row - 1].commentID,
              let likeBool = userComments?.data[index.row - 1].commentLike,
              !likeBool else{
            return
        }
        ShadhinCore.instance.api.likeComment(
            podcastType,
            commentID) { success in
                guard success, index.row - 1 < self.userComments?.data.count ?? 0 else {return}
                self.userComments?.data[index.row - 1].commentLike = !likeBool
                self.tableView.reloadRows(at: [index], with: .automatic)
                completion?()
            }
    }
 */
    
    func getComments(_ completion: (() -> Void)? = nil) {
        pendingRequestWorkItem0?.cancel()
        let requestWorkItem = DispatchWorkItem(block: {self.getCommentsFromServer(completion)})
        pendingRequestWorkItem0 = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: requestWorkItem)
    }
    
    func updateFavouriteComment(_ index : IndexPath, _ completion : (() -> Void)? = nil){
        pendingRequestWorkItem1?.cancel()
        let requestWorkItem = DispatchWorkItem(block: {self.updateFavouriteCommentServer(index, completion)})
        pendingRequestWorkItem1 = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: requestWorkItem)
    }
    
    func updateLikeComment(_ index : IndexPath,  _ completion : (() -> Void)? = nil){
        pendingRequestWorkItem2?.cancel()
        let requestWorkItem = DispatchWorkItem(block: {self.updateLikeCommentServer(index, completion)})
        pendingRequestWorkItem2 = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: requestWorkItem)
    }
}
