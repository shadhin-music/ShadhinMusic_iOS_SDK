//
//  DiscoverMusicDetailsVC.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/20/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class DiscoverMusicDetailsVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var artistSearchBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    
    var songDetails = [CommonContentProtocol]()
    var designName = ""
    var titleLblText = ""
    var selectedIndex: Int = 0
    var onEpisodeSelected: ((Int) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //view.backgroundColor = .customBGColor()
        
        collectionView.register(UINib(nibName: "PopularArtistCell", bundle: Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "PopularArtistCell")
        collectionView.register(UINib(nibName: "RadioCell", bundle: Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "RadioCell")
        
        if designName.lowercased() == "artist"{
            artistSearchBtn.isHidden = false
        }
        
        titleLbl.isHidden = titleLblText.isEmpty
        titleLbl.text = titleLblText
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func artistSearchTapped(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ArtistSearchVC") as! ArtistSearchVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - Collection View

extension DiscoverMusicDetailsVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songDetails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if designName == "Artist" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularArtistCell", for: indexPath) as! PopularArtistCell
            cell.configureCell(model: songDetails[indexPath.row])
            return cell
        }else if designName == "Radio"{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RadioCell", for: indexPath) as! RadioCell
            cell.configureCell(model: songDetails[indexPath.row])
            return cell
            
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverMusicDetailsCell", for: indexPath) as! DiscoverMusicDetailsCell
            cell.configureCell(model: songDetails[indexPath.row])
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if designName == "Radio" {
            ShadhinCore.instance.api.getAlbumOrPlaylistOrSingleDataById(ContentID: songDetails[indexPath.row].contentID ?? "", mediaType: .playlist) { (playlists, err,image) in
                guard let playlist = playlists else {return}
                self.openMusicPlayerV3(musicData: playlist, songIndex: indexPath.row, isRadio: true)
                
            }
        }
        let data = songDetails[indexPath.item]
        
        switch SMContentType.init(rawValue: data.contentType){
        case .artist:
            let vc1 = goArtistVC(content: data)
            self.navigationController?.pushViewController(vc1, animated: true)
        case .album:
            let vc2 = goAlbumVC(isFromThreeDotMenu: false, content: data)
            self.navigationController?.pushViewController(vc2, animated: true)
        case .song:
            let vc3 = goPlaylistVC(content: data)
            self.navigationController?.pushViewController(vc3, animated: true)
        case .podcast, .podcastVideo:
            let storyBoard = UIStoryboard(name: "PodCast", bundle: Bundle.ShadhinMusicSdk)
            if let tabVC = MainTabBar.shared,
               let tabs = tabVC.viewControllers,
               tabs.count > 2,
               let nav = tabs[2] as? UINavigationController,
               let contentId = Int(data.contentID ?? ""),
               let type = data.contentType,
               let podcastVC = storyBoard.instantiateViewController(withIdentifier: "PodcastVC") as? PodcastVC{
                
                podcastVC.podcastCode = type
                if designName.uppercased() == "PDPS"{
                    podcastVC.selectedEpisode = 0
                }else{
                    podcastVC.selectedEpisode = contentId
                }
                
                nav.pushViewController(podcastVC, animated: false)
                tabVC.selectedIndex = 2
            }
        case .video:
            self.openVideoPlayer(videoData: songDetails, index: indexPath.item)
        case .playlist:
            let vc3 = goPlaylistVC(content: data)
            self.navigationController?.pushViewController(vc3, animated: true)
        case .unknown, .subscription:
            Log.warning("Unknown content type \(data.contentType ?? "") not configured in view all")
        case .LK:
            break
        case .myPlayList:
            break
        case .audioBook:
            //TODO: - NOT SURE
            break
        case .link:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = UIScreen.main.bounds
        let cellDimension = (size.width / 2) - 15
        if designName == "Artist" {
            return CGSize(width: cellDimension, height: cellDimension + 20)
        }else if designName == "Radio" {
            return CGSize(width: cellDimension, height: cellDimension)
        }else {
            return CGSize(width: cellDimension, height: cellDimension + 42)
        }
    }
}
