//
//  SearchMainV3.swift
//  Shadhin
//
//  Created by Maruf on 5/2/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class SearchMainV3: UIViewController,NIBVCProtocol {
    
    @IBOutlet weak var searchProgressView: UIActivityIndicatorView!
    @IBOutlet weak var couldNotContentLbl: UILabel!
    @IBOutlet weak var noContentView: UIView!
    var coordinator : HomeCoordinator?
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var clearBtn: UIView!
    var Genreadapter:GenreAdapter!
    var recentAdapter:RecentSearchAdapter!
    var allSearchAdapter:SearchAdapter!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTf: UITextField!
    var isSearchButtonObserverAdded = false
    var isDataObserverAdded = false
    weak var allSearchCell: AllSearchCell?
    
    @IBOutlet weak var clearSearchBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
       // IQKeyboardManager.shared.enable = true
        searchProgressView.isHidden = true
        clearBtn.isHidden = true
        clearBtn.setClickListener {
            ShadhinCore.instance.api.deleteAllSearchHistory_V2 {[weak self] responseModel in
                self?.recentAdapter.recentSearchHistories.removeAll()
                self?.collectionView.reloadData()
            }
        }
        clearSearchBtn.setClickListener {
            self.searchTf.text = ""
            self.clearBtn.isHidden = true
            self.Genreadapter = nil
            self.searchTf.resignFirstResponder()
            self.noContentView.isHidden = true
            self.genreViewSetup()
            self.allSearchCell?.reset()
        }
        self.genreViewSetup()
        self.searchTf.autocapitalizationType = .none
        self.searchTf.autocorrectionType = .no
        if let navVc = self.navigationController{
            coordinator = HomeCoordinator(navigationController: navVc, tabBar: self.tabBarController)
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
       self.navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true)
    }
    
}

extension SearchMainV3 {
    func  genreViewSetup() {
        Genreadapter = nil
        Genreadapter = GenreAdapter(vc: self)
        collectionView.dataSource = Genreadapter
        collectionView.delegate = Genreadapter
     //   Genreadapter.demoChangeAdapter()
        searchTf.delegate = Genreadapter
        collectionView?.register(GenreCollectionViewCell.nib, forCellWithReuseIdentifier: GenreCollectionViewCell.identifier)
    }
    
    func recentViewSetup() {
        recentAdapter = RecentSearchAdapter(vc: self)
        collectionView.dataSource = recentAdapter
        collectionView.delegate = recentAdapter
        collectionView?.register(RecentSearchCollectionViewCell.nib, forCellWithReuseIdentifier: RecentSearchCollectionViewCell.identifier)
        collectionView.register(UINib(nibName: "HeaderViewCV", bundle:Bundle.ShadhinMusicSdk), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier:HeaderViewCV.identifier) //elementKindSectionFooter for footerview
        
    }
    func allSearchSetup() {
        allSearchAdapter = nil
        allSearchAdapter = SearchAdapter(vc: self)
        collectionView.dataSource = allSearchAdapter
        collectionView.delegate = allSearchAdapter
        collectionView?.register(AllSearchCell.nib, forCellWithReuseIdentifier: AllSearchCell.identifier)
        collectionView?.register(SearchTopResultCell.nib, forCellWithReuseIdentifier: SearchTopResultCell.identifier)
        collectionView.register(UINib(nibName: "HeaderViewCV", bundle:Bundle.ShadhinMusicSdk), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier:HeaderViewCV.identifier)
        collectionView?.register(CommonCollectionViewCell.nib, forCellWithReuseIdentifier: CommonCollectionViewCell.identifier)
        collectionView?.register(MostPopularSongCell.nib, forCellWithReuseIdentifier: MostPopularSongCell.identifier)
        collectionView?.register(ArtistToFollowCell.nib, forCellWithReuseIdentifier: ArtistToFollowCell.identifier)
        collectionView?.register(SearchCommonCollectionViewCell.nib, forCellWithReuseIdentifier: SearchCommonCollectionViewCell.identifier)
    }
//    func allSearchResultSetUp() {
//        allSearchResultAdapter = AllSearchReultAdapter()
//        collectionView.dataSource = allSearchResultAdapter
//        collectionView.delegate = allSearchResultAdapter
//        collectionView.register(SearchTopResultCell.nib, forCellWithReuseIdentifier: SearchTopResultCell.identifier)
//    }
    
}

