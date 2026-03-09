//
//  DiscoverCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/10/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class DiscoverCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(UINib(nibName: "DiscoverBillboardCell", bundle: Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "DiscoverBillboardCell")
        collectionView.register(UINib(nibName: "PopularArtistCell", bundle: Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "PopularArtistCell")
        collectionView.register(UINib(nibName: "GenreAndFeaturePlaylistCell", bundle: Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "GenreAndFeaturePlaylistCell")
        collectionView.register(UINib(nibName: "LatestAlbumCell", bundle:Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "LatestAlbumCell")
        collectionView.register(UINib(nibName: "NewMusicVideoCell", bundle: Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "NewMusicVideoCell")
        collectionView.register(UINib(nibName: "TrendingVideoCell", bundle: Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "TrendingVideoCell")
        collectionView.register(UINib(nibName: "RadioCell", bundle: Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "RadioCell")
        collectionView.register(UINib(nibName: "SpotLightCell", bundle: Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "SpotLightCell")
        collectionView.register(UINib(nibName: "VideoPodcastCell", bundle: Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "VideoPodcastCell")
        collectionView.register(RecentCell.nib, forCellWithReuseIdentifier: RecentCell.identifier)
        collectionView.register(PodcastCell.nib, forCellWithReuseIdentifier: PodcastCell.identifier)
        collectionView.register(MadeForYou.nib, forCellWithReuseIdentifier: MadeForYou.identifier)
        collectionView.register(PodcastCell_2.nib, forCellWithReuseIdentifier: PodcastCell_2.identifier)
        collectionView.register(GamesCCell.nib, forCellWithReuseIdentifier: GamesCCell.identifier)
    }
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout>(_ dataSourceDelegate: D, forRow row: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.setContentOffset(collectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        collectionView.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
