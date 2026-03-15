//
//  PodcastShowsVC.swift
//  Shadhin
//
//  Created by Rezwan on 8/4/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class PodcastShowsVC: UIViewController {

    @IBOutlet weak var noInternetView: NoInternetView!
    @IBOutlet weak var tableview: UITableView!
    
    var podcastShow : PodcastShowObj?{
        didSet{
            if podcastShow != nil{
                tableview.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.register(PodcastLatestShowCell.nib, forCellReuseIdentifier: PodcastLatestShowCell.identifier)
        tableview.register(PodcastShowCell.nib, forCellReuseIdentifier: PodcastShowCell.identifier)
        tableview.contentInset = UIEdgeInsets(top: 20,left: 0,bottom: 0,right: 0)
        tableview.dataSource = self
        tableview.delegate = self
        
        noInternetView.retry = {[weak self] in
            guard let self = self else {return}
            if ConnectionManager.shared.isNetworkAvailable{
                LoadingIndicator.initLoadingIndicator(view: self.view)
                LoadingIndicator.startAnimation()
                ShadhinCore.instance.api.getPodcastShowList{ (podcastShow) in
                    LoadingIndicator.stopAnimation()
                    if podcastShow != nil{
                        self.podcastShow = podcastShow
                        self.noInternetView.isHidden = true
                        self.tableview.isHidden = false
                    }
                }
                
            }
        }
        
        noInternetView.gotoDownload = {[weak self] in
            guard let self = self else {return}
            if checkUser(){
                let vc = DownloadVC.instantiateNib()
                vc.selectedDownloadSeg = .init(title: ^String.Downloads.audioPodcast, type: .PodCast)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ConnectionManager.shared.isNetworkAvailable{
            guard self.podcastShow == nil else {return}
            LoadingIndicator.initLoadingIndicator(view: self.view)
            LoadingIndicator.startAnimation()
            ShadhinCore.instance.api.getPodcastShowList{ (podcastShow) in
                LoadingIndicator.stopAnimation()
                if podcastShow != nil{
                    self.podcastShow = podcastShow
                    self.noInternetView.isHidden = true
                    self.tableview.isHidden = false
                }
            }
        }else{
            guard self.podcastShow == nil else {return}
            self.noInternetView.isHidden = false
            self.tableview.isHidden = true
        }
    }
    
    func openPodcast(patchItem : PatchShowItem){
        
//        if !LoginService.instance.isLoggedIn{
//            guard let mainVc = AppDelegate.shared?.mainHome else {return}
//            mainVc.showNotUserPopUp(callingVC: mainVc)
//            return
//        }
        
        if let podcastVC = self.storyboard?.instantiateViewController(withIdentifier: "PodcastVC") as? PodcastVC{
            
            podcastVC.podcastCode = patchItem.contentType
            podcastVC.selectedEpisodeID = Int(patchItem.episodeID) ?? 0
            self.navigationController?.pushViewController(podcastVC, animated: false)
        }
    }
    
}

extension PodcastShowsVC : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        podcastShow?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcastShow?.data[section].data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let patchData = podcastShow?.data[indexPath.section] else{
            return UITableViewCell()
        }
        
        switch patchData.patchType?.lowercased() {
        case "as":
            let cell = tableView.dequeueReusableCell(withIdentifier: PodcastLatestShowCell.identifier, for: indexPath) as! PodcastLatestShowCell
            cell.bind(item: patchData.data[indexPath.row])
            cell.setClickListener {
                self.openPodcast(patchItem: patchData.data[indexPath.row])
            }
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let patchData = podcastShow?.data[section] else{
            return nil
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.width, height: 30))
        label.text = patchData.patchName
        label.backgroundColor = UIColor.clear
        label.font = UIFont.init(name: "OpenSans-SemiBold", size: 20)
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let patchData = podcastShow?.data[indexPath.section] else{
            return 0
        }
        
        switch patchData.patchType?.lowercased() {
        case "as":
            return PodcastLatestShowCell.size
        default:
            return 0
        }
    }

}

