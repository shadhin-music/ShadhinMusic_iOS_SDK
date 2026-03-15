//
//  FavouriteVC.swift
//  Shadhin
//
//  Created by Joy on 21/7/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class FavouriteVC: UIViewController {
    
    @IBOutlet weak var emptyListView: EmptyListView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var headerView: HeaderViewDownload!
    
    //collection view property initial
    private var minHeaderHeight: CGFloat = 56 + 76 //+ 20
    private var maxHeaderHeight: CGFloat = 218 //+ 40
    @IBOutlet weak var headerConstraint: NSLayoutConstraint!
    
    lazy var listCVLayout: UICollectionViewFlowLayout = {
        let collectionFlowLayout = UICollectionViewFlowLayout()
        return collectionFlowLayout
    }()
    
    lazy var gridCVLayout: UICollectionViewFlowLayout = {
        let collectionFlowLayout = UICollectionViewFlowLayout()
        return collectionFlowLayout
    }()
    private func getVerticalSize() -> CGSize{
        let w = (screenWidth - 48)/2
        let h = w + DownloadGridCell.bottomHeight
        return CGSize(width: w, height: h)
    }
    
    private func getHorizontalSize() -> CGSize{
        let w = (screenWidth - 32)
        let h = 56.0
        return CGSize(width: w, height: h)
    }
    
    private lazy var screenWidth: CGFloat = {
        return UIScreen.main.bounds.width
    }()
    
    private var isSelectMood : Bool = false{
        didSet{
            collectionView.reloadData()
        }
    }
    
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
    //datasource
    private var dataSource : [CommonContent_V7] = []
    private var dataSourceAll : [CommonContent_V7] = []
    var favoriteType : SMContentType = .song
    //MARK:- Initial with nib name
    init() {
        super.init(nibName: String(describing: type(of: self)), bundle:
                .ShadhinMusicSdk)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewSafeAreaInsetsDidChange()
        let obj = EmptyViewModel(topIcon: AppImage.noFav, title: ^String.Downloads.noFavorites, subtitle: ^String.Downloads.noFavoritesSubtitle)
        emptyListView.setData(with: obj)
        emptyListView.backgroundColor = .clear
        emptyListView.isHidden = false
        // Do any additional setup after loading the view.
        let window = UIApplication.shared.windows.first
        let topPadding = window?.safeAreaInsets.top ?? 0
        minHeaderHeight = minHeaderHeight + topPadding
        maxHeaderHeight = maxHeaderHeight + topPadding
        headerConstraint.constant = maxHeaderHeight
        //collection view set up
        //collectionView.contentInset =  UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.contentInset =  UIEdgeInsets(top: maxHeaderHeight + 8, left: 16, bottom: 0, right: 16)
        collectionView.collectionViewLayout = listCVLayout
        collectionView.register(DownloadGridCell.nib(), forCellWithReuseIdentifier: DownloadGridCell.identifier)
        collectionView.register(DownloadListCell.nib(), forCellWithReuseIdentifier: DownloadListCell.identifier)
        collectionView.allowsMultipleSelection = true
        collectionView.contentInsetAdjustmentBehavior = .never
        setUpHeader()
        
        NotificationCenter.default.addObserver(forName: .init("FavDataUpdateNotify"), object: nil, queue: .main) { notification in
            self.getAllFavorites()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        if self.collectionView.dataSource == nil{
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
        }
        
        self.collectionView.reloadData()
        getAllFavorites()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    

    func setUpHeader(){
        headerView.delegate = self
        headerView.setData(with: ^String.Downloads.favorites , subtitle: ^String.Downloads.favoritesSubtitle)
        headerView.backButton.setClickListener {
            self.navigationController?.popViewController(animated: true)
        }
        //select all button click handler
        headerView.selectAllButton.setClickListener { [self] in
            self.isSelectMood = !self.isSelectMood
            //update allselect button icon
            self.headerView.selectMarkButton.isSelected = !headerView.selectMarkButton.isSelected
            self.headerView.isSelectMood = self.isSelectMood
        }
        headerView.isSelectMood = self.isSelectMood
        headerView.axis = self.axis
        //grid and list view change handler
        headerView.gridListButton.setClickListener {
            
            if self.isSelectMood{
                //delete all
                self.batchRemoveFavourite()
                return
            }
            
            guard !self.inTransition, !self.dataSource.isEmpty else {return}
            self.inTransition = true
            if self.axis == .vertical{
                self.axis = .horizontal
                
            }else{
                self.axis = .vertical
                
            }
            self.headerView.axis = self.axis
        }
        headerView.downloadView.isHidden = true
        headerView.collectionView.isHidden = true
    }
    
    private func getAllFavorites() {
        self.dataSource.removeAll()
        self.dataSourceAll.removeAll()
        ShadhinCore.instance.api.getAllFavoriteByType(type: favoriteType) { data, error in
            guard let data = data, error == nil else {
                self.view.makeToast(error?.localizedDescription)
                return
            }
            self.dataSourceAll = data.map({ fd in
                var dcm : CommonContent_V7 = CommonContent_V7()
                dcm.setContentDataProtocal(cdp: fd)
                return dcm
            })
            self.dataSource = self.dataSourceAll
            self.collectionView.reloadData()
        }
        
    }
}

extension FavouriteVC  : UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if dataSource.count == 0 {
            emptyListView.isHidden = false
        }else{
            emptyListView.isHidden = true
        }
        return dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let obj = dataSource[indexPath.row]
        if axis == .horizontal{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DownloadListCell.identifier, for: indexPath) as? DownloadListCell else{
                fatalError("download cell not load")
            }
            //cell.isSelectMood = self.isSelectMood
            cell.setData(with: obj, isSelectMood: self.isSelectMood)
            cell.setItemSelected(isSelect: obj.isSelect)
            cell.downloadMarkIV.isHidden  = true
            cell.moreButton.setClickListener {
                self.onMoreClick(index: indexPath.row)
            }
            return cell
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DownloadGridCell.identifier, for: indexPath) as? DownloadGridCell else{
            fatalError("download cell not load")
        }
        //cell select mood enable disable
        //cell.isSelectMood = self.isSelectMood
        cell.setData(with: obj,isSelectMood: self.isSelectMood)
        cell.setItemSelected(isSelect: obj.isSelect)
        cell.downloadMarkIV.isHidden  = true
        
        cell.moreButton.setClickListener {
            self.onMoreClick(index: indexPath.row)
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
    
    func onMoreClick(index : Int){
        guard index < dataSource.count else { return }
        let data = dataSource[index]
        let menu = MoreMenuVC()
        menu.delegate = self
        menu.data = data
        menu.openForm = .Favourit
        //set menu type
        var type : MoreMenuType = .Songs
        if let cType = data.contentType{
            if cType.count  > 1 {
                type = MoreMenuType(rawValue: String(cType.prefix(2))) ?? .Podcast
            }else{
                type = MoreMenuType(rawValue: cType) ?? .Songs
            }
            
        }
        menu.menuType = type
        let height = MenuLoader.getHeightFor(vc: .Favourit, type: type, operators: [])
        var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 0)
        attribute.entryBackground = .color(color: .clear)
        attribute.border = .none
        SwiftEntryKit.display(entry: menu, using: attribute)
        
    }
    
    
}
extension FavouriteVC : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isSelectMood{
            dataSource[indexPath.row].isSelect = !dataSource[indexPath.row].isSelect
            UIView.performWithoutAnimation {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
            return
        }
        let data = dataSource[indexPath.row]
        openMusicPlayerV3(musicData: dataSource, songIndex: indexPath.row, isRadio: false, playlistId: "",rootModel: data)
    }
}
extension FavouriteVC : UIScrollViewDelegate{
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerConstraint.constant = calculateHeight()
    }
}

