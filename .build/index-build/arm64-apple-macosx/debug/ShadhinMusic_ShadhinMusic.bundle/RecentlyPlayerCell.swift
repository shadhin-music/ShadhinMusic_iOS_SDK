//
//  SingleLineWithTitleCell.swift
//  Shadhin
//
//  Created by MacBook Pro on 20/12/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class RecentlyPlayerCell: UICollectionViewCell {
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    static var height : CGFloat{
        return 30 + 16 + 157
    }
    private var dataSource : [CommonContentProtocol] = []
    var onItemClick : (CommonContentProtocol)-> Void = {_ in}
    var onSeeAllClick : ()-> Void = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(RecentCell.nib, forCellWithReuseIdentifier: RecentCell.identifier)
        collectionView.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    @IBAction func onSeeAllPressed(_ sender: Any) {
        onSeeAllClick()
    }
    
    func bind(with title : String, dataSource : [CommonContentProtocol],isSeeAll : Bool){
        self.dataSource = dataSource
        self.titleLabel.text = title
        self.collectionView.reloadData()
    }
//    func bind(with patch : HomePatch){
//        self.dataSource = patch.contents
//        self.titleLabel.text = patch.title
//        seeAllButton.isHidden = !(patch.isSeeAllActive ?? false)
//        self.collectionView.reloadData()
//    }
}
extension RecentlyPlayerCell : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentCell.identifier, for: indexPath) as? RecentCell else{
            fatalError()
        }
        cell.configureCell(model: dataSource[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.onItemClick(dataSource[indexPath.row])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return RecentCell.size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}
