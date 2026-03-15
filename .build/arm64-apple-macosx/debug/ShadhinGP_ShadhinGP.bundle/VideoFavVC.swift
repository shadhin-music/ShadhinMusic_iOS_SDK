//
//  VideoFavVC.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/21/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit
class VideoFavVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataView: UIView!
    
    private var favoriteVideoLists = [CommonContentProtocol]()
    
    private let downloadManager = SDDownloadManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .customBGColor()
        
        getAllFavorites()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFav), name: .init("FavDataUpdateNotify"), object: nil)
    }
    
    @objc private func updateFav() {
        favoriteVideoLists.removeAll()
        getAllFavorites()
    }
    
    private func getAllFavorites() {
        ShadhinCore.instance.api.getAllFavoriteByType(
            type: .video) { (favs, err) in
                if err != nil {
                    ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                }else {
                    self.favoriteVideoLists = favs ?? []
                    self.tableView.reloadData()
                }
                
                self.noDataView.isHidden = !self.favoriteVideoLists.isEmpty
                self.tableView.isHidden = self.favoriteVideoLists.isEmpty
            }
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
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK: - Table View

extension VideoFavVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteVideoLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoListCell") as! VideoListCell
        cell.configureCell(model: favoriteVideoLists[indexPath.row])
        cell.didThreeDotMenuTapped {
            
            let menu = MoreMenuVC()
            menu.openForm = .Favourit
            menu.menuType = .Video
            menu.data = self.favoriteVideoLists[indexPath.row]
            menu.delegate = self
            
            let height = MenuLoader.getHeightFor(vc: .Favourit, type: .Video, operators: self.favoriteVideoLists.first?.rbtOperators)
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
        
        openVideoPlayer(videoData: favoriteVideoLists, index: indexPath.row)
    }
}


extension VideoFavVC : MoreMenuDelegate{
    func onDownload(content: CommonContentProtocol, type: MoreMenuType) {
        guard try! Reachability().connection != .unavailable else {return}
        
        guard checkProUser() else {
            return
        }
        
        guard let url = URL(string: content.playUrl?.decryptUrl() ?? "") else {
            return self.view.makeToast("Unable to get Download url for file")
        }
        
        //print("Downloading cell \(index)")
        let indx = favoriteVideoLists.firstIndex(where: {$0.contentID ==  content.contentID})
        guard let indx =  indx , let cell = tableView.cellForRow(at: .init(row: indx, section: 0)) as? VideoListCell else {return}
        cell.circularProgressView.isHidden = false
        cell.threeDotBtn.isHidden = true
        self.view.makeToast("Downloading \(content.title ?? "")")
        
        //send data to firebase analytics
        AnalyticsEvents.downloadEvent(with: content.contentType, contentID: content.contentID, contentTitle: content.title)
        
        let request = URLRequest(url: url)
        
        _ = self.downloadManager.downloadFile(withRequest: request, onProgress: { (progress) in
            _ = String(format: "%.1f %", (progress * 100))
            cell.circularProgressView.setProgress(progress: progress, animated: true)
        }) { [weak self] (error, url) in
            if let error = error {
                Log.error("Error is \(error as NSError)")
            } else {
                cell.circularProgressView.isHidden = true
                cell.threeDotBtn.isHidden = false
                VideosDownloadDatabase.instance.saveDataToDatabase(musicData: content)
                self?.view.makeToast("File successfully downloaded.")
            }
        }
    }
    
    func onRemoveDownload(content: CommonContentProtocol, type: MoreMenuType) {
        VideosDownloadDatabase.instance.deleteDataFromDatabase(contentID: content.contentID ?? "")
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
