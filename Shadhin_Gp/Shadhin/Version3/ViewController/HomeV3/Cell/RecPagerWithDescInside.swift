//
//  NewReleaseCell.swift
//  Shadhin
//
//  Created by Joy on 18/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class RecPagerWithDescInside: UICollectionViewCell {
    
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var height : CGFloat{
        return 200
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var dataSource : [CommonContentProtocol] = []
    var onItemClick : (CommonContentProtocol)-> Void = {_ in}
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        collectionView.register(RecPagerWithDescInsideSub.nib, forCellWithReuseIdentifier: RecPagerWithDescInsideSub.identifier)
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
    }
    func bind(with dataSource : [CommonContentProtocol]){
        self.dataSource = dataSource
        self.collectionView.reloadData()
        pageControl.numberOfPages = dataSource.count
    }

}
extension RecPagerWithDescInside : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecPagerWithDescInsideSub.identifier, for: indexPath) as? RecPagerWithDescInsideSub else{
            fatalError()
        }
        //cell.bindForFavouroteArtist(with: T##ContentDataProtocol)
        cell.bind(with: dataSource[indexPath.row])
        cell.onPlaySong = {content in
            
            if let vc = UIApplication.shared.topViewController(){
                vc.openMusicPlayerV3(musicData: self.dataSource, songIndex: indexPath.row, isRadio: false,rootModel: content)
                return true
            }
            return false
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onItemClick(dataSource[indexPath.row])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w  = UIScreen.main.bounds.width - 32
        return .init(width: w, height: RecPagerWithDescInsideSub.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.currentPage = indexPath.row
    }
}
