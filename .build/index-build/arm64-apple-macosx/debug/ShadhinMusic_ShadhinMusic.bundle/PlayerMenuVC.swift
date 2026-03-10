//
//  PlayerMenuVC.swift
//  Shadhin
//
//  Created by Gakk Alpha on 2/5/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit


protocol PlayerMenuV4Protocol : NSObjectProtocol{
    func onMenuPressed(menuItem : MoreMenuItemMusicV4)
    func onShuffleViewPressed(isSelected : Bool)
    func onRepeatViewPressed(isSelected : Bool)
    func onDownloadPressed(isSelected : Bool)
    func onLikePressed(isSelected : Bool)
}

class PlayerMenuVC: UIViewController,NIBVCProtocol {
    
    
    weak var delegate : PlayerMenuV4Protocol?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var shuffleView: TopItemMusicMoreV4!
    
    @IBOutlet weak var repateView: TopItemMusicMoreV4!
    
    @IBOutlet weak var downloadView: TopItemMusicMoreV4!
    
    @IBOutlet weak var likeView: TopItemMusicMoreV4!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var dataSource : [MoreMenuItemMusicV4] = MenuLoaderMV4.getMenu()
    var content : CommonContentProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        shuffleView.setIcon(icon: AppImage.shuffleOffMV4.uiImage, state: .normal)
        shuffleView.setIcon(icon: AppImage.shuffleOnMV4.uiImage, state: .selected)
        repateView.setIcon(icon: AppImage.repateMV4.uiImage, state: .normal)
        repateView.setIcon(icon: AppImage.repateOnceMV4.uiImage, state: .selected)
        downloadView.setIcon(icon: AppImage.noDownloadMV4.uiImage, state: .normal)
        downloadView.setIcon(icon: AppImage.downloadMV4.uiImage, state: .selected)
        likeView.setIcon(icon: AppImage.likeMV4.uiImage, state: .normal)
        likeView.setIcon(icon: AppImage.likeOnMV4.uiImage, state: .selected)
        
        shuffleView.setTitle(title: "Shuffle", state: .normal)
        shuffleView.setTitle(title: "Shuffle On", state: .selected)
        repateView.setTitle(title: "Repeat", state: .normal)
        repateView.setTitle(title: "Repeat Once", state: .selected)
        downloadView.setTitle(title: "Download", state: .normal)
        downloadView.setTitle(title: "Downloaded", state: .selected)
        likeView.setTitle(title: "Like", state: .normal)
        likeView.setTitle(title: "Liked", state: .selected)
        shuffleView.setClickListener {[weak self] in
            self?.onShufflePressed()
        }
        repateView.setClickListener {[weak self] in
            self?.onRepatePressed()
        }
        downloadView.setClickListener {[weak self] in
            self?.onDownloadPressed()
        }
        likeView.setClickListener {[weak self] in
            self?.onLikePressed()
        }
//        if MusicPlayerV4.shared.audioPlayer.mode.contains(.repeat){
//            repateView.isSelected = true
//        }else{
//            repateView.isSelected = false
//        }
//        if MusicPlayerV4.shared.audioPlayer.mode.contains(.shuffle){
//            shuffleView.isSelected = true
//        }else{
//            shuffleView.isSelected = false
//        }
        
        if let content = content {
            titleLabel.text = content.title
            subtitleLabel.text = content.artist
            imageView.kf.setImage(with: URL(string: content.image?.imageURL ?? ""))
            likeView.isSelected = FavoriteCacheDatabase.intance.isFav(content: content)
            let type = SMContentType(rawValue: content.contentType)
            if type == .podcast{
                dataSource = MenuLoaderMV4.getMenu(isPodcast: type == .podcast)
            }
            if let url = URL(string: content.playUrl?.safeUrl() ?? ""), SDDownloadManager.shared.isDownloadInProgress(forKey: url.lastPathComponent){
                downloadView.setTitle(title: "Cancel", state: .normal)
                downloadView.setIcon(icon: AppImage.downloadCancelMV4.uiImage, state: .normal)
            }
        }
        
        
        
        tableView.register(MoreMenuMusciV4Cell.nib, forCellReuseIdentifier: MoreMenuMusciV4Cell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
    }

    private func onShufflePressed(){
        shuffleView.isSelected = !shuffleView.isSelected
        SwiftEntryKit.dismiss {
            self.delegate?.onShuffleViewPressed(isSelected: self.shuffleView.isSelected)
        }
        
    }
    private func onRepatePressed(){
        repateView.isSelected = !repateView.isSelected
        SwiftEntryKit.dismiss {
            self.delegate?.onRepeatViewPressed(isSelected: self.repateView.isSelected)
        }
        
    }
    private func onDownloadPressed(){
        downloadView.isSelected = !downloadView.isSelected
        SwiftEntryKit.dismiss {
            self.delegate?.onDownloadPressed(isSelected: self.downloadView.isSelected)
        }
        
    }
    private func onLikePressed(){
        likeView.isSelected = !likeView.isSelected
        SwiftEntryKit.dismiss {
            self.delegate?.onLikePressed(isSelected: self.likeView.isSelected)
        }
        
    }
    
}

extension PlayerMenuVC : UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MoreMenuMusciV4Cell.identifier, for: indexPath) as? MoreMenuMusciV4Cell else{
            fatalError()
        }
        let data = dataSource[indexPath.row]
        cell.titleLabel.text = data.name
        cell.iconIV.image = data.icon.uiImage
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        48
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = dataSource[indexPath.row]
        SwiftEntryKit.dismiss {
            self.delegate?.onMenuPressed(menuItem: data)
        }
        
    }
}
