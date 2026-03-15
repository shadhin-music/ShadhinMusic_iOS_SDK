//
//  WatchLaterAndHistoryVC.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/21/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class WatchLaterAndHistoryVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var noDataImgView: UIImageView!
    @IBOutlet weak var noDataTitleLbl: UILabel!
    @IBOutlet weak var noDataDetailsLbl: UILabel!
    
    private var watchLaterAndHistoryLists = [CommonContent_V7]()
    
    var viewTitle = ""
    var isHistory: Bool!
    
    private let downloadManager = SDDownloadManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .customBGColor()
        
        title = viewTitle
        getDatabaseData()
        
        if isHistory {
            noDataImgView.image = UIImage(named: "nohistory",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            noDataTitleLbl.text = "No History!"
            noDataDetailsLbl.text = "This list is empty. Play your favorite songs, albums, playlists."
        }else {
            noDataImgView.image = UIImage(named: "novideos",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            noDataTitleLbl.text = "No Videos!"
            noDataDetailsLbl.text = "This list is empty. Add videos to this list."
        }
        
        noDataViewF()
    }
    
    private func noDataViewF() {
        noDataView.isHidden = !watchLaterAndHistoryLists.isEmpty
        tableView.isHidden = watchLaterAndHistoryLists.isEmpty
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.tintColor = .label
        } else {
            // Fallback on earlier versions
            navigationController?.navigationBar.tintColor = .black
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func getDatabaseData() {
        do {
            let datas = try VideoWatchLaterAndHistroyDatabase.instance.getDataFromDatabase(isHistory: isHistory)
            self.watchLaterAndHistoryLists = datas
            self.tableView.reloadData()
            
        }catch {
            Log.error(error.localizedDescription)
        }
    }

}

// MARK: - Table View

extension WatchLaterAndHistoryVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchLaterAndHistoryLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoListCell") as! VideoListCell
        cell.configureCell(model: watchLaterAndHistoryLists[indexPath.row])
        cell.didThreeDotMenuTapped {
            
            let menu = MoreMenuVC()
            menu.menuType = .Video
            menu.openForm = self.isHistory ? .History : .WatchLater
            menu.data = self.watchLaterAndHistoryLists[indexPath.row]
            menu.delegate = self
            let height = MenuLoader.getHeightFor(vc: self.isHistory ? .History : .WatchLater, type: .Video, operators: self.watchLaterAndHistoryLists.first?.rbtOperators)
            var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 0)
            attribute.entryBackground = .color(color: .clear)
            attribute.border = .none

            SwiftEntryKit.display(entry: menu, using: attribute)
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        openVideoPlayer(videoData: watchLaterAndHistoryLists, index: indexPath.row)
    }
}


extension WatchLaterAndHistoryVC : MoreMenuDelegate{
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
        
        let request = URLRequest(url: url)
        let _ = self.downloadManager.downloadFile(withRequest: request, onCompletion: { error, url in
            if error != nil{
                self.view.makeToast(error?.localizedDescription)
            }else{
                //self.view.makeToast("File successfully downloaded.")
                //save song
                //DatabaseContext.shared.addSong(content: content)
                //send download info to server
                ShadhinApi().downloadCompletePost(model: content)
            }
        })
        tableView.reloadData()
    }
    
    func onRemoveDownload(content: CommonContentProtocol, type: MoreMenuType) {
        SDFileUtils.removeItemFromDirectory(urlName: content.playUrl ?? "")
        VideosDownloadDatabase.instance.deleteDataFromDatabase(contentID: content.contentID ?? "")
        RecentlyPlayedDatabase.instance.deleteDataFromDatabase(contentID: content.contentID ?? "")
        viewDidLoad()
        view.makeToast("Offline video removed from storage")
    }
    //for video this work for history  and watch later remove
    func onRemoveFromHistory(content: CommonContentProtocol) {
        if isHistory{
            VideoWatchLaterAndHistroyDatabase.instance.deleteDataFromDatabase(contentID: content.contentID ?? "")
        }else{
            VideoWatchLaterAndHistroyDatabase.instance.updateDataToDatabase(videoData: [content], songIndex: 0, isHistory: true)
        }
        
        getDatabaseData()
        noDataViewF()
    }
    
    func gotoArtist(content: CommonContentProtocol) {
        
    }
    
    func gotoAlbum(content: CommonContentProtocol) {
        
    }
    
    func addToPlaylist(content: CommonContentProtocol) {
        
    }
    func shareMyPlaylist(content: CommonContentProtocol) {
        
    }
    
    func openQueue() {
        
    }
    
    func openSleepTimer() {
    
    }
    
}
