//
//  LatestVideoHomeCell.swift
//  Shadhin
//
//  Created by Joy on 19/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class TwoRowRecDescBelow: UICollectionViewCell {
    private var patch : HomeV3Patch!
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var height : CGFloat{
        return 490
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    var onItemClick : (CommonContentProtocol)-> Void = {_ in}
    var onSeeAll : ()-> Void = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(TwoRowRecDescBelowSub.nib, forCellWithReuseIdentifier: TwoRowRecDescBelowSub.identifier)
        collectionView.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func configureCell(with patch : HomeV3Patch){
        if(self.patch != nil && self.patch.patch.id == patch.patch.id){
           return
        }
        self.patch = patch
        self.collectionView.reloadData()
    }
    
    @IBAction func onSeeAllPressed(_ sender: Any) {
        onSeeAll()
    }
}
extension TwoRowRecDescBelow : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return patch.contents.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TwoRowRecDescBelowSub.identifier, for: indexPath) as? TwoRowRecDescBelowSub else{
            fatalError()
        }
        cell.bind(with: patch.contents[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onItemClick(patch.contents[indexPath.row])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return TwoRowRecDescBelowSub.size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}
