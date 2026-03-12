//
//  TopGenresCell.swift
//  Shadhin
//
//  Created by Joy on 18/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class TwoRowSqr: UICollectionViewCell {

    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var height : CGFloat{
        return 340
    }
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var dataSource : [CommonContentProtocol] = []
    var onItemClick : (CommonContentProtocol)-> Void = {_ in}
    var onSeeAllClick : ()-> Void = {}
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(TwoRowSqrSub.nib, forCellWithReuseIdentifier: TwoRowSqrSub.identifier)
        collectionView.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    @IBAction func onSeeAllPressed(_ sender: Any) {
        onSeeAllClick()
    }
    
    func bind(with title : String, data : [CommonContentProtocol]){
        self.titleLabel.text = title
        self.dataSource = data
        collectionView.reloadData()
    }
    func bind(with patch : HomeV3Patch){
        self.titleLabel.text = patch.patch.title
        self.dataSource = patch.contents
        collectionView.reloadData()
        seeAllButton.isHidden = !(patch.patch.isSeeAllActive)
    }
}
extension TwoRowSqr : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TwoRowSqrSub.identifier, for: indexPath) as? TwoRowSqrSub else{
            fatalError()
        }
        cell.bindWith(obj: dataSource[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.onItemClick(dataSource[indexPath.row])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return TwoRowSqrSub.size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}
