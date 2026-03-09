//
//  RecommendedCell.swift
//  Shadhin
//
//  Created by Joy on 10/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class TwoRowSqrWithDescLeft: UICollectionViewCell {
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var height : CGFloat {
        return 185
    }
    
    @IBOutlet weak var titleLabel : UILabel?
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var collectionView : UICollectionView?
    
    private var dataSource : [CommonContentProtocol] = []
    var onItemClick : (CommonContentProtocol)-> Void = {_ in}
    var onSeeAllClick : ()-> Void = {}
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel?.textColor = .textColor
        
        collectionView?.register(TwoRowSqrWithDescLeftSub.nib, forCellWithReuseIdentifier: TwoRowSqrWithDescLeftSub.identifier)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.contentInset  = .init(top: 8, left: 0, bottom: 8, right: 0)
    }
    @IBAction func onSeeAllPressed(_ sender: Any) {
        onSeeAllClick()
    }
    
    func bind(with title : String, dataSource : [CommonContentProtocol]){
        self.titleLabel?.text =  title
        self.dataSource = dataSource
        self.collectionView?.reloadData()
    }
}

//MARK: CollectionView setup
extension TwoRowSqrWithDescLeft : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TwoRowSqrWithDescLeftSub.identifier, for: indexPath) as? TwoRowSqrWithDescLeftSub  else{
            fatalError()
        }
        cell.bind(with: dataSource[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let obj = dataSource[indexPath.row]
        onItemClick(obj)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = SCREEN_WIDTH - 48
        return .init(width: w / 2, height: TwoRowSqrWithDescLeftSub.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}
