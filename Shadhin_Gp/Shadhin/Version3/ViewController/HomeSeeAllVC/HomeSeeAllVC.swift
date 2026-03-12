//
//  HomeSeeAllVC.swift
//  Shadhin
//
//  Created by MD Murad Hossain on 06/10/25.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class HomeSeeAllVC: UIViewController,NIBVCProtocol {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var coordinator : HomeCoordinator?
    weak var audioHomeCoordinator: AudioBookHomeCoordinator?
    var audioPatchContent : AudioPatchContent?
    var bookv3Contents:CommonContentProtocol?
    var streamingHistoryContent: StreamingHistoryData?
    var youMightData = [SimilerBooksContent]()
    var audioCatagorisData : [AudioBookCatagoriesContent] = []
    var authorDetailsAudioBookData = [AuthorDetailsDataClass]()

    var patch : HomeV3Patch?
    var isSimilerContent:Bool = false
    var isAudioPatchData:Bool = false
    var isAudioCatagoriesData:Bool = false
    var isStreamingHistoryData: Bool = false
    var isAuthorDetailsAudioBook = false
    var isBookCatagorisv3 = false
    var audioHomePatch:AudioPatchHome?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(SquareV3Cell.nib, forCellWithReuseIdentifier: SquareV3Cell.identifier)
        collectionView.register(BookSubCell.nib, forCellWithReuseIdentifier: BookSubCell.identifier)
        collectionView.register(ContinueListeningEffectViewCell.nib, forCellWithReuseIdentifier: ContinueListeningEffectViewCell.identifier)
        collectionView.contentInset = .init(top: 8, left: 16, bottom: 8, right: 16)
        collectionView.dataSource = self
        collectionView.delegate = self
        titleLabel.text = audioPatchContent?.titleEn
        titleLabel.text = bookv3Contents?.title
        if let contentId = audioPatchContent?.contentID {
            let categoryId = String(contentId) // Convert Int? to String
            getAudioBookCatagoriesContent(catagoryId: categoryId)
        }
        if let contentId = bookv3Contents?.contentID {
            let categoryId = String(contentId) // Convert Int? to String
            getAudioBookCatagoriesContent(catagoryId: categoryId)
        }
    }
    
    func getAudioBookCatagoriesContent(catagoryId:String) {
        self.view.lock()
        ShadhinCore.instance.api.getAudioBooksCatagories(catagoryId:catagoryId) {[weak self] responseModel in
            self?.view.unlock()
            guard let self = self else {return}
            switch responseModel {
            case .success(let success):
                if let contents = success.data?.contents {
                    self.audioCatagorisData = contents
                       self.collectionView.reloadData()
                   } else {
                       print("No contents available")
                   }
            case .failure(let failure):
                print("Error Response: \(failure.localizedDescription)")
                
            }
        }
    }
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.coordinator?.pop()
        audioHomeCoordinator?.pop()
    }
}
extension HomeSeeAllVC : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isAudioPatchData {
            return audioHomePatch?.contents.count ?? 0
        } else if isBookCatagorisv3 {
         return audioCatagorisData.count
        }
        else if isAudioCatagoriesData {
            return audioCatagorisData.count
        } else if isStreamingHistoryData {
            return streamingHistoryContent?.contents.count ?? 0
        } else if isSimilerContent {
            return youMightData.count
        } else if isAuthorDetailsAudioBook {
            return authorDetailsAudioBookData[section].contents.count
        }
        return patch?.contents.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isAudioPatchData {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookSubCell.identifier, for: indexPath) as? BookSubCell , let audioObj = audioHomePatch?.contents[indexPath.row] else{
                fatalError()
            }
            self.titleLabel.text = "\(audioHomePatch?.patch.title ?? "")"
            cell.bindData(content: audioObj)
            cell.bindDataRecomnmendedBooks(content: audioObj)
            cell.bindDataArtAndEntertainment(content: audioObj)
            return cell
        } else if isBookCatagorisv3 {
            let catagoryObj = audioCatagorisData[indexPath.row]
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookSubCell.identifier, for: indexPath) as? BookSubCell else{
                fatalError()
            }
            cell.bindAudioCatagoriesData(content: catagoryObj)
            return cell
        }
        else if isAudioCatagoriesData {
            let catagoryObj = audioCatagorisData[indexPath.row]
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookSubCell.identifier, for: indexPath) as? BookSubCell else{
                fatalError()
            }
            cell.bindAudioCatagoriesData(content: catagoryObj)
            return cell
        } else if isStreamingHistoryData {
            let streamingObj = streamingHistoryContent?.contents[indexPath.row]
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContinueListeningEffectViewCell.identifier, for: indexPath) as? ContinueListeningEffectViewCell else {
                fatalError()
            }
            self.titleLabel.text = "Continue Listening"
            if let streamingObj {
                cell.bindStreamingData(content:streamingObj)
            }
            return cell
        } else if isSimilerContent {
            let similerObj = youMightData[indexPath.item]
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookSubCell.identifier, for: indexPath) as? BookSubCell else {
                fatalError()
            }
            self.titleLabel.text = "You Might Like"
            cell.bindDataSimileData(content:similerObj)
            return cell
        } else if isAuthorDetailsAudioBook {
            // let authorDetailsObj = authorDetailsAudioBookData[indexPath.item]
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookSubCell.identifier, for: indexPath) as? BookSubCell else {
                fatalError()
            }
            self.titleLabel.text = "Latest Audiobook"
            let authorDetailsBookData  = authorDetailsAudioBookData.first?.contents[indexPath.item]
            if let authorDetailsBookData {
                cell.bindAuthorDetailsAudioBookData(content:authorDetailsBookData)
            }
            return cell
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SquareV3Cell.identifier, for: indexPath) as? SquareV3Cell,let obj = patch?.contents[indexPath.row] else{
            fatalError()
        }
        cell.subtitleLabel.isHidden = true
        cell.bind(with: obj)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isAudioPatchData {
            guard let obj = audioHomePatch?.contents[indexPath.row] else {fatalError()}
            audioHomeCoordinator?.audioBookrouteToContent(content: obj)
        } else if isAudioCatagoriesData {
            let content = audioCatagorisData[indexPath.row]
            let vc  = AudioBookDetailsVC()
            vc.selectedTrackID = String(content.contentId)
            vc.episodeId = String(content.contentId)
            vc.artistId = String(content.audioBook?.authors.first?.id ?? 0)
            navigationController?.pushViewController(vc, animated: false)
        } else if isStreamingHistoryData {
            let content = streamingHistoryContent?.contents[indexPath.row]
            let vc  = AudioBookDetailsVC()
            vc.artistId = String(content?.audioBook.authors.first?.id ?? 0)
            if let contentId = content?.contentId {
                vc.episodeId = String(contentId)
                vc.selectedTrackID = String(contentId)
            } else {
                print("contentId is nil")
            }
            navigationController?.pushViewController(vc, animated: false)
        } else if isSimilerContent {
            let content = youMightData[indexPath.row]
            let vc  = AudioBookDetailsVC()
            vc.episodeId = String(content.contentId)
            vc.selectedTrackID = String(content.contentId)
            vc.artistId = String(content.contentId)
            navigationController?.pushViewController(vc, animated: false)
        } else if isAuthorDetailsAudioBook {
            let content = authorDetailsAudioBookData.last?.contents
            let vc  = AudioBookDetailsVC()
            let contentId = content?[indexPath.row].contentId

            if let contentId {
                vc.episodeId = String(contentId)
                vc.artistId = String(contentId)
                vc.selectedTrackID = String(contentId)
            }
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            if let patch = patch, indexPath.row < patch.contents.count {
                let obj = patch.contents[indexPath.row]
                coordinator?.routeToContent(content: obj)
            } else {
                print("Error: patch or contents is nil, or indexPath out of range")
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isAudioPatchData {
            return BookSubCell.sizeSeeAll
        } else if isAudioCatagoriesData {
            return BookSubCell.sizeSeeAll
        } else if isSimilerContent {
            return BookSubCell.sizeSeeAll
        }
        else if isStreamingHistoryData {
            return CGSize(width: SCREEN_WIDTH - 16 , height: SCREEN_WIDTH / (328.0 / 180.0))
        } else if isAuthorDetailsAudioBook {
            return BookSubCell.sizeSeeAll
        }
        else {
            let w : CGFloat = floor((UIScreen.main.bounds.width - 50) / 3)
            let r = SquareV3Cell.sizeForLatestRelease.height / SquareV3Cell.sizeForLatestRelease.width
            let h : CGFloat = floor(w * r)
            return .init(width: w, height: h)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

