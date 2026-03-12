//
//  AudioBookHomeVC.swift
//  Shadhin
//
//  Created by Maruf on 30/9/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class AudioBookHomeVC: UIViewController, NIBVCProtocol {
    private var refreshControll : UIRefreshControl?
    @IBOutlet weak var collectionView: UICollectionView!
    var catagoryId = ""
    var catagories : [AudioBookCatagoriesContent] = []
    var audiBookAdapter: AudioBookHomeAdapter!
    var audiHomeVM: AudioBookHomeVM!
    var audioPatchData : [AudioPatchContent] = []
    private var audioHomeCoordinator: AudioBookHomeCoordinator?
    override func viewDidLoad() {
        super.viewDidLoad()
        audiHomeVM = AudioBookHomeVM(presenter: self)
        audiHomeVM.vc = self
        viewSetup()
        if let navVc = self.navigationController{
            audioHomeCoordinator = AudioBookHomeCoordinator(navigationController: navVc, tabBar: self.tabBarController)
        }
        navigationController?.isNavigationBarHidden = true
    }

}
extension AudioBookHomeVC {
      func viewSetup() {
          audiBookAdapter = AudioBookHomeAdapter(delegate: self)
          collectionView?.dataSource = audiBookAdapter
          collectionView?.delegate = audiBookAdapter
        collectionView.register(ContinueListeningBookCell.nib, forCellWithReuseIdentifier:ContinueListeningBookCell.identifier)
        collectionView.register(AudiobookCategoriesCell.nib, forCellWithReuseIdentifier: AudiobookCategoriesCell.identifier)
        collectionView.register(RecommendedBooksCell.nib, forCellWithReuseIdentifier: RecommendedBooksCell.identifier)
        collectionView.register(BookHomeCell.nib, forCellWithReuseIdentifier: BookHomeCell.identifier)
        collectionView.register(ArtsEntertainmentCell.nib, forCellWithReuseIdentifier: ArtsEntertainmentCell.identifier)
          collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "EmptyCell")
          refreshControll = UIRefreshControl()
          refreshControll?.tintColor = .appTintColor
          refreshControll?.attributedTitle = NSAttributedString(string: "Refresh")
          refreshControll?.addTarget(self, action: #selector(refresh), for: .valueChanged)
          collectionView?.alwaysBounceVertical = true
          collectionView?.refreshControl = refreshControll
          if let refreshControll = refreshControll{
              refreshControll.frame = .init(origin: .init(x: 0, y: 100), size: .init(width: 40, height: 40))
              refreshControll.backgroundColor = UIColor(named: "background")
              collectionView?.addSubview(refreshControll)
          }
          loadMorePatchs()
    }
    @objc
    private func refresh(){
        Log.info("Refresh ")
        refreshControll?.beginRefreshing()
        self.resetHome()
        loadMorePatchs()
        self.collectionView?.reloadData()
        self.refreshControll?.endRefreshing()
    }
}

extension AudioBookHomeVC : AudioBookHomeAdapterProtocol {
    
    var parentCollectionView: UICollectionView? {
        get {
            self.collectionView
        }
        set {
            
        }
    }
    
    var homeAdapter: AudioBookHomeAdapter? {
        get {
            audiBookAdapter
        }
        set {
            audiBookAdapter = newValue
        }
    }
    
    var homeVM: AudioBookHomeVM? {
        get {
            audiHomeVM
        }
        set {
            
        }
    }
    
    func loadMorePatchs() {
        audiHomeVM.loadHomeContent()
       // audiHomeVM.loadAudioBookCatagoriesContent()
    }
    
    func onItemClicked(patch: AudioPatchHome, content: AudioPatchContent) {
        audioHomeCoordinator?.audioBookrouteToContent(content: content,patch.patch)
    }
    
    func getNavController() -> UINavigationController {
        self.navigationController!
    }
        
    func seeAllClick(patch: AudioPatchHome) {
        audioHomeCoordinator?.gotoSeeAll(patch:patch)
    }
    
    func reloadView(indexPath: IndexPath) {
        collectionView?.reloadItems(at: [indexPath])
    }
    
    func refreshHome() {
        
        //
    }
    
    
}


extension AudioBookHomeVC: AudioBookHomeVMProtocol {
    
    func handle(patches: [AudioPatchHome]) {
        audiBookAdapter.addPatches(array: patches)
        collectionView?.reloadData()
    }
    
    func resetHome() {
     audiBookAdapter.reset()
    }
}
