//
//  PlaylistListCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/7/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit



class PlaylistListCell: UITableViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size: CGFloat {
        return 73
    }
    
    public typealias AllPlaylistSongsListButton = ()->()
    
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var playlistNameLbl: UILabel!
    @IBOutlet weak var songsCountLbl: UILabel!
    @IBOutlet weak var arrowBtn: UIButton!
    
    private var songsListBtnClick: AllPlaylistSongsListButton?
    
    func configureCell(model: PlaylistsObj.PlaylistDetails) {
        playlistNameLbl.text = model.name
    }
    
    func configureCell(_ data : CommonContent_V0){
        self.backgroundColor = .clear
        arrowBtn.isHidden = true
        songsCountLbl.isHidden = false
        playlistNameLbl.text = data.title ?? ""
        imgView.contentMode = .scaleAspectFill
        let imgUrl = data.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        imgView.kf.indicatorType = .activity
        imgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        switch data.contentType?.uppercased() {
        case "A":
            songsCountLbl.text = "Artist"
            self.setClickListener {
                if let viewController = self.parentViewController?.goArtistVC(content: data){
                    self.parentViewController?.navigationController?.pushViewController(viewController, animated: true)
                }
            }
            break
        case "S":
            songsCountLbl.text = "Track"
            self.setClickListener {
                self.parentViewController?.openMusicPlayerV3(musicData: [data], songIndex: 0, isRadio: false)
            }
            break
        case "R":
            songsCountLbl.text = "Album"
            self.setClickListener {
                if let vc2 = self.parentViewController?.goAlbumVC(isFromThreeDotMenu: false, content: data){
                    self.parentViewController?.navigationController?.pushViewController(vc2, animated: true)
                }
            }
            break
        case "V":
            songsCountLbl.text = "Video"
            self.setClickListener {
                self.parentViewController?.openVideoPlayer(videoData: [data], index: 0)
            }
            break
        default:
            songsCountLbl.isHidden = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func didSongsListButtonTapped(completion: @escaping AllPlaylistSongsListButton) {
        songsListBtnClick = completion
    }
    
    @IBAction func songsListAction(_ sender: Any) {
        songsListBtnClick?()
    }
}
