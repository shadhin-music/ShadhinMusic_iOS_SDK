//
//  VideoVCCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/18/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class VideoVCCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(UINib(nibName: "VideoVCViewCell", bundle:Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "VideoVCViewCell")
        collectionView.register(UINib(nibName: "LargeVideoCell", bundle:Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "LargeVideoCell")
        
    }
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout>(_ dataSourceDelegate: D, forRow row: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.setContentOffset(collectionView.contentOffset, animated:false)
        // Stops collection view if it was scrolling.
        if row == 0 {
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .vertical  // .horizontal
            }
        }else{
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal  // .horizontal
            }
        }
        collectionView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

