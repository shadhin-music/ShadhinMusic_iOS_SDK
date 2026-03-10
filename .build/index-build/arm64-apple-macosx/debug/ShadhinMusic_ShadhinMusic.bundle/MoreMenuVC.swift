//
//  MoreMenuVC.swift
//  Shadhin
//
//  Created by Joy on 13/7/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit


protocol MoreMenuDelegate : NSObjectProtocol{
    func onDownload(content : CommonContentProtocol,type : MoreMenuType)
    func onRemoveDownload(content : CommonContentProtocol,type : MoreMenuType)
    func onRemoveFromHistory(content : CommonContentProtocol)
    func gotoArtist(content : CommonContentProtocol)
    func gotoAlbum(content : CommonContentProtocol)
    func addToPlaylist(content : CommonContentProtocol)
    func shareMyPlaylist(content : CommonContentProtocol)
    func onAirplay()
    func addToFavourite()
    func removeFromFavourite()
    func openQueue()
    func openSleepTimer()
}

extension MoreMenuDelegate {
    func onAirplay(){}
    func addToFavourite(){}
    func removeFromFavourite(){}
}

class MoreMenuVC: UIViewController,NIBVCProtocol {
    
    weak var delegate : MoreMenuDelegate?
    
    @IBOutlet weak var songImgShadow: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var songImgView: UIImageView!
    @IBOutlet weak var songTitleLbl: UILabel!
    @IBOutlet weak var songArtistLbl: UILabel!
    @IBOutlet weak var copyRightLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var resolvedAlbumId: String = ""
    //menu list
    private var dataSource : [MoreMenuModel] = []
    //favourite check variable
    private var isFav : Bool = false
    //menu open for which content
    var data : CommonContentProtocol!
    //alwasy set this menu open from
    var menuType : MoreMenuType = .Songs
    //use this optio for now
    var openForm : MenuOpenFrom?
    //content type
    private var contentType : SMContentType = .song
    //MARK:- Initial with nib name
    init() {
        super.init(nibName: String(describing: type(of: self)), bundle:Bundle.ShadhinMusicSdk)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 8
        if let cType = data.contentType{
            contentType = SMContentType(rawValue: cType)
            if contentType == .unknown{
                if cType.count > 1{
                    contentType = .podcast
                }else{
                    contentType = .song
                }
            }
            
        }
        if let openForm = openForm {
            dataSource = MenuLoader.getMenuFor(vc: openForm, type: menuType, operators: data.rbtOperators)
            if menuType == .Songs && (data.albumId == nil || data.albumId == ""){
                dataSource.removeAll(where: {$0.type == .GotoAlbum})
            }

            tableViewSetup()
            viewSetup()
            if openForm != .History && ( menuType == .Video){
                checkWatchLater()
            }
            return
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = ShadhinCore.instance.defaults.isLighTheam ? .light : .dark
        } else {
            // Fallback on earlier versions
        }
    }

    //view setup
    private func viewSetup(){
        if let imgUrl = data.image{
            songImgView.kf.setImage(with: ShadhinApi.getImageUrl(url: imgUrl, size: 300), placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        }else{
            songImgView.image = UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        }
        songImgShadow.layer.masksToBounds = false
        songImgShadow.layer.cornerRadius = 42
        songImgShadow.layer.shadowOffset = CGSize(width: 0, height: 8)
        songImgShadow.layer.shadowOpacity = 0.6
        songImgShadow.layer.shadowRadius = 16
        songImgShadow.layer.shadowColor = UIColor.secondaryLabelColor().cgColor
        if let artist = data.artist , !artist.isEmpty{
            self.songArtistLbl.text = artist
        }
        
        if let title = data.title{
            self.songTitleLbl.text = title
        }
        if let copyright = data.copyright, !copyright.isEmpty{
            self.copyRightLabel.isHidden = false
            self.copyRightLabel.text = "© copyright: \(copyright)"
        }else{
            self.copyRightLabel.isHidden = true
        }
        //check this item is favorite or not
        favoriteCheck()
        downloadCheck()
    }
}

//MARK: table view populate
extension MoreMenuVC : UITableViewDataSource{
    //tableview setup
    private func tableViewSetup(){
        tableView.register(MoreMenuCell.nib(), forCellReuseIdentifier: MoreMenuCell.identifier)
        tableView.dataSource = self
        tableView.delegate  = self
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MoreMenuCell.identifier) as? MoreMenuCell else{
            fatalError("more menu cell load failed")
        }
        
