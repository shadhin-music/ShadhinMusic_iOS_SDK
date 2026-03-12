//
//  DiscoverVideoDetailsVC.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/20/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class DiscoverVideoDetailsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var videoDetailLists = [CommonContent_V0]()
    
    private let downloadManager = SDDownloadManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .customBGColor()
        
        tableView.rowHeight = 70
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Table View

extension DiscoverVideoDetailsVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoDetailLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoListCell") as! VideoListCell
        cell.configureCell(model: videoDetailLists[indexPath.row])
        cell.didThreeDotMenuTapped {
            let menu = MoreMenuVC()
            menu.data = self.videoDetailLists[indexPath.row]
            menu.menuType = .Video
            menu.openForm = .Video
            menu.delegate = self
            
            let height = MenuLoader.getHeightFor(vc: .Video, type: .Video, operators: self.videoDetailLists.first?.rbtOperators)
            var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 8)
            attribute.entryBackground = .color(color: .clear)
            attribute.border = .none

            SwiftEntryKit.display(entry: menu, using: attribute)
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    
        if ConnectionManager.shared.isNetworkAvailable{
            openVideoPlayer(videoData: videoDetailLists, index: indexPath.row)
        }else{
            let vc = NoInternetPopUpVC.instantiateNib()
            vc.gotoDownload =  {[weak self] in
                guard let self = self else {return}
                if self.checkProUser(){
                    let vc = DownloadVC.instantiateNib()
                    vc.selectedDownloadSeg = .init(title: ^String.Downloads.songs, type: .None)
                    self.navigationController?.pushViewController(vc, animated: true)
                    SwiftEntryKit.dismiss()
                }
            }
            vc.retry = {[weak self] in
                guard let self = self else {return}
                openVideoPlayer(videoData: videoDetailLists, index: indexPath.row)
                SwiftEntryKit.dismiss()
            }
            SwiftEntryKit.display(entry: vc, using: SwiftEntryKitAttributes.bottomAlertAttributes(viewHeight: NoInternetPopUpVC.HEIGHT))
        }
        
    }
}

extension DiscoverVideoDetailsVC : MoreMenuDelegate{
    func onAirplay() {
        
    }
    
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
        ShadhinCore.instance.api.downloadCompletePost(model: content)
        self.view.makeToast("Downloading \(String(describing: content.title ?? ""))")
        
        let request = URLRequest(url: url)
        let _ = self.downloadManager.downloadFile(withRequest: request, onCompletion: { error, url in
            if error != nil{
                self.view.makeToast(error?.localizedDescription)
            }else{
                self.tableView.reloadData()
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
    //remove from watch list
    func onRemoveFromHistory(content: CommonContentProtocol) {
        VideoWatchLaterAndHistroyDatabase.instance.updateDataToDatabase(videoData: [content], songIndex: 0, isHistory: true)
        view.makeToast("Remove from watch later")
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
