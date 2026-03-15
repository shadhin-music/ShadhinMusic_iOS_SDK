//
//  AudioBookAdapter.swift
//  Shadhin
//
//  Created by Maruf on 2/10/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

enum AudioBookHomePatchType : Int{
    case CONTINUE_LISTENING_BOOK           = 23
    case AUDIOBOOK_CATAGORIES              = 22
    case RECOMANDED_BOOKS                  = 20
    case LATEST_AUDIOBOOKS                 = 19
    case ART_AND_ENTERTAINMENT             = 21
    case UNKNOWN                           = -1
    
}

protocol AudioBookHomeAdapterProtocol : NSObjectProtocol{
    // Read-write property
    var parentCollectionView: UICollectionView? {get set}
    var homeAdapter: AudioBookHomeAdapter? { get set }
    var homeVM: AudioBookHomeVM? {get set}
    func loadMorePatchs()
    func onItemClicked(patch: AudioPatchHome, content: AudioPatchContent)
    func getNavController() -> UINavigationController
    func seeAllClick(patch : AudioPatchHome)
    func reloadView(indexPath: IndexPath)
    func refreshHome()
}

class AudioBookHomeAdapter:NSObject {
    private weak var delegate : AudioBookHomeAdapterProtocol?
    var dataSource : [AudioPatchHome] = []
    weak var homeSeeAllVC: HomeSeeAllVC!
    weak var vc:AudioBookHomeVC!
    init(delegate: AudioBookHomeAdapterProtocol) {
        self.delegate = delegate
        super.init()
    }
    func addPatches(array: [AudioPatchHome]){
        dataSource.append(contentsOf: array)
        dataSource = dataSource.sorted(by: {$0.patch.sort < $1.patch.sort})
    }
      func reset(){
        dataSource.removeAll()
    }
}

extension AudioBookHomeAdapter:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       // dataSource[index].getDesign()
        let patchType = dataSource[indexPath.row].patch.getDesignAudioBook()
        let obj = dataSource[indexPath.row]
        switch patchType {
            
        case .CONTINUE_LISTENING_BOOK:
            if ShadhinCore.instance.isUserLoggedIn &&  ShadhinCore.instance.isUserPro {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContinueListeningBookCell.identifier, for: indexPath) as? ContinueListeningBookCell else{
                    fatalError()
                }
                cell.bindAudioBookContinueListening(with: obj)
                if ShadhinCore.instance.isUserLoggedIn && ShadhinCore.instance.isUserPro {
                    cell.getStreamingHistoryContent()
                } else {
                    print("User is not logged in or not a Pro user.")
                }
                return cell
            } else {
                let emptyCell = UICollectionViewCell()
                emptyCell.isHidden = true
                return collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
            }
            
        case .AUDIOBOOK_CATAGORIES:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AudiobookCategoriesCell.identifier, for: indexPath) as? AudiobookCategoriesCell else{
                fatalError()
            }
//            let contentIDs = obj.contents.compactMap { $0.contentID }
//            contentIDs.forEach { contentID in
//                cell.getAudioBookCatagoriesContent(catagoryId: String(contentID))
//            }
            cell.bindAudioBookCatagories(with: obj)
            cell.onItemClick = {[weak self] item in
                guard let self = self else {return}
                self.delegate?.onItemClicked(patch: obj, content: item)
            }
            return cell
        case .RECOMANDED_BOOKS:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedBooksCell.identifier, for: indexPath) as? RecommendedBooksCell else{
                fatalError()
            }
            cell.bindAudioBookRecommended(with: obj)
            cell.onSeeAll = {[weak self] in
                guard let self = self else {return}
                self.delegate?.seeAllClick(patch: obj)
            }
            cell.onItemClick = {[weak self] item in
                guard let self = self else {return}
                self.delegate?.onItemClicked(patch: obj, content: item)
            }
            return cell
        case .LATEST_AUDIOBOOKS:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookHomeCell.identifier, for: indexPath) as? BookHomeCell else {
                fatalError()
            }
            cell.headerLebel.text = obj.patch.title
            cell.isSeeAllActive = true
            cell.isAudioPatchData  = true
            cell.bindAudioHome(with: obj)
            cell.onSeeAll = {[weak self] in
                guard let self = self else {return}
                self.delegate?.seeAllClick(patch: obj)
            }
            
            cell.onItemClick = {[weak self ] item in
                guard let self = self else {return}
                Log.info("\(item)")
                self.delegate?.onItemClicked(patch: obj, content: item)
            }
            return cell
        case .ART_AND_ENTERTAINMENT:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtsEntertainmentCell.identifier, for: indexPath) as? ArtsEntertainmentCell else{
                fatalError()
            }
            cell.bindAudioBookArtAndEntertainment(with: obj)
            cell.onSeeAll = {[weak self] in
                guard let self = self else {return}
                self.delegate?.seeAllClick(patch: obj)
            }
            cell.onItemClick = {[weak self] item in
                guard let self = self else {return}
                self.delegate?.onItemClicked(patch: obj, content: item)
            }
            return cell
        case .UNKNOWN:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let patchType = dataSource[indexPath.row].patch.getDesignAudioBook()
        switch patchType {
        case .CONTINUE_LISTENING_BOOK:
            if ShadhinCore.instance.isUserLoggedIn && ShadhinCore.instance.isUserPro {
                return ContinueListeningBookCell.size
            } else {
                return .zero
            }
        case .AUDIOBOOK_CATAGORIES:
            return AudiobookCategoriesCell.size
        case .RECOMANDED_BOOKS:
            return RecommendedBooksCell.size
        case .LATEST_AUDIOBOOKS:
            return BookHomeCell.size
        case .ART_AND_ENTERTAINMENT:
            return ArtsEntertainmentCell.size
        case .UNKNOWN:
            return .zero
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 8, left: 16, bottom: 10 , right: 0) // Insets for other sections
    }
}
