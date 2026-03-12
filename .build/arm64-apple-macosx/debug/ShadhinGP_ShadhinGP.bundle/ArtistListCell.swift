//
//  ArtistAlbumListCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 8/4/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit



class ArtistListCell: UITableViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var height: CGFloat {
        return 165
    }
    
    public typealias SelectArtistAlbumList = (_ content: CommonContentProtocol)->()
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    var artistList : [CommonContent_V0]!
    var indexToSkip : Int = 0
    var completion : ((Int) -> ())!
    
    override func awakeFromNib() {
        collectionView.register(UINib(nibName: "RadioCell", bundle: Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "RadioCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func configureCell(content: [CommonContent_V0], index : Int, selection : @escaping (Int) -> () ) {
        artistList = content
        indexToSkip = index
        completion = selection
        collectionView.reloadData()
    }
    
    
    
    func didSelectAlbumList(completion: @escaping () -> (Int)) {
        
    }
}

extension ArtistListCell: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artistList.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var index = indexPath.item
        if index >= indexToSkip{
            index += 1
        }
       // guard let container = ShadhinCore.instance.containers[artistList[index]] else {return .init()}
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RadioCell", for: indexPath) as! RadioCell
      
        cell.configureCell(model: artistList[index])
        //cell.configureCell(container: container)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var index = indexPath.item
        if index >= indexToSkip{
            index += 1
        }
        completion(index)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 138, height: 165)
    }
}