        cell.setDataWith(model: dataSource[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
}
//MARK: tableview did select
extension MoreMenuVC : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let  obj = dataSource[indexPath.row]
        guard let delegate = self.delegate else{
            return
        }
        switch obj.type{
        case .SetAsWelcomeTune:
            let popupVC = SetWelcomeTunePopupVC.instantiateNib()
            popupVC.contentId = data.contentID ?? ""
            popupVC.topImageView = songImgView.image
            popupVC.musicName = songTitleLbl.text ?? ""
            popupVC.artsitName = songArtistLbl.text ?? ""
            var attribute = SwiftEntryKitAttributes.bottomAlertWrapAttributesRound(offsetValue: 0)
            attribute.entryBackground = .color(color: .clear)
            attribute.border = .none
            attribute.positionConstraints.size = .init(width: .fill, height: .constant(value: 740))
            SwiftEntryKit.display(entry:popupVC, using: attribute)
        case .Download:
            if openForm == .Download{
                delegate.onDownload(content: data, type: menuType)
            }else{
                getDownloadUrl()
            }
            
            SwiftEntryKit.dismiss()
        case .RemoveDownload:
            SwiftEntryKit.dismiss(.displayed){
                delegate.onRemoveDownload(content: self.data, type: self.menuType)
            }
        case .Favorite:
            favoriteAddOrRemove()
            delegate.addToFavourite()
        case .RemoveFevorite:
            favoriteAddOrRemove()
            delegate.removeFromFavourite()
        case .AddToPlaylist:
            SwiftEntryKit.dismiss(.displayed) { [self] in
                delegate.addToPlaylist(content: data)
            }
            
            break
        case .GotoAlbum:
           // print("🔍 navigating with albumId: \(albumId)")
            if let albumId = data.contentID {
                var albumContent = CommonContent_V0()
                albumContent.contentID = albumId
                albumContent.albumId = albumId
                albumContent.title = data.title
                albumContent.artist = data.artist
                albumContent.artistId = data.artistId
                albumContent.image = data.image
               // albumContent.contentType = "R"
                SwiftEntryKit.dismiss(.displayed) {
                    delegate.gotoAlbum(content: albumContent)
                }
            } else {
                view.makeToast(^String.Alert.noAlbumFound)
            }

            break
        case .GotoArtist:
            if let artistId = data.artistId {
                var artistContent = CommonContent_V0()
                artistContent.contentID = artistId
                artistContent.artistId = artistId
                artistContent.title = data.artist   // artist name
                artistContent.artist = data.artist
                artistContent.image = data.artistImage

                SwiftEntryKit.dismiss(.displayed) {
                    delegate.gotoArtist(content: artistContent)
                }
            } else {
                view.makeToast(^String.Alert.noArtistFound)
            }

            break
        case .Share:
            if menuType == .UserPlaylist{
                delegate.shareMyPlaylist(content: data)
            }else{
                share()
            }
            
        case .RemoveHistory:
            SwiftEntryKit.dismiss(.displayed) {
                delegate.onRemoveFromHistory(content: self.data)
            }
            
        case .WatchLater:
            self.addVideoToWatchLater {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    SwiftEntryKit.dismiss()
                }
                
            }
            
        case .RemoveWatchLater:
            SwiftEntryKit.dismiss(.displayed) {
                delegate.onRemoveFromHistory(content: self.data)
            }
            
            break
        case .Remove:
            SwiftEntryKit.dismiss(.displayed) {
                delegate.onRemoveDownload(content: self.data, type: self.menuType)
            }
        case .ConnectedDevice:
            SwiftEntryKit.dismiss(.displayed){
                delegate.onAirplay()
            }
        case .OpenQueue:
            SwiftEntryKit.dismiss(.displayed){
                delegate.openQueue()
            }
        case .SleepTimer:
            SwiftEntryKit.dismiss(.displayed){
                delegate.openSleepTimer()
            }
        case .Speed:
            changePlayerSpeed()
        default:
            break
        }
        
    }
    
