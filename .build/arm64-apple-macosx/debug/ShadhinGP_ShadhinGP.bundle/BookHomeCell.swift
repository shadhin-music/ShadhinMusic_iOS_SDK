//
//  BookHomeCell.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 6/6/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class BookHomeCell: UICollectionViewCell {
    var isSimilerBookData: Bool = false
    var isAudioPatchData = false
    var isRecommned = false
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var headerLebel: UILabel!
    var isActiveBookData:Bool = false
  //  var navigationController: UINavigationController?
    var dataSourceV3 = [HomeV3Content]()
    var dataSource = [CommonContentProtocol]()
    var audioBookHome = [AudioPatchContent]()
    var similerBookData = [SimilerBooksContent]()
    var authorDetailsAudioBookData = [AuthorDetailsDataClass]()
    var onSeeAll: (()->Void)?
    unowned var vc: HomeVCv3?
    unowned var seeAllVC:HomeSeeAllVC?
    unowned var audioVC: AudioBookHomeVC?
    var onItemClick : (AudioPatchContent)-> Void = {_ in}
    var onItemClickForYouMightLike:(SimilerBooksContent) -> Void = {_ in }
    private var content: CommonContentProtocol?
    var onPlaySong : ((CommonContentProtocol)-> Bool)?
    var selectedTrack: CommonContentProtocol?
    let audioPlayer = AudioPlayer.shared
    var seekToInterval: TimeInterval = 0 // Default value
    var seektoCurrentCursor = 0

    var isFromDetails = false
    var isAuthorDetailsAudioBook = false
    var isSeeAllActive = false
    var isActiveAuthotDetails = false


    deinit {
        NotificationCenter.default.removeObserver(self, name: .audioPlayNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .audioPauseNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .audioBufferingNotification, object: nil)
    }

    static var identifier: String {
        String(describing: self)
    }

    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }

    static var size: CGSize {
        let aspectRatio = 360.0/344.0
        let width = SCREEN_WIDTH - 32
        let height = width/aspectRatio
        return CGSize(width: width, height: height)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.setupCells()
    }

    @IBAction func seeAllClicked(_ sender: Any) {
        if let onSeeAll = onSeeAll {
            seeAllVC?.isAudioPatchData = true
            if isSeeAllActive {
                onSeeAll()
            }
        } else if isActiveAuthotDetails {
            seeAllAction()
        }
    }

    private func seeAllAction() {
        let vc = HomeSeeAllVC.instantiateNib()
        vc.isAuthorDetailsAudioBook = true
        vc.authorDetailsAudioBookData = authorDetailsAudioBookData
        self.navigationController()?.pushViewController(vc, animated: true)
    }

    func bind(title: String, with data : HomeV3Patch) {
        self.isRecommned = false
        self.isActiveBookData = true
        self.dataSource = data.contents
        headerLebel.text  = title
        seeAllButton.isHidden = data.patch.isSeeAllActive
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    func bindRecommended(title: String, with data : HomeV3Patch) {
        self.isActiveBookData = false
        self.isRecommned = true
        self.dataSourceV3 = data.contents
        print(dataSourceV3)
        headerLebel.text  = title
        seeAllButton.isHidden = true
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    func bindAudioHome(with patch: AudioPatchHome) {
        self.isActiveBookData = false
        self.isRecommned = false
        self.audioBookHome = patch.contents
        self.seeAllButton.isHidden = patch.patch.isSeeAllActive
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    func bindFromDetails(books: SimilerBooksContent) {
        self.isActiveBookData = false
        self.isRecommned = false
        self.headerLebel.text = "AudioBooks"
        self.seeAllButton.isHidden = false
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    func setupCells() {
        self.collectionView.register(BookSubCell.nib, forCellWithReuseIdentifier: BookSubCell.identifier)
    }
}

extension BookHomeCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSimilerBookData {
            return similerBookData.count
        } else if isAuthorDetailsAudioBook {
            return authorDetailsAudioBookData[section].contents.count
        } else if isActiveBookData {
            return dataSource.count
        } else if isRecommned {
            return dataSourceV3.count
        }
        return audioBookHome.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookSubCell.identifier, for: indexPath) as? BookSubCell else{
            fatalError("more menu cell load failed")
        }
        if isSimilerBookData {
            let similerBook = similerBookData[indexPath.item]
            cell.bindDataSimileData(content: similerBook)
        } else if isAuthorDetailsAudioBook {
            let authorDetailsBookData  = authorDetailsAudioBookData.first?.contents[indexPath.item]
            if let authorDetailsBookData {
                cell.bindAuthorDetailsAudioBookData(content: authorDetailsBookData)
            }
        } else if isActiveBookData {
            let content = dataSource[indexPath.item]
            cell.getAudioBookReviews(episodeId: content.contentID ?? "")
            cell.getAudioBookDetailsData(episodeId: content.contentID ?? "", indexPath: indexPath)
            cell.bindDataHomv3AudioBook(content: content)
        } else if isRecommned {
            let content = dataSourceV3[indexPath.item]
            cell.getAudioBookReviews(episodeId: content.contentID ?? "")
            cell.getAudioBookDetailsData(episodeId: content.contentID ?? "", indexPath: indexPath)
            cell.bindDataHomv3Recommended(contentV3: dataSourceV3[indexPath.item])
        }
        else {
            if audioBookHome.indices.contains(indexPath.item){
                cell.bindData(content: audioBookHome[indexPath.item])
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isSimilerBookData {
            return BookSubCell.size
        } else if isAuthorDetailsAudioBook {
            return BookSubCell.size
        } else if isRecommned {
            return BookSubCell.size
        }
        else {
            return BookSubCell.size
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isAudioPatchData {
            if indexPath.item < audioBookHome.count {
                onItemClick(audioBookHome[indexPath.item])
            } else {
                print("Index out of range: \(indexPath.item), array count: \(audioBookHome.count)")
            }
        }
        else if isActiveBookData {
            let content = dataSource[indexPath.item]
            print(dataSource[indexPath.item])
            let vc  = AudioBookDetailsVC()
            let contentId = content.contentID
            if let contentId {
                vc.episodeId = String(contentId)
                vc.artistId = String(contentId)
                vc.selectedTrackID = String(contentId)
            }
            self.navigationController()?.pushViewController(vc, animated: true)

        } else if isRecommned {

            let content3 = dataSourceV3[indexPath.row]
            if (content3.track != nil) {
                if ConnectionManager.shared.isNetworkAvailable {
                    self.parentViewController?.openMusicPlayerV3(musicData: self.dataSourceV3, songIndex: indexPath.row, isRadio: false, rootModel: content3)
                }

            } else {

                let vc  = AudioBookDetailsVC()
                let contentId = content3.contentID
                if let contentId {
                    vc.episodeId = String(contentId)
                    vc.artistId = String(contentId)
                    vc.selectedTrackID = String(contentId)
                }
                self.navigationController()?.pushViewController(vc, animated: true)
            }

        } else {
            let content = authorDetailsAudioBookData.last?.contents
            let vc  = AudioBookDetailsVC()
            let contentId = content?[indexPath.row].contentId

            if let contentId {
                vc.episodeId = String(contentId)
                vc.artistId = String(contentId)
                vc.selectedTrackID = String(contentId)
            }
            self.navigationController()?.pushViewController(vc, animated: true)
        }
    }
}


extension BookHomeCell {

    func playPauseHandler() {
        switch audioPlayer.state {
        case .buffering:
            break
        case .playing:
            if doEpisodesContainCurrentAudio() {
                audioPlayer.pause()
            } else {
                startAudioFrom(index: 0, startAudioFrom: 0)
            }
        case .paused:
            if doEpisodesContainCurrentAudio() {
                audioPlayer.resume()
            } else {
                startAudioFrom(index: 0, startAudioFrom: seektoCurrentCursor)
            }
        case .stopped, .failed(_):
            /// This state does not happen
            if doEpisodesContainCurrentAudio() {
                // do nothing
            } else {
                startAudioFrom(index:0, startAudioFrom:seektoCurrentCursor)
            }

        case .waitingForConnection:
            break
        }
    }

    func doEpisodesContainCurrentAudio() -> Bool {
        if let currentAuioContentId = audioPlayer.currentItem?.contentId {
            let currentlyPlayingEpisode = vc?.episodes.first(where: { audioBookContent in
                if let episodeContentId = audioBookContent.contentId  {
                    return String(episodeContentId) == currentAuioContentId
                }
                return false
            })

            if currentlyPlayingEpisode != nil {
                return true
            }
        }

        return false
    }

    func startAudioFrom(index: Int,startAudioFrom:Int) {
        seekToInterval = TimeInterval(startAudioFrom)
        print("Set seekToInterval: \(seekToInterval)") // Debugging
        if doEpisodesContainCurrentAudio() {
            // seek to
            audioPlayer.playItem(at: index)
        } else {
            // play with the list
//            if var episodeContents = vc?.episodes.compactMap({$0.toCommonContent()}) {
//                for (index,episodeContent) in episodeContents.enumerated() {
//                    episodeContents[index].artist = authors
//                }
//                self.vc?.openMusicPlayerV3(musicData: episodeContents, songIndex: index, isRadio: false)
//            }
        }
    }


    func removeSeconds(_ time: String)->String {
        if let index = time.firstIndex(of: "m") {
            return String(time.prefix(upTo: time.index(after: index)))
        }
        return time
    }

    func addAudioObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioPlayNotification(_:)), name: .audioPlayNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioPauseNotification(_:)), name: .audioPauseNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioBufferingNotification(_:)), name: .audioBufferingNotification, object: nil)
    }

    @objc func handleAudioPlayNotification(_ notification: Notification) {
        if let contentId = notification.userInfo?["contentId"] as? String {
            print("Audio play notification received with contentId: \(contentId)")

        }
    }

    @objc func handleAudioPauseNotification(_ notification: Notification) {
        if let contentId = notification.userInfo?["contentId"] as? String {
            print("Audio pause notification received with contentId: \(contentId)")
        }
    }

    @objc func handleAudioBufferingNotification(_ notification: Notification) {
        if let contentId = notification.userInfo?["contentId"] as? String {
            print("Audio pause notification received with contentId: \(contentId)")
        }
    }
}