extension FavouriteVC : JRHeaderDelegate{
    func onSearchCancel() {
        view.endEditing(true)
    }
    func onSearchText(text: String) {
        if text.isEmpty || text.elementsEqual(""){
            dataSource = dataSourceAll
            collectionView.reloadData()
            return
        }
        dataSource = dataSourceAll.filter({ dd in
            guard let title = dd.title else {return false}
            return title.lowercased().contains(text.lowercased())
        })
        collectionView.reloadData()
    }
}


extension FavouriteVC : MoreMenuDelegate {
    
    func openQueue() {}
    
    func onDownload(content: CommonContentProtocol, type: MoreMenuType) {
        
    }
    
    func onRemoveDownload(content: CommonContentProtocol, type: MoreMenuType) {
        
    }
    
    func onRemoveFromHistory(content: CommonContentProtocol) {
        
    }
    
    func gotoArtist(content: CommonContentProtocol) {
        let vc =  goArtistVC(content: content)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func gotoAlbum(content: CommonContentProtocol) {
        let vc = goAlbumVC(isFromThreeDotMenu: true, content: content)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func addToPlaylist(content: CommonContentProtocol) {
        goAddPlaylistVC(content: content)
    }
    
    func shareMyPlaylist(content: CommonContentProtocol) {
        
    }
    
    func openQueue(_ content: CommonContentProtocol) {
        
    }

    func openSleepTimer() {
    
    }
}

extension FavouriteVC {
    //error for podcast remove
    func batchRemoveFavourite(){
        let selected = dataSource.filter({$0.isSelect})
        let group = DispatchGroup()
        view.lock()
        for item in selected{
            group.enter()
            ShadhinCore.instance.api.addOrRemoveFromFavorite(
                content: item,
                action: .remove) { error in
                if let error = error {
                    Log.error(error.localizedDescription)
                }
                group.leave()
                self.dataSource.removeAll { dcm in
                    return dcm.contentID == item.contentID
                }
                self.collectionView.reloadData()
            }
        }
        view.unlock()
    }
}
