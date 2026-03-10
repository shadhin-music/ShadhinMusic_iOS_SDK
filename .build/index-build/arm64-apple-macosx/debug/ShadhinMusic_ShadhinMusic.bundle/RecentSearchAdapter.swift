//
//  RecentSearchAdapter.swift
//  Shadhin
//
//  Created by Maruf on 7/2/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import Foundation

class RecentSearchAdapter: NSObject  {
    var recentSearchHistories = [RecentSearchHistoriesContent]()
    var vc: SearchMainV3
    init(vc : SearchMainV3) {
        self.vc = vc
        super.init()
        getRecentHistories()
    }
    
    func getRecentHistories() {
        ShadhinCore.instance.api.getSearchHistories_V2(userCode: ShadhinCore.instance.defaults.userIdentity) { [weak self] responseModel in
            switch responseModel {
            case .success(let data):
                self?.recentSearchHistories = data.contents
                self?.vc.collectionView.reloadData()
            case .failure(let error):
                if error.localizedDescription.contains("Empty response"){
                    self?.recentSearchHistories.removeAll()
                    self?.vc.collectionView.reloadData()
                }
            }
        }
    }
}



extension RecentSearchAdapter : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recentSearchHistories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentSearchCollectionViewCell.identifier, for: indexPath) as? RecentSearchCollectionViewCell else{
            fatalError()
        }
        cell.refreshHistories = getRecentHistories
        cell.bindData(data: recentSearchHistories[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (SCREEN_WIDTH - (16*2)-8)
        return CGSize(width: width,height:56)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:HeaderViewCV.identifier, for: indexPath) as! HeaderViewCV
       switch kind {
       case UICollectionView.elementKindSectionHeader:
           headerView.headerTitle.text = "Recent Searches"
           
                return headerView
         default:
                assert(false, "Unexpected element kind")
        }
        return headerView
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height:HeaderViewCV.HEIGHT)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        vc.coordinator?.routeToContent(content: recentSearchHistories[indexPath.item].toCommonContent())
    }
    
}
