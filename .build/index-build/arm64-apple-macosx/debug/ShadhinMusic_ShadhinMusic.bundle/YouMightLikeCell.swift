//
//  YouMightLikeCell.swift
//  Shadhin
//
//  Created by Maruf on 24/10/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class YouMightLikeCell: UICollectionViewCell {
    
    @IBOutlet weak var seeAll: UIButton!
    var youMightData = [SimilerBooksContent]()
    var onSeeAll: (()->Void)?
    unowned var seeAllVC:HomeSeeAllVC?
    @IBOutlet weak var collectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(YouMightLikeSubCell.nib, forCellWithReuseIdentifier: YouMightLikeSubCell.identifier)
    }
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var size: CGSize {
        let aspectRatio = 360.0/344.0
        let width = SCREEN_WIDTH - 32
        let height = width/aspectRatio
        return CGSize(width: width, height: height)
    }
    
    @IBAction func seeAllAction(_ sender: Any) {
        let vc = HomeSeeAllVC.instantiateNib()
        vc.isSimilerContent = true
        vc.youMightData = youMightData
        self.navigationController()?.pushViewController(vc, animated: true)
    }
    
}

extension YouMightLikeCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        youMightData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YouMightLikeSubCell.identifier, for: indexPath) as? YouMightLikeSubCell else{
            fatalError("more menu cell load failed")
        }
        cell.bindDataSimileData(content:youMightData[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return YouMightLikeSubCell.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let content = youMightData[indexPath.row]
        let vc  = AudioBookDetailsVC()
        let contentId = content.contentId
        vc.episodeId = String(contentId)
        vc.selectedTrackID = String(contentId)
        vc.artistId = String(contentId)
        navigationController()?.pushViewController(vc, animated: true)
    }
    
}
