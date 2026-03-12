//
//  VideoDownloadVC.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 3/5/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit


class VideoDownloadVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var noDataImgView: UIImageView!
    @IBOutlet weak var noDataTitleLbl: UILabel!
    @IBOutlet weak var noDataDetailsLbl: UILabel!
    
    private let downloadManager = SDDownloadManager.shared
    
    private var downloadVideoLists = [CommonContent_V7]()
    
    var viewTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customBGColor()
        title = viewTitle
        getDatabaseData()
        noDataViewF()
    }
    
    private func noDataViewF() {
        noDataView.isHidden = !downloadVideoLists.isEmpty
        tableView.isHidden = downloadVideoLists.isEmpty
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
        guard let data = try? VideosDownloadDatabase.instance.getDataFromDatabase() else {return}
        self.downloadVideoLists = data
        self.tableView.reloadData()
    }
}

extension VideoDownloadVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadVideoLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoListCell") as! VideoListCell
        cell.configureCell(model: downloadVideoLists[indexPath.row])
        cell.didThreeDotMenuTapped {
            let menu = MoreMenuVC()
            menu.openForm = .Download
            menu.menuType = .Video
            menu.data = self.downloadVideoLists[indexPath.row]
            menu.delegate = self
            
            let height = MenuLoader.getHeightFor(vc: .Download, type: .Video, operators: self.downloadVideoLists.first?.rbtOperators)
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
        
        openVideoPlayer(videoData: downloadVideoLists, index: indexPath.row)
    }
}


extension VideoDownloadVC : MoreMenuDelegate{
    func onDownload(content: CommonContentProtocol, type: MoreMenuType) {
        
    }
    
    func onRemoveDownload(content: CommonContentProtocol, type: MoreMenuType) {
        SDFileUtils.removeItemFromDirectory(urlName: content.playUrl ?? "")
        VideosDownloadDatabase.instance.deleteDataFromDatabase(contentID: content.contentID ?? "")
        RecentlyPlayedDatabase.instance.deleteDataFromDatabase(contentID: content.contentID ?? "")
        viewDidLoad()
        view.makeToast("Offline video removed from storage")
    }
    
    func onRemoveFromHistory(content: CommonContentProtocol) {
        
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
