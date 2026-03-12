//
//  SearchCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/23/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(UINib(nibName: "PopularArtistCell", bundle:Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "PopularArtistCell")
        collectionView.register(UINib(nibName: "LatestAlbumCell", bundle:Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "LatestAlbumCell")
        collectionView.register(UINib(nibName: "NewMusicVideoCell", bundle:Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "NewMusicVideoCell")
        
        collectionView.register(UINib(nibName: "TopTenTrendingSongsCell", bundle:Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "TopTenTrendingSongsCell")
        collectionView.register(UINib(nibName: "TopTenTrendingVideoCell", bundle:Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "TopTenTrendingVideoCell")
        collectionView.register(UINib(nibName: "SearchHistoryCell", bundle:Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "SearchHistoryCell")
        
    }
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout>(_ dataSourceDelegate: D, forRow row: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.setContentOffset(.zero, animated:false) // Stops collection view if it was scrolling.
        collectionView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
