//
//  UserContentPlaylistAndQueueListVC.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/8/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit


typealias UserContentPlaylistAndQueueListClick = (_ destinationIndex: Int?,_ index: Int?,_ type: String?)->()

class UserContentPlaylistAndQueueListVC: UIViewController {

    @IBOutlet weak var viewTitleLbl: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var editBarBtn: UIBarButtonItem!
    var backBarBtn: UIBarButtonItem!
    var isQueueEditing = false
    
    var viewTitle = ""
    var playlistID = ""
    
    var userContentPlaylists = [CommonContentProtocol]()
    
    var queueListClick: UserContentPlaylistAndQueueListClick?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .customBGColor()
        
        tableView.register(UINib(nibName: "UserContentPlaylistAndQueueCell", bundle:Bundle.ShadhinMusicSdk), forCellReuseIdentifier: "UserContentPlaylistAndQueueCell")
        
        
        updateUI()
    }
    
    func updateUI() {
        if !(viewTitle == "Playlist") {
            tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
            tableView.isScrollEnabled = true
            navigationItem.title = viewTitle
            self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]
            editBarBtn = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(addTapped))
            backBarBtn = UIBarButtonItem(image: UIImage(named: "ic_back",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), style: .done, target: self, action: #selector(backTapped))
            editBarBtn.tintColor = #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1)
            if #available(iOS 13.0, *) {
                backBarBtn.tintColor = .label
            } else {
                backBarBtn.tintColor = #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
            }
            navigationItem.rightBarButtonItem = editBarBtn
            navigationItem.leftBarButtonItem = backBarBtn
            viewTitleLbl.text = ""
        }else {
            viewTitleLbl.text = viewTitle
            tableView.isScrollEnabled = userContentPlaylists.count > 5
        }
    }
    
    @objc func addTapped() {
        tableView.isEditing = !isQueueEditing
        editBarBtn.title = isQueueEditing ? "Edit" : "Done"
        isQueueEditing.toggle()
    }
    
    @objc func backTapped() {
        dismiss(animated: true)
    }
    

    @IBAction func deleteAction(_ sender: Any) {
//        if viewTitle == "Playlist" {
//            MyMusicService.instance.deletePlaylist(playlistID: playlistID)
//            self.view!.makeToast("Playlist deleted", duration: 1, position: .bottom, title: nil, image: nil, style: .init()) { (success) in
//                SwiftEntryKit.dismiss()
//            }
//        }else {
//
//        }
    }
    
    func didQueueListClicked(completion: @escaping UserContentPlaylistAndQueueListClick) {
        queueListClick = completion
    }
    
}


extension UserContentPlaylistAndQueueListVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userContentPlaylists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserContentPlaylistAndQueueCell") as! UserContentPlaylistAndQueueCell
        cell.configureCellForFav(model: userContentPlaylists[indexPath.row])
        if userContentPlaylists[indexPath.row].contentID == MusicPlayerV3.audioPlayer.currentItem?.contentId {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if viewTitle == "Playlist" {
            queueListClick?(nil,indexPath.row,nil)
            openMusicPlayerV3(musicData: userContentPlaylists, songIndex: indexPath.row, isRadio: false)
        }else {
            queueListClick?(nil,indexPath.row,"onlyPlay")
        }
        
        //tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .none
//    }
//
//    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard userContentPlaylists.count > 1 else {
                view.makeToast("You can't delete last track on play queue")
                return
            }
            
            userContentPlaylists.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            queueListClick?(nil,indexPath.row,"delete")
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        guard userContentPlaylists.count > 1 else {return}
        
        let movedObject = self.userContentPlaylists[sourceIndexPath.row]
        userContentPlaylists.remove(at: sourceIndexPath.row)
        userContentPlaylists.insert(movedObject, at: destinationIndexPath.row)
        queueListClick?(destinationIndexPath.row,sourceIndexPath.row,"move")
    }
    
}
