//
//  ArtistSearchVC.swift
//  Shadhin
//
//  Created by Rezwan on 27/9/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class ArtistSearchVC: UIViewController {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    private var currentPage = 0
    private var noMoreData = false
    private var inProcess = false
    private var refreshView : KRPullLoadView?
    
    private var artists : [Artists.Artist] = []
    private var searcheArtist : [Artists.Artist] = []
    
    private var isSearching = false
    private var lastSearchText = ""
    
    var searchRequestWorkItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadingIndicator.initLoadingIndicator(view: self.view)
        LoadingIndicator.startAnimation()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        refreshView = KRPullLoadView()
        refreshView?.delegate = self
        self.tableView.addPullLoadableView(refreshView!, type: .loadMore)
        self.getAllArtistPaged()
    }
    
    func updateArtistsData(data : [Artists.Artist]){
        
        if self.isSearching{
            return
        }
        
        tableView.beginUpdates()
        let startIndex = artists.count
        artists.append(contentsOf: data)
        let endIndex = artists.count
        let indexArray = (startIndex..<endIndex).map { i in
             IndexPath(row: i, section: 0)
        }
        tableView.insertRows(at: indexArray, with: .bottom)
        tableView.endUpdates()
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension ArtistSearchVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching{
            return searcheArtist.count
        }
        return artists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistCell", for: indexPath)
        
        let artist = isSearching ? searcheArtist[indexPath.row] : artists[indexPath.row]
        
        guard let img = cell.viewWithTag(1) as? UIImageView,
            let label = cell.viewWithTag(2) as? UILabel else{
                return cell
        }
        label.text = artist.artistName
        let imgUrl = artist.image.replacingOccurrences(of: "<$size$>", with: "300")
        img.kf.indicatorType = .activity
        img.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_artist",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let artist = isSearching ? searcheArtist[indexPath.row] : artists[indexPath.row]
        let content = CommonContent_V0(contentID: artist.id,
                                      image: artist.image,
                                      title: artist.artistName,
                                      playUrl: "",
                                      artistId: artist.id,
                                      albumId: artist.id,
                                      duration0: "",
                                      duration1: "",
                                      contentType: "A",
                                      fav: "-1",
                                      bannerImg: artist.image,
                                      newBannerImg: artist.image,
                                      playCount: 0,
                                      totalStream: "",
                                      isPaid: false,
                                      trackType: "A",
                                      _artist: artist.artistName)
        let storyBoard = UIStoryboard(name: "Discover", bundle:Bundle.ShadhinMusicSdk)
        let vc = storyBoard.instantiateViewController(withIdentifier: "MusicArtistListVC") as! MusicArtistListVC
        vc.discoverModel = content
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}

extension ArtistSearchVC : KRPullLoadViewDelegate{
    func pullLoadView(_ pullLoadView: KRPullLoadView, didChangeState state: KRPullLoaderState, viewType type: KRPullLoaderType) {
        switch state {
    
        case .none:
            break
        case .pulling(offset: _, threshold: _):
            break
        case .loading(completionHandler: let completionHandler):
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.getAllArtistPaged(completionHandler)
            }
        }
    }
}

extension ArtistSearchVC : UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.tableView.tableHeaderView?.removeFromSuperview()
        self.tableView.tableHeaderView = nil
        if searchText.count > 2{
            self.isSearching = true
            self.tableView.removePullLoadableView(type: .loadMore)
            self.refreshView = nil
            self.searcheArtist.removeAll()
            LoadingIndicator.startAnimation()
            self.getSearch(searchText)
            tableView.reloadData()
            
        }else{
            self.isSearching = false
            self.lastSearchText = ""
            LoadingIndicator.stopAnimation()
            if self.refreshView == nil{
                self.refreshView = KRPullLoadView()
                self.refreshView?.delegate = self
                self.tableView.addPullLoadableView(refreshView!, type: .loadMore)
            }
            tableView.reloadData()
        }
    }
}

extension ArtistSearchVC{
    
    func getSearch(_ searchText : String,_ completion: (() -> Void)? = nil) {
        searchRequestWorkItem?.cancel()
        let requestWorkItem = DispatchWorkItem(block: {self.getSearchFromServer(searchText, completion)})
        searchRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: requestWorkItem)
    }
    
    private func getSearchFromServer(
        _ searchText : String,
        _ completion: (() -> Void)? = nil){
        self.lastSearchText = searchText
        ShadhinCore.instance.api.searchArtist(
            searchText) { _data in
                if let data = _data{
                    self.searcheArtist.append(contentsOf: data.data)
                    self.tableView.reloadData()
                }else{
                    if searchText == self.lastSearchText{
                        let label = UILabel(frame: self.tableView.frame)
                        label.font = UIFont(name: "OpenSans-Regular", size: 18.0)
                        label.textAlignment = .center
                        label.text = "No result was found for \(searchText) 🤷‍♀️"
                        self.tableView.tableHeaderView = label
                    }
                }
                LoadingIndicator.stopAnimation()
                completion?()
            }
    }
    
    private func getAllArtistPaged(_ completion: (() -> Void)? = nil){
        currentPage += 1
        ShadhinCore.instance.api.getAllArtistPaged(currentPage) { _data in
            guard let data = _data else {return self.currentPage -= 1}
            self.updateArtistsData(data: data.data)
            LoadingIndicator.stopAnimation()
            completion?()
        }
    }
    
}




