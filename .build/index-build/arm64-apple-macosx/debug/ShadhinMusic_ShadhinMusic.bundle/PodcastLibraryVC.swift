//
//  PodcastLibraryVC.swift
//  Shadhin
//
//  Created by Rezwan on 8/10/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class PodcastLibraryVC: UIViewController {
    
    @IBOutlet weak var downloadHolder: UIView!
    @IBOutlet weak var favoriteHolder: UIView!
    @IBOutlet weak var noRecentData: UIView!
    @IBOutlet weak var tableView: UITableView!
    private var recentPlays = [CommonContent_V7]()
    private let downloadManager = SDDownloadManager.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.register(MyMusicSongsAndFavCell.nib, forCellReuseIdentifier: MyMusicSongsAndFavCell.identifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.favoriteHolder.setClickListener {
            self.openFavoritePodcast()
        }
        self.downloadHolder.setClickListener {
            self.openDownloadPodcast()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func openDownloadPodcast(){
        if checkUser(){
            let vc = DownloadVC.instantiateNib()
            vc.selectedDownloadSeg = .init(title: ^String.Downloads.audioPodcast, type: .PodCast)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func openFavoritePodcast(){
        let fv = FavouriteVC()
        fv.favoriteType = .podcast
        navigationController?.pushViewController(fv, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getData()
    }
    
    private func getData() {
        do {
            let data = try RecentlyPlayedDatabase.instance.getDataFromDatabase(fetchLimit: 0)
            recentPlays.removeAll()
            for item in data{
                if let contentType = item.contentType, contentType.count > 3 && contentType.lowercased().prefix(2) == "pd"{
                    recentPlays.append(item)
                    //print("Got data")
                }
            }
            if recentPlays.count > 0{
                noRecentData.isHidden = true
            }
            
            //self.recentPlays = data
            self.tableView.reloadData()
        }catch {
            Log.error(error.localizedDescription)
        }
    }
    
    
    
}

extension PodcastLibraryVC: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentPlays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PodcastRecentItem.identifier) as! PodcastRecentItem
        
        if recentPlays.count > 0 {
            cell.configureCell(model: recentPlays[indexPath.row], isFav: false)
            
            cell.didThreeDotMenuTapped {
                
                let menu = MoreMenuVC()
                menu.data = self.recentPlays[indexPath.row]
                menu.delegate = self
                menu.menuType = .Podcast
                menu.openForm = .Podcast
                let height = MenuLoader.getHeightFor(vc: .Podcast, type: .Podcast, operators: [])
                var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 0)
                attribute.entryBackground = .color(color: .clear)
                attribute.border = .none

                SwiftEntryKit.display(entry: menu, using: attribute)
                
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let obj = self.recentPlays[indexPath.row]
            let sb = UIStoryboard(name: "PodCast", bundle: Bundle.ShadhinMusicSdk)
            if let podcastVC = sb.instantiateViewController(withIdentifier: "PodcastVC") as? PodcastVC, let type = obj.contentType, let episodId = obj.albumId{
                
                podcastVC.podcastCode = type
                podcastVC.selectedEpisodeID = Int(episodId) ?? 0
                self.navigationController?.pushViewController(podcastVC, animated: false)
            }
        }
    }
    
}

//MARK: mennu delegate
extension PodcastLibraryVC: MoreMenuDelegate{
    func onDownload(content: CommonContentProtocol, type: MoreMenuType) {
        guard try! Reachability().connection != .unavailable else {return}
        
        guard checkProUser() else {
            return
        }
        
        guard let url = URL(string: content.playUrl?.decryptUrl() ?? "") else {
            return self.view.makeToast("Unable to get Download url for file")
        }
        //send data to firebase analytics
        AnalyticsEvents.downloadEvent(with: content.contentType, contentID: content.contentID, contentTitle: content.title)
        
        self.view.makeToast("Downloading \(String(describing: content.title ?? ""))")
        ShadhinApi().downloadCompletePost(model: content)
        let request = URLRequest(url: url)
        let _ = self.downloadManager.downloadFile(withRequest: request, onCompletion: { error, url in
            
        })
        tableView.reloadData()


    }
    
    func onRemoveDownload(content: CommonContentProtocol, type: MoreMenuType) {
        DatabaseContext.shared.removePodcast(with: content.contentID  ?? "")
        if let playUrl = content.playUrl{
            SDFileUtils.removeItemFromDirectory(urlName: playUrl)
            self.view.makeToast("File Removed from Download")
        }
    }
    //no need to implement this
    func onRemoveFromHistory(content: CommonContentProtocol) {
    }
    //this not call for this context
    func gotoArtist(content: CommonContentProtocol) {
    }
    //this is not call for this context
    func gotoAlbum(content: CommonContentProtocol) {
    }
    //this is not call for this context
    func addToPlaylist(content: CommonContentProtocol) {
    }
    func shareMyPlaylist(content: CommonContentProtocol) {
        
    }
    
    func openQueue() {
        
    }
    
    func openSleepTimer() {
    
    }
}

