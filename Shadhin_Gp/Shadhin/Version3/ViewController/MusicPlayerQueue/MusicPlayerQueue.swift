//
//  MusicPlayerQueue.swift
//  Shadhin
//
//  Created by Gakk Alpha on 9/20/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit





class MusicPlayerQueue: UIViewController,NIBVCProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    
    var backBarBtn: UIBarButtonItem!
    var viewTitle = ""
    var currentPlayingIndex = 0
    var userContentPlaylists = [CommonContentProtocol]()
    var queueListClick: ((_ destinationIndex: Int?,_ index: Int?,_ type: String?)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customBGColor()

        registerCells()
        tableView.isEditing = true
        updateUI()
    }
    private func registerCells() {
        let nib = UINib(nibName: "UserContentPlaylistAndQueueCell", bundle: Bundle.ShadhinMusicSdk)
        tableView.register(nib, forCellReuseIdentifier: "UserContentPlaylistAndQueueCell")
    }
    func updateUI() {
            tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
            tableView.isScrollEnabled = true
            navigationItem.title = viewTitle
            self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]
        backBarBtn = UIBarButtonItem(image: UIImage(named: "ic_back",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), style: .done, target: self, action: #selector(backTapped))
            if #available(iOS 13.0, *) {
                backBarBtn.tintColor = .label
            } else {
                backBarBtn.tintColor = #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
            }
            navigationItem.leftBarButtonItem = backBarBtn
    }
    
    @objc func backTapped() {
        dismiss(animated: true)
    }
    
    func didQueueListClicked(completion: @escaping UserContentPlaylistAndQueueListClick) {
        queueListClick = completion
    }
    
}


extension MusicPlayerQueue: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        return userContentPlaylists.count - (currentPlayingIndex + 1)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "UserContentPlaylistAndQueueCell"
        ) as? UserContentPlaylistAndQueueCell else {

            assertionFailure("❌ Failed to dequeue UserContentPlaylistAndQueueCell")
            return UITableViewCell()
        }

        let actualIndex = indexPath.section == 0
            ? currentPlayingIndex
            : currentPlayingIndex + 1 + indexPath.row

        if actualIndex < userContentPlaylists.count {
            cell.configureCellForFav(model: userContentPlaylists[actualIndex])
        }

        cell.setSelected(indexPath.section == 0, animated: false)

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0){
            return "Now Playing"
        }
        return "Next in Queue"
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFrame = tableView.frame
        let title = UILabel()
        title.frame =  CGRectMake(8, 4, headerFrame.size.width-20, 20)
        title.font =  UIFont(name: "OpenSans-Regular", size: 16)
        if(section == 0){
            title.textColor = .ascentColorOne()
        }
        title.text = self.tableView(tableView, titleForHeaderInSection: section)
        let headerView:UIView = UIView(frame: CGRectMake(0, 0, headerFrame.size.width, 20))
        headerView.addSubview(title)
        if #available(iOS 13.0, *) {
            headerView.backgroundColor = .systemBackground
        } else {
            headerView.backgroundColor = .white
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 26
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0){
            return
        }
        queueListClick?(nil,indexPath.row + currentPlayingIndex + 1,"onlyPlay")
        currentPlayingIndex = indexPath.row + currentPlayingIndex + 1
        UIView.transition(with: tableView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: { self.tableView.reloadData() })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            var row = 0
            if sourceIndexPath.section < proposedDestinationIndexPath.section {
                row = tableView.numberOfRows(inSection: sourceIndexPath.section) - 1
            }
            return NSIndexPath(item: row, section: sourceIndexPath.section) as IndexPath
        }
        return proposedDestinationIndexPath;
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 ? false : true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard userContentPlaylists.count > 1 else {return}
        let movedObject = self.userContentPlaylists[sourceIndexPath.row + currentPlayingIndex + 1]
        userContentPlaylists.remove(at: sourceIndexPath.row + currentPlayingIndex + 1)
        userContentPlaylists.insert(movedObject, at: destinationIndexPath.row + currentPlayingIndex + 1)
        queueListClick?(
            destinationIndexPath.row + currentPlayingIndex + 1,
            sourceIndexPath.row + currentPlayingIndex + 1,
            "move")
    }
    
}
