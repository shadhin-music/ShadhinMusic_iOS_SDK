//
//  ArtistsInPlaylistTC.swift
//  Shadhin
//
//  Created by Gakk Alpha on 7/28/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class ArtistsInPlaylistTC: UITableViewCell {

    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size: CGFloat {
        return 200
    }
    

    @IBOutlet weak var collectionView: UICollectionView!
    var favArtists : [CommonContentProtocol] = []
    var artistsInPlaylist : [CommonContentProtocol] = []
    var didSelectArtist : ((_ index : Int)->Void)?
    
    
    override func awakeFromNib() {
        collectionView.register(ArtistsInPlaylistCC.nib, forCellWithReuseIdentifier: ArtistsInPlaylistCC.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        getFavArtists()
    }
    
    func getFavArtists(){
        self.contentView.lock()
        ShadhinCore.instance.api.getAllFavoriteByType(type: .artist) {
            data, error in
            self.contentView.unlock()
            guard let data = data else {return}
            self.favArtists = data
            self.collectionView.reloadData()
        }
    }
    
    func setData(_ artistsInPlaylist : [CommonContentProtocol]){
        guard self.artistsInPlaylist.count != artistsInPlaylist.count else {return}
        self.artistsInPlaylist = artistsInPlaylist
        self.collectionView.reloadData()
    }
    
    func followOrUnfollow(_ index : Int){
        let option : UserActionType = artistsInPlaylist[index].fav == "1" ? .remove : .add
        self.followUnfollowArtist(index, option)
        if let followStr = artistsInPlaylist[index].followers,
           let followInt = Int(followStr){
            artistsInPlaylist[index].followers = "\(option == .remove ? followInt-1 : followInt+1)"
        }
    }
    
    func followUnfollowArtist(
        _ index : Int,
        _ followType : UserActionType){
            self.contentView.lock()
            guard index < artistsInPlaylist.count else {return}
            let artistData = artistsInPlaylist[index]
            guard let contentId = artistData.contentID else {return}
            ShadhinCore.instance.api.addOrRemoveFromFavorite(
                content: artistData,
                action: followType) {
                    error in
                    if followType == .remove{
                        self.favArtists.removeAll(where: {$0.contentID == contentId})
                    }else{
                        self.favArtists.append(artistData)
                    }
                    self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
                    self.contentView.unlock()
                }
        }
    
}

extension ArtistsInPlaylistTC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artistsInPlaylist.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtistsInPlaylistCC.identifier, for: indexPath) as! ArtistsInPlaylistCC
        let imgUrl = artistsInPlaylist[indexPath.row].image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        cell.artistImage.kf.indicatorType = .activity
        cell.artistImage.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_artist",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        cell.artistName.text = artistsInPlaylist[indexPath.row].title
        let followers : String = artistsInPlaylist[indexPath.row].followers ?? "0"
        cell.artistFollowCount.text = "\(followers)"
        
        if let artistId = artistsInPlaylist[indexPath.row].contentID{
            if favArtists.contains(where: {$0.contentID == artistId}){
                cell.followBtn.setTitle("Following", for: .normal)
                cell.followBtn.borderColor = UIColor.secondaryLabelColor()
                cell.followBtn.setTitleColor(UIColor.secondaryLabelColor(), for: .normal)
                cell.followBtn.backgroundColor = UIColor.clear
                artistsInPlaylist[indexPath.row].fav = "1"
            }else{
                cell.followBtn.setTitle("Follow", for: .normal)
                cell.followBtn.borderColor = UIColor.init(rgb: 0x00B0FF)
                cell.followBtn.setTitleColor(UIColor.white, for: .normal)
                cell.followBtn.backgroundColor = UIColor.init(rgb: 0x00B0FF)
                artistsInPlaylist[indexPath.row].fav = "0"
            }
        }else{
            cell.followBtn.setTitle("Follow", for: .normal)
            cell.followBtn.borderColor = UIColor.init(rgb: 0x00B0FF)
            cell.followBtn.setTitleColor(UIColor.white, for: .normal)
            cell.followBtn.backgroundColor = UIColor.init(rgb: 0x00B0FF)
        }
        cell.followBtn.setClickListener {
            self.followOrUnfollow(indexPath.row)
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //print("Artist index selected \(indexPath.row)")
        didSelectArtist?(indexPath.row)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        ArtistsInPlaylistCC.size
    }
}
