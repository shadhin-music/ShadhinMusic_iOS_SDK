//
//  SingleImageItemCell.swift
//  Shadhin
//
//  Created by MacBook Pro on 11/1/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class SingleImageItemCell: UICollectionViewCell {

    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var height : CGFloat{
        return 180
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    
    private var dataSource : [CommonContentProtocol] = []
    var onItemClick : (CommonContentProtocol)-> Void = {_ in}
    var onSeeAll : ()-> Void = {}
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(SquareImageCell.nib, forCellWithReuseIdentifier: SquareImageCell.identifier)
        collectionView.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func bind(with patch : HomeV3Patch){
        self.dataSource = patch.contents
        self.titleLabel.text = patch.patch.title
        self.seeAllButton.isHidden = (patch.patch.isSeeAllActive) ? false : true
        self.collectionView.reloadData()
    }
    
    @IBAction func onSeeAllPressed(_ sender: Any) {
        onSeeAll()
    }
}
extension SingleImageItemCell : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SquareImageCell.identifier, for: indexPath) as? SquareImageCell else{
            fatalError()
        }
        cell.bind(with: dataSource[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onItemClick(dataSource[indexPath.row])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: collectionView.bounds.height - 8, height: collectionView.bounds.height - 8)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}
