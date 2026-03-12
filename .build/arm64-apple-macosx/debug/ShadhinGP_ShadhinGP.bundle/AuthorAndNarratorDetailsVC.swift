//
//  AuthorDetailsVC.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 27/8/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class AuthorAndNarratorDetailsVC: UIViewController {
    private var favs = "-1"
    private var artistFollow = ""
    @IBOutlet weak var collectionView: UICollectionView!
    weak var coordinator : HomeCoordinator?
    weak var audioCoordinator: AudioBookHomeCoordinator?
    var authorId = ""
    var isAuthorVisible = false
    var isNarratorVisible = false
    var authorAndNarratorData = [AuthorDetailsDataClass]()
    var authorData: Author?
    var narratorData: Narrator?
    private var audioBooks = [AuthorDetailsDataClass]()
    private var youMightLikeAudioBooks = [AuthorDetailsDataClass]()
    var youMightLikeBooksData = [SimilerBooksData]()
    var isSummaryExpanded = false
    var authorSData:AuthorDetailsParentContent?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCells()
        getData()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        additionalSafeAreaInsets = UIEdgeInsets.zero
        collectionView.contentInsetAdjustmentBehavior = .never
    }
    private func setupCells() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(AuthorDetailsHeaderCell.nib, forCellWithReuseIdentifier: AuthorDetailsHeaderCell.identifier)
        collectionView.register(ChapterSubcell.nib, forCellWithReuseIdentifier: ChapterSubcell.identifier)
        collectionView.register(BookHomeCell.nib, forCellWithReuseIdentifier: BookHomeCell.identifier)
        collectionView.register(YouMightLikeCell.nib, forCellWithReuseIdentifier: YouMightLikeCell.identifier)
        collectionView.register(ChapterHeaderCell.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ChapterHeaderCell.identifier)
    }
    
    func addFollowApiCall(content:AuthorDetailsParentContent, _ completion: @escaping (Bool) -> Void) {
        ShadhinCore.instance.api.addFollow(content){ [weak self] response, error in
            guard let self = self else {return}
            if let response = response, response.success {
                completion(true) // Call completion with success
            } else {
                print("Failed to submit reaction: \(error ?? "Unknown error")")
                self.view.makeToast(error ?? "Failed to submit reaction.")
                completion(false) // Call completion with failure
            }
        }
    }
    func addUnfollowApiCall(content:String,completion:@escaping(Bool)->Void) {
        ShadhinCore.instance.api.addUnfollow(content){ [weak self] response, error in
            guard let self = self else {return}
            if let response = response, response.success {
                completion(true) // Call completion with success
            } else {
                print("Failed to submit reaction: \(error ?? "Unknown error")")
                self.view.makeToast(error ?? "Failed to submit reaction.")
                completion(false) // Call completion with failure
            }
        }
    }
    
    private func getData() {
        getAuthorDetails()
    }
    private func getAuthorDetails() {
        guard !authorId.isEmpty else { return }
        print("\(authorId)")
        
        ShadhinCore.instance.api.getAuthorDetails(artistId: authorId) { [weak self] response in
            guard let self = self else { return }
            
            switch response {
            case .success(let success):
                DispatchQueue.main.async { // Ensure UI updates happen on the main thread
                    self.authorAndNarratorData = [success.data]
                    print("Author and Narrator Data: \(self.authorAndNarratorData)")
                    self.audioBooks = [success.data]
                    self.youMightLikeAudioBooks = [success.data]
                    self.collectionView.reloadData()
                }
                
            case .failure(let failure):
                DispatchQueue.main.async {
                    print("Failed to get author details: \(failure)")
                }
            }
        }
    }
    
}

extension AuthorAndNarratorDetailsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1{
            return audioBooks.count
        }else if section == 2 {
            return youMightLikeBooksData.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AuthorDetailsHeaderCell.identifier, for: indexPath) as? AuthorDetailsHeaderCell else{
                fatalError()
            }
            cell.vc = self
            cell.dismiss = {[weak self]  in
                self?.navigationController?.popViewController(animated: true)
            }
            if authorAndNarratorData.indices.contains(indexPath.section) {
                let author = authorAndNarratorData[indexPath.section].parentContents[indexPath.item]
                let narrator = authorAndNarratorData[indexPath.section].parentContents[indexPath.item]
                if isAuthorVisible {
                    cell.dataBindAuthor(authors: author)
                } else if isNarratorVisible {
                    cell.dataBindNarrator(narrators: narrator)
                    
                }
            }
           
            cell.followTapped = { [weak self] in
                guard let self = self else { return }
                if ConnectionManager.shared.isNetworkAvailable {
                    if ShadhinCore.instance.isUserLoggedIn && ShadhinCore.instance.isUserPro {
                        // Toggle follow state
                        cell.isFollow.toggle()
                        guard let contents = self.authorAndNarratorData.first?.parentContents, !contents.isEmpty else {
                            print("No contents available")
                            return
                        }
                        if cell.isFollow {
                            if let content = contents.first {
                                self.addFollowApiCall(content: content) { success in
                                    if success {
                                        DispatchQueue.main.async {
                                            FavoriteCacheDatabase.intance.addContent(content: content.toCommonContent())
                                            cell.followBtn.setTitle("Following", for: .normal)
                                            // Update followers count
                                            cell.followersCountLbl.text = "\(content.likeCount + 1) Followers"
                                        }
                                    }
                                }
                            }
                        } else {
                            if let content = contents.first {
                                self.addUnfollowApiCall(content: String(content.contentId)) { success in
                                    if success {
                                        DispatchQueue.main.async {
                                            FavoriteCacheDatabase.intance.deleteContent(content: content.toCommonContent())
                                            cell.followBtn.setTitle("Follow", for: .normal)
                                            cell.followersCountLbl.text = "\(content.likeCount - 1) Followers"
                                        }
                                    }
                                }
                            }
                        }
                        
                    } else if !ShadhinCore.instance.isUserPro {
                        SubscriptionPopUpVC.show(self)
                    }
                }

            }
            return cell
        }
        
        else if indexPath.section == 1 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookHomeCell.identifier, for: indexPath) as? BookHomeCell else{
                fatalError()
            }
//            cell.bindFromDetails(books: audioBooks[0].contents)
            cell.isActiveAuthotDetails = true
            cell.isAuthorDetailsAudioBook = true
            cell.authorDetailsAudioBookData = audioBooks
            cell.onItemClick = {[weak self ] item in
                guard let self = self else {return}
                Log.info("\(item)")
               // coordinator?.goToAudioBook(content: item)
                audioCoordinator?.goToAudioBook(content: item)
            }
            return cell
        }
        
        else if indexPath.section == 2 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YouMightLikeCell.identifier, for: indexPath) as? YouMightLikeCell else{
                fatalError()
            }
            cell.youMightData = youMightLikeBooksData.first?.contents ?? []
            return cell
        }
        
        else {
            return UICollectionViewCell()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return isSummaryExpanded ? AuthorDetailsHeaderCell.sizeExpanded : AuthorDetailsHeaderCell.size
        } else if indexPath.section == 1 {
            return BookHomeCell.size
        } else if indexPath.section == 2 {
            return YouMightLikeCell.size
        }
        return .zero
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        UIEdgeInsets(top: 0, left: 0, bottom: 10 , right: 0) // Insets for other sections
    }
    
}


extension Notification.Name {
    static let followStateChanged = Notification.Name("followStateChanged")
}
