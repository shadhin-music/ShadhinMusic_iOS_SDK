//
//  FollowingArtist.swift
//  Shadhin
//
//  Created by Gakk Alpha on 6/6/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class FollowingArtistVC: UIViewController {
    
    @IBOutlet weak var emptyListView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var layoutBtn: UIButton!
    @IBOutlet weak var selectionModeBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    private var minHeaderHeight: CGFloat = 92
    private var maxHeaderHeight: CGFloat = 218
    
    private var artistListsServer = [CommonContent_V3]()
    private var artistListsFiltered = [CommonContent_V3]()
    private var artistLists : [CommonContent_V3]{
        get{
            if inSearchMode{
                return artistListsFiltered
            }else{
                return artistListsServer
            }
        }
    }
    
    lazy var listCVLayout: UICollectionViewFlowLayout = {
        let collectionFlowLayout = UICollectionViewFlowLayout()
        return collectionFlowLayout
    }()
    
    lazy var gridCVLayout: UICollectionViewFlowLayout = {
        let collectionFlowLayout = UICollectionViewFlowLayout()
        return collectionFlowLayout
    }()
    
    func getVerticalSize() -> CGSize{
        var w = (screenWidth - 48)/2
        let h = w * 1.275
        w = (screenWidth - 16)/2
        return CGSize(width: w, height: h)
    }
    
    func getHorizontalSize() -> CGSize{
        let w = (screenWidth - 32)
        let h = w * 2.0/9.0 - 16
        return CGSize(width: w, height: h)
    }
    
    lazy var screenWidth: CGFloat = {
        return UIScreen.main.bounds.width
    }()
    
    var inTransition = false
    var axis : NSLayoutConstraint.Axis = .horizontal{
        didSet{
            let toLayout = axis == .horizontal ? self.listCVLayout : self.gridCVLayout
            self.collectionView.startInteractiveTransition(to: toLayout){
                _,_ in
                self.inTransition = false
            }
            self.collectionView.reloadData()
            self.collectionView.finishInteractiveTransition()
        }
    }
    
    private var inSelectionMode = false {
        didSet {
            if inSelectionMode {
                selectionModeBtn.setImage(UIImage(resource: ImageResource(name: "ic_artist_check", bundle: Bundle.ShadhinMusicSdk)), for: .normal)
                layoutBtn.setImage(UIImage(resource: ImageResource(name: "ic_delete_header", bundle: Bundle.ShadhinMusicSdk)), for: .normal)
            } else {
                selectionModeBtn.setImage(UIImage(resource: ImageResource(name: "ic_artist_uncheck", bundle: Bundle.ShadhinMusicSdk)), for: .normal)
                switch self.axis{
                case .horizontal:
                    layoutBtn.setImage(UIImage(resource: ImageResource(name: "ic_grid_mode", bundle: Bundle.ShadhinMusicSdk)), for: .normal)
                default:
                    layoutBtn.setImage(UIImage(resource: ImageResource(name: "ic_grid_mode", bundle: Bundle.ShadhinMusicSdk)), for: .normal)
                }
            }
            collectionView.reloadData()
        }
    }
    
    private var inSearchMode = false{
        didSet{
            if inSearchMode{
                searchBar.setIsHidden(false, animated: true)
                artistListsFiltered = artistListsServer
                searchBar.text = ""
                searchBar.becomeFirstResponder()
                searchBtn.setImage(UIImage(resource: ImageResource(name: "ic_close_t", bundle: Bundle.ShadhinMusicSdk)))
            }else{
                searchBar.endEditing(true)
                searchBar.setIsHidden(true, animated: true)
                searchBtn.setImage(UIImage(resource: ImageResource(name: "ic_collapsible_search", bundle: Bundle.ShadhinMusicSdk)))
            }
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let window = UIApplication.shared.windows.first
        let topPadding = window?.safeAreaInsets.top ?? 0
        minHeaderHeight = 92 + topPadding
        maxHeaderHeight = 218 + topPadding
        collectionView.contentInset =  UIEdgeInsets(top: maxHeaderHeight + 8, left: 0, bottom: 0, right: 0)
        collectionView.collectionViewLayout = listCVLayout
        collectionView.register(ArtistFollowingCell.nib, forCellWithReuseIdentifier: ArtistFollowingCell.identifier)
        initLayout()
    }
    
    private func initLayout(){
        layoutBtn.setClickListener {
            if self.inSelectionMode{
                self.sureUnfollowAll()
                return
            }
            guard !self.inTransition, !self.artistLists.isEmpty else {return}
            self.inTransition = true
            let bundle = Bundle.ShadhinMusicSdk

            if self.axis == .vertical {
                self.axis = .horizontal
                let img = UIImage(named: "ic_grid_mode", in: bundle, compatibleWith: nil)
                self.layoutBtn.setImage(img, for: .normal)
            } else {
                self.axis = .vertical
                let img = UIImage(named: "ic_list_mode", in: bundle, compatibleWith: nil)
                self.layoutBtn.setImage(img, for: .normal)
            }
        }
        selectionModeBtn.setClickListener {
            guard !self.inTransition, !self.artistLists.isEmpty else {return}
            self.inSelectionMode = !self.inSelectionMode
        }
        searchBtn.setClickListener {
            self.inSearchMode = !self.inSearchMode
        }
        backBtn.setClickListener {
            self.navigationController?.popViewController(animated: true)
        }
        if #available(iOS 13.0, *){
            searchBar.searchTextField.backgroundColor = .systemBackground
        }else if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField{
            let backgroundView = UIView(frame: textFieldInsideSearchBar.bounds)
            backgroundView.backgroundColor = .white
            backgroundView.layer.cornerRadius = 10
            backgroundView.clipsToBounds = true
            textFieldInsideSearchBar.insertSubview(backgroundView, at: 1)
        }
        searchBar.placeholder = "Search Artist"
        searchBar.delegate = self
    }
    
    
    private func getAllFavoriteArtists() {
        self.view.lock()
        ShadhinCore.instance.api.getAllFavoriteByType(type: .artist) { data, error in
            if error != nil {
                ConnectionManager.shared.networkErrorHandle(err: error, view: self.view)
            }else {
                self.inSearchMode = false
                self.inSelectionMode = false
                self.artistListsServer.removeAll()
                for item in data ?? []{
                    let artist = CommonContent_V3()
                    artist.contentID = item.contentID
                    artist.contentType = item.contentType
                    artist.image = item.image
                    artist.newBannerImg = item.newBannerImg
                    artist.title = item.title
                    artist.playUrl = item.playUrl
                    artist.artist = item.artist
                    artist.artistId = item.artistId
                    artist.albumId = item.albumId
                    artist.duration = item.duration
                    artist.fav = item.fav
                    artist.playCount = item.playCount
                    artist.isPaid = item.isPaid
                    artist.trackType = item.trackType
                    artist.copyright = item.copyright
                    artist.labelname = item.labelname
                    artist.releaseDate = item.releaseDate
                    artist.hasRBT = item.hasRBT
                    artist.teaserUrl = item.teaserUrl
                    artist.isSelected = false
                    artist.followers = item.followers

                    self.artistListsServer.append(artist)
                }
                //self.artistListsServer = data ?? []
                if self.collectionView.dataSource == nil{
                    self.collectionView.delegate = self
                    self.collectionView.dataSource = self
                }else{
                    self.collectionView.reloadData()
                }
    
            }
            self.view.unlock()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        getAllFavoriteArtists()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func openArtist(contentId: String?){
        guard let id = contentId,
              let index = artistLists.firstIndex(where: {$0.contentID == id}) else {return}
        if inSelectionMode{
            if let _index = artistListsServer.firstIndex(where: {$0.contentID == id}){
                artistListsServer[_index].isSelected = !artistListsServer[_index].isSelected
            }
            if let _index = artistListsFiltered.firstIndex(where: {$0.contentID == id}){
                artistListsFiltered[_index].isSelected = !artistListsFiltered[_index].isSelected
            }
            self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            return
        }
        let vc = goArtistVC(content: artistLists[index])
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func unFollowArtistSingle(contentId: String?){
        guard let id = contentId,
              let index = artistLists.firstIndex(where: {$0.contentID == id}) else {return}
        if inSelectionMode{
            if let _index = artistListsServer.firstIndex(where: {$0.contentID == id}){
                artistListsServer[_index].isSelected = !artistListsServer[_index].isSelected
            }
            if let _index = artistListsFiltered.firstIndex(where: {$0.contentID == id}){
                artistListsFiltered[_index].isSelected = !artistListsFiltered[_index].isSelected
            }
            self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            return
        }
        self.view.lock()
        let artist =  artistLists[index]
        ShadhinCore.instance.api.addOrRemoveFromFavorite(
            content: artist,
            action: .remove) {
                error in
                if error != nil {
                    ConnectionManager.shared.networkErrorHandle(err: error, view: self.view)
                }else {
                    self.view.makeToast("\(artist.title ?? "Artist") removed from the following list")
                    if let _index = self.artistListsServer.firstIndex(where: {$0.contentID == id}){
                        self.artistListsServer.remove(at: _index)
                    }
                    if let _index = self.artistListsFiltered.firstIndex(where: {$0.contentID == id}){
                        self.artistListsFiltered.remove(at: _index)
                    }
                    self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                }
                self.view.unlock()
            }
    }
    
    func sureUnfollowAll(){
        let unfollowArtstList = artistLists.filter({$0.isSelected})
        if unfollowArtstList.isEmpty{
            let alert = UIAlertController(title: "Notice", message: "No item selected.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Alert", message: "Unfollow all selected artists?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.destructive, handler: {_ in self.unfollowAll(unfollowArtstList)}))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func unfollowAll(_ artists : [CommonContent_V3]){
        self.view.lock()
        let dispatchGroup = DispatchGroup()
        for artist in artists{
            dispatchGroup.enter()
            ShadhinCore.instance.api.addOrRemoveFromFavorite(
                content: artist,
                action: .remove) {
                    error in
                    dispatchGroup.leave()
                }
        }
        dispatchGroup.notify(queue: .main) {
            self.getAllFavoriteArtists()
        }
    }
    
}

extension FollowingArtistVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if artistLists.count == 0{
            emptyListView.isHidden = false
        }else{
            emptyListView.isHidden = true
        }
        return artistLists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtistFollowingCell.identifier, for: indexPath) as! ArtistFollowingCell
        cell.mainStackView.axis = self.axis
        if self.axis == .vertical{
            cell.mainTitle.textAlignment = .center
            cell.mainStackView.spacing = 6
        }else{
            cell.mainStackView.spacing = 16
            cell.mainTitle.textAlignment = .left
        }
        let artist = artistLists[indexPath.row]
        print(artistLists)
        cell.configureCell(model: artistLists[indexPath.row])
        cell.mainStackView.setClickListener {
            self.openArtist(contentId: artist.contentID)
        }
        cell.unfollowBtn.setClickListener {
            self.unFollowArtistSingle(contentId: artist.contentID)
        }
        if inSelectionMode{
            if artist.isSelected{
                cell.checkGridWise.setImage(#imageLiteral(resourceName: "ic_artist_check.pdf"), for: .normal)
                cell.checkListWise.setImage(#imageLiteral(resourceName: "ic_artist_check.pdf"), for: .normal)
            }else{
                cell.checkGridWise.setImage(#imageLiteral(resourceName: "ic_artist_uncheck.pdf"), for: .normal)
                cell.checkListWise.setImage(#imageLiteral(resourceName: "ic_artist_uncheck.pdf"), for: .normal)
            }
        }
        if self.inSelectionMode{
            switch self.axis{
            case .horizontal:
                UIView.animate(withDuration: 0.3, animations:{
                    cell.checkListWise.isHidden = false
                    cell.checkGridWise.isHidden = true
                }){ _ in
                    cell.checkListWise.isHidden = false
                    cell.checkGridWise.isHidden = true
                }
            default:
                cell.checkListWise.isHidden = true
                cell.checkGridWise.isHidden = false
            }
        }else{
            switch self.axis{
            case .horizontal:
                UIView.animate(withDuration: 0.3, animations:{
                    cell.checkListWise.isHidden = true
                    cell.checkGridWise.isHidden = true
                }){ _ in
                    cell.checkListWise.isHidden = true
                    cell.checkGridWise.isHidden = true
                }
            default:
                cell.checkListWise.isHidden = true
                cell.checkGridWise.isHidden = true
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if axis == .horizontal{
            return getHorizontalSize()
        }else{
            return getVerticalSize()
        }
    }
    
    func calculateHeight() -> CGFloat {
        guard let collectionView = self.collectionView else {return .zero}
        let scroll = collectionView.contentOffset.y + maxHeaderHeight
        let heightTemp = maxHeaderHeight - scroll
        if  heightTemp > maxHeaderHeight {
            return maxHeaderHeight
        } else if heightTemp < minHeaderHeight {
            return minHeaderHeight
        } else {
            return heightTemp
        }
    }
    
}
extension FollowingArtistVC: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerHeightConstraint.constant = calculateHeight()
    }
    
}

extension FollowingArtistVC: UISearchBarDelegate{

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        self.filterContentForSearchText(searchText)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        if searchText.isEmpty{
            artistListsFiltered = artistListsServer
        }else{
            artistListsFiltered = artistListsServer.filter { (artist: CommonContent_V3) -> Bool in
                return artist.title?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
        collectionView.reloadData()
    }
    
}
