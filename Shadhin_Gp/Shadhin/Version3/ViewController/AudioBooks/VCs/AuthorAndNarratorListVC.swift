//
//  AuthorsVC.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 25/8/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class AuthorAndNarratorListVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var narrators = [Narrator]()
    var authors = [Author]()
    var youMightLikeData = [SimilerBooksData]()
    weak var coordinator: HomeCoordinator?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCells()
    }
    
    
    func setupCells() {
        collectionView.register(AuthorAndNarratorCell.nib, forCellWithReuseIdentifier: AuthorAndNarratorCell.identifier)
        collectionView.register(ChapterHeaderCell.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ChapterHeaderCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}


extension AuthorAndNarratorListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else if section == 1 {
            if authors.count >= 2 {
                return authors.count
            } else {
                return narrators.count
            }
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //if indexPath.section == 1 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AuthorAndNarratorCell.identifier, for: indexPath) as? AuthorAndNarratorCell else{
                fatalError()
            }
            //TODO: - Book Numbers Should Come From API
        if authors.count >= 2 {
            cell.bindAuthorList(authors: authors)
            } else {
                cell.bindNarratorList(narrators: narrators)
            }
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return AuthorAndNarratorCell.size
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            if kind == UICollectionView.elementKindSectionHeader {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ChapterHeaderCell.identifier, for: indexPath) as! ChapterHeaderCell
                if authors.count >= 2 {
                    header.chapterLbl.text = "Authors"
                } else {
                    header.chapterLbl.text = "Narrators"
                }
                 //   header.bindForNarrator(narrator:narrators[indexPath.item])
            
                return header
            }
        }
        return UICollectionReusableView()
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return ChapterHeaderCell.size
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
        
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 10 , right: 0) // Insets for other sections
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        gotoDetailsNarrator()
    }
    
    private func gotoDetailsNarrator() {
        if let id = narrators.first?.id {
            SwiftEntryKit.dismiss() {
                self.coordinator?.gotoNarratorDetails(id: String(id), content: self.youMightLikeData)
            }
        }
    }
}