    func changePlayerSpeed(){
        let speedAlert = UIAlertController(title: "Speed", message: "Please select your preferred player speed...", preferredStyle: UIAlertController.Style.actionSheet)

        let _050 = UIAlertAction(title: "x 0.50", style: .default) { (action: UIAlertAction) in
            MusicPlayerV3.audioPlayer.rate = 0.50
            self.tableView.reloadData()
        }
        
        let _067 = UIAlertAction(title: "x 0.67", style: .default) { (action: UIAlertAction) in
            MusicPlayerV3.audioPlayer.rate = 0.67
            self.tableView.reloadData()
        }
        
        let _080 = UIAlertAction(title: "x 0.80", style: .default) { (action: UIAlertAction) in
            MusicPlayerV3.audioPlayer.rate = 0.80
            self.tableView.reloadData()
        }
        
        let _100 = UIAlertAction(title: "x 1.00", style: .default) { (action: UIAlertAction) in
            MusicPlayerV3.audioPlayer.rate = 1.0
            self.tableView.reloadData()
        }
        
        let _125 = UIAlertAction(title: "x 1.25", style: .default) { (action: UIAlertAction) in
            MusicPlayerV3.audioPlayer.rate = 1.25
            self.tableView.reloadData()
        }
        
        let _150 = UIAlertAction(title: "x 1.50", style: .default) { (action: UIAlertAction) in
            MusicPlayerV3.audioPlayer.rate = 1.50
            self.tableView.reloadData()
        }
        
        let _200 = UIAlertAction(title: "x 2.00", style: .default) { (action: UIAlertAction) in
            MusicPlayerV3.audioPlayer.rate = 2.0
            self.tableView.reloadData()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        speedAlert.addAction(_050)
        speedAlert.addAction(_067)
        speedAlert.addAction(_080)
        speedAlert.addAction(_100)
        speedAlert.addAction(_125)
        speedAlert.addAction(_150)
        speedAlert.addAction(_200)
        speedAlert.addAction(cancelAction)
        self.present(speedAlert, animated: true, completion: nil)
    }
    
    
}

//MARK: action and network call
extension MoreMenuVC{
    private func getDownloadUrl(){
        ShadhinCore.instance.api.getDownloadUrl(data) { playUrl, error in
            self.data.playUrl = playUrl
            self.delegate?.onDownload(content: self.data, type: self.menuType)
        }
    }
    private func share(){
        DeepLinks.createLinkTest(controller: self)
    }
    private func favoriteAddOrRemove(){
        ShadhinCore.instance.api.addOrRemoveFromFavorite(
            content: data,
            action: isFav ? .remove : .add) { error in
            if error != nil{
                return
            }
            self.isFav.toggle()
            let remove = MoreMenuModel(title: ^String.MoreMenu.removeFromFavorite, icon: AppImage.removeFromFavorite, type: .RemoveFevorite)
            let add = MoreMenuModel(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite)
            if self.isFav{
                if let indx = self.dataSource.firstIndex(where: {$0.type == .Favorite}){
                    self.dataSource.remove(at: indx)
                    self.dataSource.insert(remove, at: indx)
                }
                FavoriteCacheDatabase.intance.addContent(content: self.data)
                self.delegate?.addToFavourite()
                self.makeToastAndRemoveSwiftEntryKit(msg: ^String.MoreMenu.addToFavorite)
            }else  if let inx = self.dataSource.firstIndex(where: {$0.type == .RemoveFevorite}){
                self.dataSource.remove(at: inx)
                self.dataSource.insert(add, at: inx)
                self.makeToastAndRemoveSwiftEntryKit(msg: ^String.MoreMenu.removeFromFavorite)
                FavoriteCacheDatabase.intance.deleteContent(content: self.data)
                self.delegate?.removeFromFavourite()
                
            }
            self.tableView.reloadData()
            //post notification for favourite update
            NotificationCenter.default.post(name: .init("FavDataUpdateNotify"), object: nil)
        }
    }
    
    private func favoriteCheck(){
        ShadhinCore.instance.api.getAllFavoriteByType(type: contentType) { data, error in
            guard let data = data, error == nil else {
                return
            }
 
            if data.contains(where: { $0.contentID == self.data.contentID}){
                self.isFav  = true
                //change fav item
                if let indx = self.dataSource.firstIndex(where: { $0.type == .Favorite}){
                    let remove = MoreMenuModel(title: ^String.MoreMenu.removeFromFavorite, icon: AppImage.removeFromFavorite, type: .RemoveFevorite)
                    self.dataSource.remove(at: indx )
                    self.dataSource.insert(remove, at: indx)
                    self.tableView.reloadData()
                }
            }else {
                //do nothing
                self.isFav = false
            }
        }
    }
    
