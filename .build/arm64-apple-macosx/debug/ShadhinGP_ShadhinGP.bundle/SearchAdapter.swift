//
//  SearchAdapter.swift
//  Shadhin
//
//  Created by Maruf on 8/2/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit
import Foundation


class  SearchAdapter:NSObject {
    var allSearchData = [[SearchV2Content]]()
    var isAllSearch = false
    var vc: SearchMainV3
    init(vc : SearchMainV3) {
        self.vc = vc
        super.init()
      }
    
    func handleDataNotification(_ data:[String: Any], isAllSearch: Bool = false) {
        // Extract data from the notification
        
        if let connection = try? Reachability().connection, connection == .unavailable  {
            vc.noContentView.isHidden = false
            vc.couldNotContentLbl.text = "You are offline!"
            return
        }
        
        self.isAllSearch = isAllSearch
        
        if let value = data["data"] as? [[SearchV2Content]] {
            
            if value.count == 0 {
                allSearchData.removeAll()
                vc.noContentView.isHidden = false
            } else {
                if value.first?.count == 0 {
                    allSearchData.removeAll()
                    vc.noContentView.isHidden = false
                } else {
                    allSearchData = value
                    vc.noContentView.isHidden = true
                }
            }
            
            vc.collectionView.reloadData()
            
            vc.hideKeyboardWhenTappedAround()
        } else if let value = data["data"] as? Bool, value == true {
            vc.noContentView.isHidden = false
            allSearchData.removeAll()
            vc.collectionView.reloadData()
        }
        else if let value = data["data"] as? String {
            vc.noContentView.isHidden = false
            vc.couldNotContentLbl.text = "Could not find '\(value)'"
        }
        
    }
}

