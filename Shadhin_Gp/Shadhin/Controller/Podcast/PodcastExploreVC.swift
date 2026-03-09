//
//  PodcastExploreVC.swift
//  Shadhin
//
//  Created by Rezwan on 8/3/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//


import UIKit

class PodcastExploreVC: UIViewController {

    @IBOutlet weak var noInternetView: NoInternetView!
    @IBOutlet weak var tableView: UITableView!

    var willLoadAds = false

    var podcastExplore : PodcastExploreObj?{
        didSet{
            if podcastExplore != nil{
                tableView.reloadData()
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PodcastCollectionCell.nib, forCellReuseIdentifier: PodcastCollectionCell.identifier)
        tableView.register(PodcastTrendingCell.nib, forCellReuseIdentifier: PodcastTrendingCell.identifier)
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        tableView.dataSource = self
        tableView.delegate = self

        // Remove extra spacing (iOS 13 compatible)
        tableView.separatorStyle = .none
        tableView.estimatedSectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0

        noInternetView.retry = {[weak self] in
            guard let self = self else {return}
            if ConnectionManager.shared.isNetworkAvailable{
                LoadingIndicator.startAnimation()
                ShadhinCore.instance.api.getPodcastExplore { (exploreModel, errStr) in
                    LoadingIndicator.stopAnimation()
                    if exploreModel != nil{
                        self.podcastExplore = exploreModel
                        self.noInternetView.isHidden = true
                        self.tableView.isHidden = false
                    }
                    if let _errStr = errStr{
                        self.view.makeToast(_errStr)
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
            guard self.podcastExplore == nil else {return}
            LoadingIndicator.initLoadingIndicator(view: self.view)
            LoadingIndicator.startAnimation()
            ShadhinCore.instance.api.getPodcastExplore { (exploreModel, errStr) in
                LoadingIndicator.stopAnimation()
                if exploreModel != nil{
                    self.podcastExplore = exploreModel
                    self.noInternetView.isHidden = true
                    self.tableView.isHidden = false
                }
                if let _errStr = errStr{
                    self.view.makeToast(_errStr)
                }
            }

        }else{
            guard self.podcastExplore == nil else {return}
            tableView.isHidden = true
            noInternetView.isHidden = false
        }
    }

    func openPodcast(patchItem : PatchItem){

        if let podcastVC = self.storyboard?.instantiateViewController(withIdentifier: "PodcastVC") as? PodcastVC{
            podcastVC.podcastCode = patchItem.contentType
            podcastVC.selectedEpisodeID = Int(patchItem.episodeID) ?? 0
            self.navigationController?.pushViewController(podcastVC, animated: false)
        }
    }
}

extension PodcastExploreVC : UITableViewDelegate, UITableViewDataSource{

    func isIndexAnAd(index : Int) -> Bool{
        if !willLoadAds{
            return false
        }
        return index % 4 == 0
    }

    func getAdAdjustedRow(row: Int) -> Int{
        if !willLoadAds{
            return row
        }
        let n = Double(row) / 4.0
        let _n = Int(n.rounded(.up))
        let adjustedSection = row - (1 * _n)
        return adjustedSection
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // Only count sections with pp or tpc patch types
        return podcastExplore?.data.filter {
            ["pp", "tpc"].contains($0.patchType.lowercased())
        }.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Show 2 rows for 2x2 grid
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let allData = podcastExplore?.data else {
            return UITableViewCell()
        }

        // Get filtered data
        let filteredData = allData.filter { ["pp", "tpc"].contains($0.patchType.lowercased()) }
        let patchData = filteredData[indexPath.section]

        let cell = tableView.dequeueReusableCell(withIdentifier: PodcastCollectionCell.identifier, for: indexPath) as! PodcastCollectionCell
        cell.bind(patchData, indexPath)
        cell.podcastExploreVC = self
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        guard let allData = podcastExplore?.data else {
            return 0
        }

        // Get filtered data
        let filteredData = allData.filter { ["pp", "tpc"].contains($0.patchType.lowercased()) }
        let patchData = filteredData[indexPath.section]

        switch patchData.patchType.lowercased() {
        case "pp":
            return PodcastCollectionCell.size(.SquareBig)
        case "tpc":
            return PodcastCollectionCell.size(.Portrait)
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let allData = podcastExplore?.data else {
            return nil
        }

        // Get filtered data
        let filteredData = allData.filter { ["pp", "tpc"].contains($0.patchType.lowercased()) }
        let patchData = filteredData[section]

        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        view.backgroundColor = .clear

        let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.width - 32, height: 30))
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
        return .leastNonzeroMagnitude
    }
}