    private func downloadCheck(){
        let item = MoreMenuModel(title: ^String.MoreMenu.removeFromDownload, icon: AppImage.remove, type: .RemoveDownload)
        //if menu not open from download, basically menu open from song
        //check song database and check menu not podcast
//        if !isFromDownload && menuType != .Podcast && menuType != .PodCastVideo && menuType != .Video{
//            if DatabaseContext.shared.isSongExist(contentId: data.contentID  ?? ""){
//                if let indx = self.dataSource.firstIndex(where: {$0.type == .Download}){
//                    self.dataSource.remove(at: indx)
//                    self.dataSource.insert(item, at: indx)
//                    self.tableView.reloadData()
//                }
//            }
//            return
//        }
        //this condion exicute only menu open from download and podcast file
        switch menuType{
        case .Songs:
            if DatabaseContext.shared.isSongExist(contentId: data.contentID  ?? ""){
                if let indx = self.dataSource.firstIndex(where: {$0.type == .Download}){
                    self.dataSource.remove(at: indx)
                    self.dataSource.insert(item, at: indx)
                    self.tableView.reloadData()
                }
            }
        case .Album:
            if DatabaseContext.shared.isAlbumExist(for: data.albumId ?? ""){
                if let indx = self.dataSource.firstIndex(where: {$0.type == .Download}){
                    self.dataSource.remove(at: indx)
                    self.dataSource.insert(item, at: indx)
                    self.tableView.reloadData()
                }
            }
        case .Artist:
            if DatabaseContext.shared.isArtistExist(for: data.artistId ?? ""){
                if let indx = self.dataSource.firstIndex(where: {$0.type == .Download}){
                    self.dataSource.remove(at: indx)
                    self.dataSource.insert(item, at: indx)
                    self.tableView.reloadData()
                }
            }
        case .Podcast:
            if DatabaseContext.shared.isPodcastExist(where: data.contentID ?? ""){
                if let indx = self.dataSource.firstIndex(where: {$0.type == .Download}){
                    self.dataSource.remove(at: indx)
                    self.dataSource.insert(item, at: indx)
                    self.tableView.reloadData()
                }
            }
        case .Playlist:
            if DatabaseContext.shared.isPlaylistExist(playlistID: data.contentID ?? ""){
                if let indx = self.dataSource.firstIndex(where: {$0.type == .Download}){
                    self.dataSource.remove(at: indx)
                    self.dataSource.insert(item, at: indx)
                    self.tableView.reloadData()
                }
            }
        case .None:
            break
        case .PodCastVideo:
            break
        case .Video:
            if VideosDownloadDatabase.instance.isDownloaded(contentID: data.contentID ?? ""){
                if let indx = self.dataSource.firstIndex(where: {$0.type == .Download}){
                    self.dataSource.remove(at: indx)
                    self.dataSource.insert(item, at: indx)
                    self.tableView.reloadData()
                }
            }
            break
        case .UserPlaylist:
            break
            
        case .AudioBook:
            //TODO: - Make it work!
            if DatabaseContext.shared.isSongExist(contentId: data.contentID  ?? "") {
                if let indx = self.dataSource.firstIndex(where: {$0.type == .Download}){
                    self.dataSource.remove(at: indx)
                    self.dataSource.insert(item, at: indx)
                    self.tableView.reloadData()
                }
            }
            
        case .ShortsSong:
            if DatabaseContext.shared.isSongExist(contentId: data.contentID  ?? "") {
                if let indx = self.dataSource.firstIndex(where: {$0.type == .Download}){
                    self.dataSource.remove(at: indx)
                    self.dataSource.insert(item, at: indx)
                    self.tableView.reloadData()
                }
            }
        }

    }
    
    func addVideoToWatchLater(complete : ()->Void){
                
        let instance = VideoWatchLaterAndHistroyDatabase.instance
        let isExist = instance.checkRecordExists(contentID: self.data.contentID ?? "")
        if isExist {
            instance.updateDataToDatabase(videoData: [self.data], songIndex: 0, isHistory: false)
        }else {
            instance.saveDataToDatabase(videoData: [self.data], songIndex: 0, isHistory: false)
        }
        view.makeToast("Added to watch history")
        complete()
    }
    
    func checkWatchLater(){
        let remove = MoreMenuModel(title: ^String.MoreMenu.removeFromWatchLater, icon: AppImage.remove, type: .RemoveWatchLater)
        if VideoWatchLaterAndHistroyDatabase.instance.isWatchLater(contentID: data.contentID ?? ""){
            if let indx = dataSource.firstIndex(where: {$0.type == .WatchLater}){
                dataSource.remove(at: indx)
                dataSource.insert(remove, at: indx)
            }
        }
    }
    func makeToastAndRemoveSwiftEntryKit(msg: String) {
        self.view?.makeToast(msg, duration: 1, position: .bottom, title: nil, image: nil, style: .init()) { (success) in
            SwiftEntryKit.dismiss()
        }
    }
    func shareSongs() {
        DeepLinks.createLinkTest(controller: self)
    }
    func shareMyPlaylist(){
        guard let name = data.title,
            let contentID = data.contentID,
            let imgUrl = data.image else{
                self.view.makeToast("Playlist is empty")
                return
        }
        //DeepLinks.createDeepLinkMyPlaylist(name: name, contentID: contentID, imgUrl: imgUrl, controller: self)
    }
}
