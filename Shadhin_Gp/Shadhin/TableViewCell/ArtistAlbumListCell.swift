//
//  ArtistAlbumListCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 8/4/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit



class ArtistAlbumListCell: UITableViewCell {
    
    public typealias SelectArtistAlbumList = ((_ content: CommonContentProtocol)->())
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var albumModels = [CommonContentProtocol]()
    var selectAlbumList: ((_ content: CommonContentProtocol)->())?
    var isPlaylistType = false
    var didSelectArtist : ((Int)->())?
    var currentId : String = ""
    
    override func awakeFromNib() {
        collectionView.register(UINib(nibName: "LatestAlbumCell", bundle:Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "LatestAlbumCell")
        collectionView.register(UINib(nibName: "RadioCell", bundle:Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "RadioCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    
    func configureCell(contentID: String) {
        if contentID != currentId{
            getDataFromServer(contentID: contentID)
            currentId = contentID
        }
    }
    
    func configureCell( data : [CommonContentProtocol],_ isPlaylistType: Bool = true ){
        self.isPlaylistType = isPlaylistType
        self.albumModels = data
        self.collectionView.reloadData()
    }
    
    func getDataFromServer(contentID: String) {
        ShadhinCore.instance.api.getSongsOrAblumsBy(
            artistId: contentID,
            type: .album) {
                (models, err) in
                if err != nil {
                    Log.error(err?.localizedDescription ?? "")
                }else {
                    self.albumModels = models?.data ?? []
                    self.collectionView.reloadData()
                }
            }
    }
    
    func getDataFromServer(playlistId: String){
        ShadhinCore.instance.api.getArtistsInPlaylistBy(playListID: playlistId) { (data) in
            guard let data = data else {return}
            self.albumModels = data.data
            self.collectionView.reloadData()
        }
    }
    
    func didSelectAlbumList(completion: @escaping SelectArtistAlbumList) {
        selectAlbumList = completion
    }
    
    
}

extension ArtistAlbumListCell: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isPlaylistType{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RadioCell", for: indexPath) as! RadioCell
            cell.configureCell(model: albumModels[indexPath.item])
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LatestAlbumCell", for: indexPath) as! LatestAlbumCell
        cell.configureCell(model: albumModels[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectAlbumList?(albumModels[indexPath.row])
        didSelectArtist?(indexPath.row)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isPlaylistType{
            return CGSize(width: 138, height: 165)
        }
        return CGSize(width: 138, height: 186)
    }
}
