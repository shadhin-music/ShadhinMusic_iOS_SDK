//
//  AllSearchCell.swift
//  Shadhin
//
//  Created by Maruf on 8/2/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class AllSearchCell: UICollectionViewCell {
    var selectedSearchItemIndex = 0
    var isFirstTime = true
    @IBOutlet weak var collectionView: UICollectionView!
    var itemsArray = ["All", "Artists", "Albums", "Tracks", "Playlists", "Podcasts", "Videos"]
    weak var vc: SearchMainV3!
    var onItemClicked:((_ itemName: String)->Void)?
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(SearchSubCell.nib, forCellWithReuseIdentifier: SearchSubCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.selectItem(at: IndexPath(row: selectedSearchItemIndex, section: 0), animated: true, scrollPosition: .left)
    }
    
    func reset() {
        // Perform any necessary reset actions here
        selectedSearchItemIndex = 0
        isFirstTime = true
        collectionView.reloadData() // For example, reload data to clear the collection view
        collectionView.selectItem(at: IndexPath(row: selectedSearchItemIndex, section: 0), animated: true, scrollPosition: .left)
    }
}

extension AllSearchCell : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchSubCell.identifier, for: indexPath) as? SearchSubCell else{
            fatalError()
        }
        cell.searchTitle.text = itemsArray[indexPath.item]
        cell.layer.cornerRadius = 15
        if traitCollection.userInterfaceStyle == .dark {
            if indexPath.item == selectedSearchItemIndex{
                cell.searchTitle.textColor = UIColor.white
                cell.layer.backgroundColor = UIColor.tintColor.cgColor
                cell.layer.borderWidth = 0
                cell.layer.borderColor = UIColor.clear.cgColor
            }
            else {
                cell.searchTitle.textColor = UIColor.gray
                cell.layer.borderColor = UIColor.gray.cgColor
                cell.layer.backgroundColor = UIColor.black.cgColor
                cell.layer.borderWidth = 1
                cell.layer.borderColor = UIColor.lightGray.cgColor
            }
        } else {
            if indexPath.item == selectedSearchItemIndex{
                cell.searchTitle.textColor = UIColor.white
                cell.layer.backgroundColor = UIColor.tintColor.cgColor
                cell.layer.borderWidth = 0
                cell.layer.borderColor = UIColor.clear.cgColor
            }
            else {
                cell.layer.borderWidth = 1
                cell.searchTitle.textColor = UIColor.gray
                cell.layer.borderColor = UIColor.gray.cgColor
                cell.layer.backgroundColor = UIColor.white.cgColor
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: IndexPath(row: selectedSearchItemIndex, section: 0), animated: true)
        collectionView.selectItem(at: IndexPath(row: indexPath.row, section: 0), animated: true, scrollPosition: .left)
        selectedSearchItemIndex = indexPath.item
        vc.Genreadapter.handleSearchTabClicked((itemsArray[indexPath.item]))
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemsArray[indexPath.row].size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)]).width + 25, height: 33)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

extension AllSearchCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
         super.traitCollectionDidChange(previousTraitCollection)
         // Detect interface style change and update background color
     }
}


