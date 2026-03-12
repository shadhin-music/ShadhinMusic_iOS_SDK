//
//  AudiobookCategoriesCell.swift
//  Shadhin
//
//  Created by Maruf on 30/9/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class AudiobookCategoriesCell: UICollectionViewCell {
    @IBOutlet weak var titleLbl: UILabel!
    var onSeeAll: (()->Void)?
    var audioBookHome = [AudioPatchContent]()
    var bookv3 = [CommonContentProtocol]()
    unowned var audioVC: AudioBookHomeVC?
    var catagories : [AudioBookCatagoriesContent] = []
    var patch: AudioPatchHome!
    var dataSource = [CommonContentProtocol]()
    var catagoryId = ""
    var isBeingDragged = false
    unowned var vc: AudioBookHomeVC?
    var onItemClick : (AudioPatchContent)-> Void = {_ in}
    @IBOutlet weak var pagerControl: FSPageControl!
    @IBOutlet weak var catagoriesView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var isHomeV3Content : Bool  = false
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var size: CGSize {
        let aspectRatio = 304.0/180.0
        let width = SCREEN_WIDTH
        let height = width/aspectRatio
        return CGSize(width: width, height: height)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        catagoriesView.cornerRadius = 12
        viewSetup()

    }
    func bind(title:String,with data : HomeV3Patch) {
        titleLbl.text  = title
        self.dataSource = data.contents
    }
    
    func viewSetup() {
        collectionView.register(AudiobookCategoriesSubCell.nib, forCellWithReuseIdentifier: AudiobookCategoriesSubCell.identifier)
        
    }
    
    func bindAudioBookCatagories(with patch:AudioPatchHome) {
        audioBookHome = patch.contents
        titleLbl.text = patch.patch.title
        pagerControl.numberOfPages = patch.contents.first?.imageModes.count ?? 1
        pagerControl.contentHorizontalAlignment = .center
        pagerControl.setFillColor( #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .selected)
    }
    func bindBookCatagoriesv3(with patch:HomeV3Patch) {
        bookv3 = patch.contents
        titleLbl.text = patch.patch.title
        pagerControl.numberOfPages = patch.contents.first?.imageModes?.count ?? 0
        pagerControl.currentPage = 0 // Reset to first page
        pagerControl.contentHorizontalAlignment = .center
        pagerControl.setFillColor( #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .selected)
    }
    
}

extension AudiobookCategoriesCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isHomeV3Content {
            return bookv3.count
        }
        return audioBookHome.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AudiobookCategoriesSubCell.identifier, for: indexPath) as? AudiobookCategoriesSubCell else{
            fatalError()
        }
       
        if isHomeV3Content {
            cell.bindDataBasedOnType(content: bookv3[indexPath.item])
        } else {
            cell.bindDataBasedOnType(content: audioBookHome[indexPath.item])
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isHomeV3Content {
            return AudiobookCategoriesSubCell.size
        }
        return AudiobookCategoriesSubCell.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = HomeSeeAllVC.instantiateNib()
        if isHomeV3Content {
            let category = bookv3[indexPath.item]
            vc.isBookCatagorisv3 = true
            vc.bookv3Contents = category
            self.navigationController()?.pushViewController(vc, animated: true)
        } else {
            let category = audioBookHome[indexPath.item]
            vc.isAudioCatagoriesData = true
            vc.audioPatchContent = category
            self.navigationController()?.pushViewController(vc, animated: true)
        }
    }
}

extension AudiobookCategoriesCell: FSPagerViewDelegate {
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.pagerControl.currentPage = targetIndex
        guard let cell = pagerView.cellForItem(at: targetIndex) as? BillboardSub else {return}
        cell.tag = targetIndex
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        self.pagerControl.currentPage = pagerView.currentIndex
        guard let cell = pagerView.cellForItem(at: pagerView.currentIndex) as? BillboardSub else {return}
        cell.tag = pagerView.currentIndex
        
    }
}