extension SearchAdapter : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if isAllSearch {
            if section == 0 {
                return 1
            } else {
                return allSearchData.first?.count ?? 0
            }
        }
        
        if section == 2, allSearchData[1].first?.resultType == SearchAllResultType.mostPopular.rawValue{
            return allSearchData[1].count
        } else if section == 1, allSearchData[0].first?.resultType == SearchAllResultType.tracks.rawValue {
            return allSearchData[0].count
        } else if section == 1, allSearchData[0].first?.resultType == SearchAllResultType.podcastStories.rawValue {
            return allSearchData[0].count
        } else if section == 1, allSearchData[0].first?.resultType == SearchAllResultType.artists.rawValue {
            return allSearchData[0].count
        } else if section == 1, allSearchData[0].first?.resultType == SearchAllResultType.album.rawValue {
            return allSearchData[0].count
        } else if section == 1, allSearchData[0].first?.resultType == SearchAllResultType.videos.rawValue {
            return allSearchData[0].count
        } else if section == 1, allSearchData[0].first?.resultType == SearchAllResultType.playlists.rawValue {
            return allSearchData[0].count
        } else {
            return 1
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return allSearchData.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllSearchCell.identifier, for: indexPath) as? AllSearchCell else{
                fatalError()
            }
            cell.vc = vc
            vc.allSearchCell = cell
            return cell
        } else if indexPath.section > 0 {
            
            let resultType:SearchAllResultType = .init(rawValue: allSearchData[indexPath.section - 1].first?.resultType ?? "") ?? .unknown
            
            if indexPath.section == 1 {
                
                if isAllSearch {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MostPopularSongCell.identifier, for: indexPath) as? MostPopularSongCell else{
                        fatalError()
                    }
                    
                    if let data  = allSearchData.first {
                        cell.dataBind(data: data[indexPath.item], index: String(indexPath.item+1), isAllSearch: true)
                    }
                    
                    return cell
                }
                
                if resultType == .album || resultType == .videos || resultType == .playlists {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCommonCollectionViewCell.identifier, for: indexPath) as? SearchCommonCollectionViewCell else{
                        fatalError()
                    }
                    if let data  = allSearchData.filter({$0.first?.resultType == resultType.rawValue}).first {
                        cell.bindData(data: data[indexPath.item], forAll: false)
                    }
                    
                    if resultType == .videos {
                        cell.playVideoIcon.isHidden = false
                    }
                    
                    return cell
                }
            }
            
            switch resultType {
            case .topResult:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchTopResultCell.identifier, for: indexPath) as? SearchTopResultCell else{
                    fatalError()
                }
                if let data  = allSearchData.filter({$0.first?.resultType == resultType.rawValue}).first?.first {
                    cell.bind(data: data)
                }
                return cell
                
            case .artists:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtistToFollowCell.identifier, for: indexPath) as? ArtistToFollowCell else{
                    fatalError()
                }
                cell.vc = vc
                if let data  = allSearchData.filter({$0.first?.resultType == resultType.rawValue}).first {
                    cell.bindData(data: data[indexPath.item])
                }
                
                return cell
                
            case .mostPopular, .tracks, .podcastStories:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MostPopularSongCell.identifier, for: indexPath) as? MostPopularSongCell else{
                    fatalError()
                }
                if let data  = allSearchData.filter({$0.first?.resultType == resultType.rawValue}).first {
                    cell.dataBind(data: data[indexPath.item], index: String(indexPath.item+1))
                }
                
                return cell
            case .album, .singles, .artistToFollow, .playlists, .featuring, .moreEpisodes, .videoPodcast, .podcastShows, .latestRelease, .movieBlockBluster, .morePlaylistLikeThis, .videos, .podcastEpisodes:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommonCollectionViewCell.identifier, for: indexPath) as? CommonCollectionViewCell else{
                    fatalError()
                }
                cell.vc = vc
                if let data = allSearchData.filter({$0.first?.resultType == resultType.rawValue}).first {
                    cell.titleLbl.text = resultType.rawValue
                    cell.contentType = resultType.rawValue
                    if resultType == .featuring {
                        cell.bindData(data: data, artistName: allSearchData.first?.first?.artist ?? "")
                    } else {
                        cell.bindData(data: data)
                    }
                   
                    return cell
                }
            case .unknown:
                break
            }
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommonCollectionViewCell.identifier, for: indexPath) as? CommonCollectionViewCell else{
            fatalError()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            let width = (SCREEN_WIDTH - (16*2)-8)
            return CGSize(width:width,height:33)
        } else {
            
            if isAllSearch {
                return MostPopularSongCell.size
            }
            
            let resultType:SearchAllResultType = .init(rawValue: allSearchData[indexPath.section - 1].first?.resultType ?? "") ?? .unknown
            
            if indexPath.section == 1 {
                
                if resultType == .videos {
                    return SearchCommonCollectionViewCell.sizeForVedios
                }
                
                if resultType == .album || resultType == .playlists {
                    return SearchCommonCollectionViewCell.sizeForAlbums
                }
            }
            
            if case .topResult = resultType {
                return SearchTopResultCell.size
            } else if case .mostPopular = resultType {
                return MostPopularSongCell.size
            } else if case .tracks = resultType {
                return MostPopularSongCell.size
            } else if case .podcastStories = resultType {
                return MostPopularSongCell.size
            } else if case .artistToFollow = resultType {
                return CommonCollectionViewCell.size2
            } else if case .artists = resultType {
                return ArtistToFollowCell.sizeForArtist
            }
            else {
                return CommonCollectionViewCell.commonSize
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
       switch kind {
       case UICollectionView.elementKindSectionHeader:
           
           if indexPath.section == 1 {
               let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:HeaderViewCV.identifier, for: indexPath) as! HeaderViewCV
               let resultType:SearchAllResultType = .init(rawValue: allSearchData[0].first?.resultType ?? "") ?? .unknown
               
               if isAllSearch {
                   headerView.headerTitle.text = ""
               } else if case .tracks = resultType {
                   headerView.headerTitle.text = resultType.rawValue
               } else if case .podcastStories = resultType {
                   headerView.headerTitle.text = resultType.rawValue
               } else if case .artists = resultType {
                   headerView.headerTitle.text = resultType.rawValue
               } else if case .album = resultType {
                   headerView.headerTitle.text = resultType.rawValue
               } else if case .videos = resultType {
                   headerView.headerTitle.text = resultType.rawValue
               } else if case .playlists = resultType {
                   headerView.headerTitle.text = resultType.rawValue
               }
               else{
                   headerView.headerTitle.text = SearchAllResultType.topResult.rawValue
               }
                return headerView
           } else if indexPath.section == 2 {
               let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:HeaderViewCV.identifier, for: indexPath) as! HeaderViewCV
               headerView.headerTitle.text = "Most Popular"
                    return headerView
           }
         default:
                assert(false, "Unexpected element kind")
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section > 0{
            let resultType:SearchAllResultType = .init(rawValue: allSearchData[indexPath.section - 1].first?.resultType ?? "") ?? .unknown
            
            if isAllSearch {
                if let item = allSearchData.first?[indexPath.item].type, (item.starts(with: "PD") || item.starts(with: "VD") ) {
                    vc.coordinator?.routeToContent(content: allSearchData[0][indexPath.item].toCommonContentForPodcast(shoudlHistoryAPICall: true))
                } else {
                    vc.coordinator?.routeToContent(content: allSearchData[0][indexPath.item].toCommonContent(shoudlHistoryAPICall: true))
                }
            } else if indexPath.section == 1, (resultType == .podcastStories || resultType == .videoPodcast || resultType == .podcastShows || resultType == .podcastEpisodes) {
                vc.coordinator?.routeToContent(content: allSearchData[0][indexPath.item].toCommonContentForPodcast(shoudlHistoryAPICall: true))
            } else if indexPath.section == 1, (resultType == .album || resultType == .videos || resultType == .playlists || resultType == .artists) {
                vc.coordinator?.routeToContent(content: allSearchData[0][indexPath.item].toCommonContent(shoudlHistoryAPICall: true))
            } else {
                switch resultType {
                case .topResult, .podcastStories, .artists:
                    if let data = allSearchData[0].first {
                        if let item = data.contentType, (item.starts(with: "PD") || item.starts(with: "VD") ) {
                            vc.coordinator?.routeToContent(content: data.toCommonContentForPodcast(shoudlHistoryAPICall: true))
                        } else {
                            vc.coordinator?.routeToContent(content: data.toCommonContent(shoudlHistoryAPICall: true))
                        }
                        
                    }
                case .tracks :
                    vc.coordinator?.routeToContent(content: allSearchData[0][indexPath.item].toCommonContent(shoudlHistoryAPICall: true))
                case .mostPopular:
                    if let item = allSearchData[1][indexPath.item].contentType, (item.starts(with: "PD") || item.starts(with: "VD") ) {
                        vc.coordinator?.routeToContent(content: allSearchData[1][indexPath.item].toCommonContentForPodcast(shoudlHistoryAPICall: true))
                    } else {
                        vc.coordinator?.routeToContent(content: allSearchData[1][indexPath.item].toCommonContent(shoudlHistoryAPICall: true))
                    }
                    
                case .album, .singles, .artistToFollow, .playlists, .featuring, .moreEpisodes, .videoPodcast, .podcastShows, .latestRelease, .movieBlockBluster, .morePlaylistLikeThis, .videos, .podcastEpisodes:
                    break
                case .unknown:
                    break
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section > 0 {
            let resultType:SearchAllResultType = .init(rawValue: allSearchData[section - 1].first?.resultType ?? "") ?? .unknown
            if section == 1, (resultType == .album || resultType == .videos || resultType == .playlists || isAllSearch) {
                return CGSize(width: collectionView.frame.width, height:HeaderViewCV.HEIGHT)
            }
            switch resultType {
            case .topResult, .mostPopular, .tracks, .podcastStories, .artists:
                return CGSize(width: collectionView.frame.width, height:HeaderViewCV.HEIGHT)
            case .album, .singles, .artistToFollow, .playlists, .featuring, .moreEpisodes, .videoPodcast, .podcastShows, .latestRelease, .movieBlockBluster, .morePlaylistLikeThis, .videos, .podcastEpisodes:
                return .zero
            case .unknown:
                return .zero
            }
        }
        
        return .zero
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
          // Dismiss keyboard
        vc.searchTf.endEditing(true)
      }
}

enum SearchAllResultType: String {
    case topResult = "Top Result"
    case mostPopular = "Most Popular"
    case album = "Albums"
    case singles = "Singles"
    case artistToFollow = "Artists To Follow"
    case playlists = "Playlists"
    case featuring = "Featuring"
    case moreEpisodes = "More Episodes Like This"
    case podcastShows = "Podcast Shows"
    case podcastEpisodes = "Podcast Episodes"
    case videoPodcast = "Video Podcasts"
    case latestRelease = "Latest Releases"
    case movieBlockBluster = "Movie Blockbusters"
    case morePlaylistLikeThis = "More PlayList Like This"
    case artists = "Artists"
    case tracks = "Tracks"
    case videos = "Videos"
    case podcastStories = "Podcast Stories"
    case unknown = ""
}
