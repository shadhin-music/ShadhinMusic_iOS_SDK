//
//  AudioBookDetailsVC.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 10/6/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

protocol ChapterCellUpdaterDelegate: AnyObject {
    func updateChapterCell(with progress: [AudioBookProgress])
}



class AudioBookDetailsVC: UIViewController, NIBVCProtocol {

    @IBOutlet weak var collectionView: UICollectionView!

    let audioPlayer = AudioPlayer.shared
    var selectedTrack: CommonContentProtocol?
    var isSummaryExpanded = false
    var AudioBookType = "BK"
    private let downloadManager = SDDownloadManager.shared
    var trackCompletion = [AudioBookProgress]()
    var reviews = [AudioBookReview]()
    var replies = [Reply]()
    var averageReview: ReviewRatingCount?
    var repliesRating: ReviewRatingCount?
    var episodes = [AudioBookContent]()
    private var initialEpisodesCount = 4
    var parentBook: ParentContent?
    private var authors = [Author]()
    private var narattors = [Narrator]()
    private var youMightLikeBooksData = [SimilerBooksData]()
    weak var vc: HomeAdapterProtocol?
    var coordinator : HomeCoordinator?
    var artistId = ""
    weak var audioCoordinator: AudioBookHomeCoordinator?
    var episodeId = ""
    var checkPlayPauseImage: ()->Void = {}
    var playTheChapter: (Int, Int)->Void = {_,_  in}
    var reviewId = ""
    var reviewPopvc = ReviewPopUpVC()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCells()
        collectionView.delegate = self
        collectionView.dataSource = self
        MusicPlayerV3.shared.delegate = self
        MusicPlayerV3.shared.coordinator = self.coordinator
        MusicPlayerV3.shared.audioDetailsVC = self
//        getAudioBookDetailsData()
//        getAudioBookReviews()
//        getYoumightLikeBooks()
//        getTracksCompletionHistory()
        if let navVc = self.navigationController{
            coordinator = HomeCoordinator(navigationController: navVc, tabBar: self.tabBarController)
        }
        NotificationCenter.default.addObserver(forName: .init(rawValue: "FavDataUpdateNotify"), object: nil, queue: .main) { notificatio in
            self.checkIsFav()
        }
        navigationController?.isNavigationBarHidden = true
        reviewPopvc.homeVC = self
        reviewPopvc.episodeId = episodeId
        print(reviewPopvc.episodeId)
    }
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        additionalSafeAreaInsets = UIEdgeInsets.zero
        collectionView.contentInsetAdjustmentBehavior = .never
    }
    var favBtn : UIButton?{
        didSet{
            self.checkIsFav()
        }
    }
    var selectedTrackID = ""{
        didSet{
            self.checkIsFav()
        }
    }
    
    
    func checkIsFav(){
        guard !selectedTrackID.isEmpty else {
            favBtn?.isHidden = true
            return
        }


        let type: SMContentType = AudioBookType.uppercased() == "BK" ? .audioBook : .podcast
        
        ShadhinCore.instance.api.getAllFavoriteByType(type: type) { [weak self] (data, error) in
            guard let self = self else {return}
            if let error = error {
                print("API error: \(error.localizedDescription)")
                self.favBtn?.isHidden = true
                return
            }

            guard let data = data else {
                print("No data received")
                self.favBtn?.isHidden = true
                return
            }

            self.favBtn?.isHidden = false
            if data.contains(where: { $0.contentID == self.selectedTrackID }) {
                self.favBtn?.tag = 1
                self.favBtn?.setImage(UIImage(named: "ic_favorite_a", in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                print("Favorite status set to selected")
            } else {
                self.favBtn?.tag = 0
                self.favBtn?.setImage(UIImage(named: "ic_favorite_n", in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                print("Favorite status set to unselected")
            }
        }
    }
    
    func addDeleteFav(){
        if favBtn?.tag == 1{
            deleteFav()
        }else{
            addFav()
        }
    }
    
    func addFav(){
       // guard let track = selectedTrack else {return}
        guard let track = parentBook?.toCommonContent() else {return}
        ShadhinCore.instance.api.addOrRemoveFromFavorite(
            content: track,
            action: .add) { (err) in
                if err != nil {
                    ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                }else {
                    self.favBtn?.tag = 1
                    self.favBtn?.setImage(UIImage(named: "ic_favorite_a",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                }
            }
    }
    
    func deleteFav(){
        guard let track = parentBook?.toCommonContent() else {return}
        ShadhinCore.instance.api.addOrRemoveFromFavorite(
            content: track,
            action: .remove) { (err) in
                if err != nil {
                    ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                }else {
                    self.favBtn?.tag = 0
                    self.favBtn?.setImage(UIImage(named: "ic_favorite_n",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                }
            }
    }
    
    private func addreplyPopupView() {
        let vc =  AddReplyPopUpVC()
        //   vc.reviewId = String(self.reviews.first?.reviewId ?? 0)
        // vc.reviewsData = reviews
        vc.vc = self
        // vc.mainbgView.backgroundColor = .red
        let height: CGFloat = 400.0
        var attributes = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 8)
        attributes.entryBackground = .color(color: .clear)
        attributes.border = .none
        // attributes.scroll = .disabled
        //attributes.screenInteraction = .absorbTouches
        var ekAttributes = EKAttributes()
        ekAttributes.entryInteraction = .absorbTouches
        
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 16, screenEdgeResistance: 20)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        //  SwiftEntryKit.dismiss()
        SwiftEntryKit.display(entry: vc, using: attributes)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // call the func to check and set play pause image inside header cell
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.checkPlayPauseImage()
        })
    }
    func setupCells() {
        collectionView.register(BookDetailsHeaderCell.nib, forCellWithReuseIdentifier: BookDetailsHeaderCell.identifier)
        collectionView.register(ChapterSubcell.nib, forCellWithReuseIdentifier: ChapterSubcell.identifier)
        collectionView.register(ReviewCell.nib, forCellWithReuseIdentifier: ReviewCell.identifier)
        collectionView.register(AuthorMultipleImgCell.nib, forCellWithReuseIdentifier: AuthorMultipleImgCell.identifier)
        collectionView.register(NarratorMultipleImgCell.nib, forCellWithReuseIdentifier: NarratorMultipleImgCell.identifier)
        collectionView.register(BookHomeCell.nib, forCellWithReuseIdentifier: BookHomeCell.identifier)
        collectionView.register(YouMightLikeCell.nib, forCellWithReuseIdentifier: YouMightLikeCell.identifier)
        collectionView.register(CommentCollectionCell.nib, forCellWithReuseIdentifier: CommentCollectionCell.identifier)
        collectionView.register(SeeAllCell.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: SeeAllCell.identifier)
        collectionView.register(ChapterHeaderCell.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ChapterHeaderCell.identifier)
    }
    
    func getAudioBookReviews() {
        guard !episodeId.isEmpty else {return}
        print(episodeId)
        ShadhinCore.instance.api.getAudioBookReviews(userCode: ShadhinCore.instance.defaults.userIdentity, episodeId: episodeId) {[weak self] responseModel in
            guard let self = self else {return}
            switch responseModel {
            case .success(let success):
                DispatchQueue.main.async {
                    self.reviews = success.data?.review ?? []
                    self.averageReview = success.data?.reviewRatingCount
                    self.collectionView.reloadData()
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func postReaction(_ index: IndexPath, reviewId: String, tobeDeted: Bool, completion: @escaping (Bool) -> Void) {
        ShadhinCore.instance.api.addReaction(reviewId, tobeDeted) { [weak self] response, error in
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
    
    // Helper function to save the state to UserDefaults
    
    
    private func getAudioBookDetailsData() {
        LoadingIndicator.initLoadingIndicator(view: self.view)
        LoadingIndicator.startAnimation()
        guard !episodeId.isEmpty else {
            print("Error: episodeId is empty")
            LoadingIndicator.stopAnimation()
            view.makeToast("Invalid audiobook data. Please try again.")
            return
        }
        print("Fetching audiobook details for episodeId: \(episodeId)")
        ShadhinCore.instance.api.getAudioBookData(episodeId: episodeId) { [weak self] responseModel in
            guard let self = self else { return }
            switch responseModel {
            case .success(let success):
                guard let data = success.data else {
                    print("Error: No data in success response for episodeId: \(self.episodeId)")
                    LoadingIndicator.stopAnimation()
                    view.makeToast("Failed to load audiobook details. Please try again.")
                    return
                }
                print("API Response: \(data)") // Log the response for debugging
                self.episodes = data.contents ?? []
                self.parentBook = data.parentContents?.first
                if let audioBook = self.parentBook?.audioBook {
                    self.authors = audioBook.authors ?? []
                    self.narattors = audioBook.narrators ?? []
                } else {
                    print("Warning: parentBook.audioBook is nil for episodeId: \(self.episodeId)")
                    self.authors = []
                    self.narattors = []
                }
                if let contents = data.contents {
                    MusicPlayerV3.shared.audioPatchContent = contents
                } else {
                    print("No contents available for episodeId: \(self.episodeId)")
                }
                LoadingIndicator.stopAnimation()
                self.collectionView.reloadData()
            case .failure(let failure):
                print("Error fetching audiobook details: \(failure)")
                if case let .responseSerializationFailed(reason) = failure {
                    print("Serialization failure reason: \(reason)")
                }
                LoadingIndicator.stopAnimation()
                self.view.makeToast("Failed to load audiobook details. Please try again.")
            }
        }
    }
    
    private func getYoumightLikeBooks(){
        guard !artistId.isEmpty else {return}
        print("\(artistId)")
        ShadhinCore.instance.api.getYouMightLikeAudioBooks(episodeId: artistId) {[weak self] responseModel in
            guard let self = self else {return}
            switch responseModel {
            case .success(let success):
                if let data = success.data {
                    self.youMightLikeBooksData = [data]
                    self.collectionView.reloadData()
                    // print(self.youMightLikeBooks.first?.parentContents as Any)
                } else {
                    self.youMightLikeBooksData = []
                }
                self.collectionView.reloadData()
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    private func getTracksCompletionHistory() {
        guard !episodeId.isEmpty else { return }
        print("Fetching audiobook details for episodeId: \(episodeId)")
        ShadhinCore.instance.api.getTrackComplrtionHistory(episodeId: episodeId) { [weak self] responseModel in
            guard let self = self else { return }
            switch responseModel {
            case .success(let success):
                if let updatedProgress = success.data {
                    self.trackCompletion = updatedProgress
                } else {
                    print("No progress data found")
                }
                MusicPlayerV3.shared.trackCompletionContent = success.data?.first
                self.collectionView.reloadData()
            case .failure(let failure):
                print("Error fetching audiobook details: \(failure)")
            }
        }
    }
    
    private func showAuthorsAndNarratorsList() {
        let vc =  AuthorAndNarratorListVC()
        vc.youMightLikeData = youMightLikeBooksData
        vc.authors = authors
        vc.narrators = narattors
        vc.coordinator = coordinator
        let height: CGFloat = 300.0
        var attributes = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 8)
        attributes.entryBackground = .color(color: .clear)
        attributes.border = .none
        _ = EKAttributes()
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 16, screenEdgeResistance: 20)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        SwiftEntryKit.dismiss()
        SwiftEntryKit.display(entry: vc, using: attributes)
    }
}


extension AudioBookDetailsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1{
            return episodes.count
        } else if section == 4 {
            return youMightLikeBooksData.count
        }
        else if section == 6 {
            return reviews.count
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookDetailsHeaderCell.identifier, for: indexPath) as? BookDetailsHeaderCell else{
                fatalError()
            }
            if averageReview == nil || averageReview?.reviewCount == nil {
                cell.ratingString = "No Rating Yet • "
            } else if let reviewCount = averageReview?.reviewCount, reviewCount == 0 {
                cell.ratingString = "No Rating Yet • "
            } else {
                let ratingAverage = averageReview?.ratingAverage ?? 0
                let reviewCount = averageReview?.reviewCount ?? 0
                cell.ratingString = "\(ratingAverage) (\(reviewCount)) • "
            }

            self.favBtn = cell.favBtn
            cell.onTap = { [weak self] in
                guard let self = self else {return}
                self.addDeleteFav()
            }
            
            cell.dismiss = {[weak self]  in
                self?.navigationController?.popViewController(animated: true)
            }
            if let parentBook {
                cell.bind(data: parentBook)
                cell.authors = authors.compactMap({$0.name}).joined(separator: ", ")
                cell.dismiss = {[weak self]  in
                    self?.navigationController?.popViewController(animated: true)
                }
            }
            if let averageReview {
                cell.bindReviewData(data: averageReview)
            }
            checkPlayPauseImage = cell.playPauseSetImageHandler
            cell.vc = self
            playTheChapter = cell.startAudioFrom(index: startAudioFrom: )
            cell.seektoCurrentCursor = trackCompletion.first?.currentDurationCursor ?? 0
            return cell
        }
        
        else if indexPath.section == 1 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChapterSubcell.identifier, for: indexPath) as? ChapterSubcell else{
                fatalError()
            }
            let downloadData = episodes[indexPath.item].toCommonContent()
//            cell.checkAudioBookIsDownloading(data: downloadData)
            
            cell.didThreeDotMenuTapped {
                            
                let menu = MoreMenuVC()
                let data = self.episodes[indexPath.item].toCommonContent()
                menu.data = data
                menu.delegate = self
                menu.menuType = .Podcast
                menu.openForm = .Podcast
//                menu.clickRemoveDownloaded = {
//                    cell.removeDownalodedSong()
//                }
                let height = MenuLoader.getHeightFor(vc: .Podcast, type: .Podcast, operators: [])
                var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 0)
                attribute.entryBackground = .color(color: .clear)
                attribute.border = .none
                SwiftEntryKit.display(entry: menu, using: attribute)
            }
            
            if trackCompletion.first?.completionPercentage == nil {
                cell.progressView.isHidden = true
            }
            
            else if indexPath.item < trackCompletion.count {
                cell.progressView.isHidden = true
                cell.dataBindProgressComplete(data: trackCompletion[indexPath.item])
            }
            
            else {
                cell.progressView.isHidden = true
                print("Index out of range for trackCompletion at \(indexPath.item)")
            }
            cell.bind(data: episodes[indexPath.item])
            cell.onThreeDotTap = onThreeDotTap
            if let parentBook {
                cell.setImage(urlString: parentBook.imageUrl ?? "")
            }
            return cell
        }
        
        else if indexPath.section == 2 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AuthorMultipleImgCell.identifier, for: indexPath) as? AuthorMultipleImgCell else {
                fatalError()
            }
            cell.bgView.roundCorners(corners: [.topLeft, .topRight], radius: 12)
            cell.authorsBindData(authors: authors)
            return cell
        } else if indexPath.section == 3 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NarratorMultipleImgCell.identifier, for: indexPath) as? NarratorMultipleImgCell else {
                fatalError()
            }
            cell.bgView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12)
            cell.narratorsBindData(narrators: narattors)
            if narattors.count == 0 {
               cell.isHidden = true
            } else {
                cell.isHidden = false
            }
            return cell
        }
        else if indexPath.section == 4 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YouMightLikeCell.identifier, for: indexPath) as? YouMightLikeCell else {
                fatalError()
            }
            cell.seeAll.isHidden = true
            cell.youMightData = youMightLikeBooksData.first?.contents ?? []
            return cell
        }
        
        else if indexPath.section == 5 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCell.identifier, for: indexPath) as? ReviewCell else{
                fatalError()
            }
            if reviews.indices.contains(indexPath.item) {
                let reviews = reviews[indexPath.item]
                cell.reviws = reviews
            }
            cell.audioVC = self
            if reviews.count == 0 {
                cell.bindDataNoRevies()
            }
            if let averageReview {
                cell.bindData(data: averageReview)
            }
            return cell
        }
        
        else if indexPath.section == 6 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCollectionCell.identifier, for: indexPath) as? CommentCollectionCell else{
                fatalError()
            }
            var review = self.reviews[indexPath.item]
            // Configure the initial state based on reactionCount
            let initialFavoriteImage = (review.reactionCount ?? 0) > 0 ? UIImage(named: "ic_mymusic_favorite",in: Bundle.ShadhinMusicSdk,compatibleWith: nil) : UIImage(named: "ic_favorite_border",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            cell.reactionBtn.setImage(initialFavoriteImage, for: .normal)
            
            // Define the action when the button is tapped
            cell.onTap = { [weak self] in
                guard let self = self else { return }
                
                if ConnectionManager.shared.isNetworkAvailable {
                    if ShadhinCore.instance.isUserLoggedIn && ShadhinCore.instance.isUserPro {
                        let toBeDeleted = review.isFavorite
                        self.postReaction(indexPath, reviewId: String(review.reviewId ?? 0), tobeDeted: toBeDeleted) { success in
                            if success {
                                // Toggle `isFavorite` and update `reactionCount` based on the API call success
                                review.isFavorite.toggle()
                                review.reactionCount = toBeDeleted ? (review.reactionCount ?? 0) - 1 : (review.reactionCount ?? 0) + 1
                                // Set the new image and update the reaction count label
                                let updatedImage = review.isFavorite ? UIImage(named: "ic_mymusic_favorite",in: Bundle.ShadhinMusicSdk,compatibleWith: nil) : UIImage(named: "ic_favorite_border",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                                cell.reactionBtn.setImage(updatedImage, for: .normal)
                                cell.reactionCountLabel.text = "\(review.reactionCount ?? 0)"
                            } else {
                                print("Failed to update reaction.")
                            }
                        }
                        
                    } else if !ShadhinCore.instance.isUserPro {
                        SubscriptionPopUpVC.show(self)
                    }
                }
            }
            
            cell.onTap = {[weak self] in
                guard let self = self else {return}
                if ConnectionManager.shared.isNetworkAvailable{
                    if ShadhinCore.instance.isUserLoggedIn && ShadhinCore.instance.isUserPro {
                        // Call the API and handle UI updates based on success
                        let toBeDeleted = review.isFavorite
                        self.postReaction(indexPath, reviewId: String(review.reviewId ?? 0), tobeDeted: toBeDeleted) { success in
                            if success {
                                // Update the favorite status and reaction count based on action
                                review.isFavorite.toggle() // Switch favorite status
                                review.reactionCount = toBeDeleted ? (review.reactionCount ?? 0) - 1 : (review.reactionCount ?? 0) + 1
                                // Update the cell's UI
                                let favoriteImage = review.isFavorite ? UIImage(named: "ic_mymusic_favorite",in: Bundle.ShadhinMusicSdk,compatibleWith: nil) : UIImage(named: "ic_favorite_border",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                                cell.reactionBtn.setImage(favoriteImage, for: .normal)
                                cell.reactionCountLabel.text = "\(review.reactionCount ?? 0)"
                            } else {
                                self.view.makeToast("Failed to submit reaction.")
                            }
                        }
                    } else if !ShadhinCore.instance.isUserPro {
                        SubscriptionPopUpVC.show(self)
                    }
                }
            }
            
            if (review.replyCount ?? 0) > 0 {
                cell.replyButton.isHidden = false
                cell.replyButton.setTitle("(\(reviews.first?.replyCount ?? 0)) replies", for: .normal)
            }
            cell.replyButton.setClickListener {
                guard ShadhinCore.instance.isUserPro else {
                   return SubscriptionPopUpVC.show(self)
                }
                // self.addreplyPopupView()
                let vc =  AddReplyPopUpVC()
                vc.reviewId = String(review.reviewId ?? 0)
                vc.reviewsData = review
                vc.vc = self
                let height: CGFloat = 400.0
                var attributes = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 8)
                attributes.entryBackground = .color(color: .clear)
                attributes.border = .none
                // attributes.scroll = .disabled
                //attributes.screenInteraction = .absorbTouches
                var ekAttributes = EKAttributes()
                ekAttributes.entryInteraction = .absorbTouches
                
                let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 16, screenEdgeResistance: 20)
                let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
                attributes.positionConstraints.keyboardRelation = keyboardRelation
                SwiftEntryKit.dismiss()
                SwiftEntryKit.display(entry: vc, using: attributes)
            }
            
            cell.replybtnAlwasy.setClickListener {
                guard ShadhinCore.instance.isUserPro else {
                    return SubscriptionPopUpVC.show(self)
                }
                let vc =  AddReplyPopUpVC()
                vc.reviewId = String(review.reviewId ?? 0)
                vc.reviewsData = review
                vc.vc = self
                let height: CGFloat = (review.replyCount == 0) ? 200.0 : 400.0
                var attributes = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 8)
                attributes.entryBackground = .color(color: .clear)
                attributes.border = .none
                // attributes.scroll = .disabled
                //attributes.screenInteraction = .absorbTouches
                var ekAttributes = EKAttributes()
                ekAttributes.entryInteraction = .absorbTouches
                
                let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 16, screenEdgeResistance: 20)
                let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
                attributes.positionConstraints.keyboardRelation = keyboardRelation
                //  SwiftEntryKit.dismiss()
                SwiftEntryKit.display(entry: vc, using: attributes)
            }
            cell.bindData(data: reviews[indexPath.item])
            return cell
        }
        
        
        else {
            return UICollectionViewCell()
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return isSummaryExpanded ? BookDetailsHeaderCell.sizeExpanded : BookDetailsHeaderCell.size
        } else if indexPath.section == 1 {
            return ChapterSubcell.size
        } else if indexPath.section == 2 {
            return AuthorMultipleImgCell.size
        }  else if indexPath.section == 3 {
            return narattors.isEmpty ? NarratorMultipleImgCell.sizeNoNarrtor : NarratorMultipleImgCell.size
        }
        else if indexPath.section == 4 {
            return YouMightLikeCell.size
        } else if indexPath.section == 5 {
            return ReviewCell.size
        } else if indexPath.section == 6 {
            let review = self.reviews[indexPath.item]
            if (review.replyCount == 0) {
                return CommentCollectionCell.sizeForNoReplies()
            }
            return CommentCollectionCell.size(textHeight: (reviews[indexPath.item].description ?? "").heightOfAttributedString(withFont: .init(name: "OpenSans-Regular", size: 12.0) ?? .init(), width: SCREEN_WIDTH - (7.0 + 40.0 + 32.0)))
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 1{
            if kind == UICollectionView.elementKindSectionHeader {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ChapterHeaderCell.identifier, for: indexPath) as! ChapterHeaderCell
                return header
            } else if kind == UICollectionView.elementKindSectionFooter {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SeeAllCell.identifier, for: indexPath) as! SeeAllCell
                footer.seeAllParentView.layer.borderWidth = 1
                footer.seeAllParentView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
                return footer
            }
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 1 {
            return ChapterHeaderCell.size
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // Set zero insets for sections 2 and 3
        if section == 2 || section == 3 {
            return UIEdgeInsets.zero
        } else if section == 5 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 18, right: 0)
        } else if section == 6 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 64, right: 0)
        }
        // Default insets for other sections
        return UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        // No line spacing for sections 2 and 3
        if section == 2 || section == 3 {
            return 0
        }
        // Default line spacing for other sections
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        // No inter-item spacing for sections 2 and 3
        if section == 2 || section == 3 {
            return 0
        }
        // Default inter-item spacing for other sections
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath.section == 2 {
            if authors.count == 1 {
                let vc = AuthorAndNarratorDetailsVC()
                vc.authorId = authors.compactMap { "\($0.id ?? 0)" }.joined(separator: " ")
                vc.isAuthorVisible = true
                vc.youMightLikeBooksData = youMightLikeBooksData
                navigationController?.pushViewController(vc, animated: false)
            } else {
                // showAuthorsAndNarrators()
                self.view.makeToast("No Author Available")
            }
        } else if indexPath.section == 3 {
            if let firstNarrator = narattors.first, narattors.count == 1 {
                let vc = AuthorAndNarratorDetailsVC()
                vc.authorId = "\(firstNarrator.id ?? 0)" // Assuming `id` is an `Int`, convert it to `String`.
                vc.youMightLikeBooksData = youMightLikeBooksData
                vc.isNarratorVisible = true
                navigationController?.pushViewController(vc, animated: false)
            }
//            // Narrator count is 2 then we will show NarratorList
//            if narattors.count == 0 {
//                self.view.makeToast("No Narrator Available")
//            }
            if narattors.count > 2 {
                showAuthorsAndNarratorsList()
            }
        } else if indexPath.section == 1 {
            // Play the chapter
            if ShadhinCore.instance.isUserLoggedIn {
                if ShadhinCore.instance.isUserPro {
                    if trackCompletion.indices.contains(indexPath.item),
                       let currentCursor = trackCompletion[indexPath.item].currentDurationCursor {
                        playTheChapter(indexPath.item, currentCursor)
                    } else {
                        playTheChapter(indexPath.item, 0)
                    }
                } else {
                    SubscriptionPopUpVC.show(self)
                }
            }
        }

    }
}


extension AudioBookDetailsVC: MoreMenuDelegate {
    func openQueue() {
        
    }
    
    
    func onDownload(content: CommonContentProtocol, type: MoreMenuType) {
        guard try! Reachability().connection != .unavailable else {return}
        
        //send data to firebase analytics
        AnalyticsEvents.downloadEvent(with: content.contentType, contentID: content.contentID, contentTitle: content.title)
        //send download info to server
        ShadhinApi().downloadCompletePost(model: content)
        
        guard let url = URL(string: content.playUrl?.decryptUrl() ?? "") else {
            return self.view.makeToast("Unable to get Download file Url")
        }
        
        self.view.makeToast("Downloading \(String(describing: content.title ?? ""))")

        let request = URLRequest(url: url)
        let _ = self.downloadManager.downloadFile(withRequest: request, onCompletion: { error, url in
            if error != nil{
                self.view.makeToast(error?.localizedDescription)
            } else {
                
//                self.showDownloadStatusView(title: "Downloaded", isDownloadBtnShow: true, coordinator: self.coordinator)
                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
//                    self.hideDownloadStatusView()
//                }
                
                self.collectionView.reloadData()
            }
        })
        collectionView.reloadData()
        
    }
    
    func onRemoveDownload(content: CommonContentProtocol, type: MoreMenuType) {
        DatabaseContext.shared.removePodcast(with: content.contentID  ?? "")
        if let playUrl = content.playUrl{
            SDFileUtils.removeItemFromDirectory(urlName: playUrl)
            self.view.makeToast("File Removed from Download")
        }
        collectionView.reloadData()
    }
    
    func onRemoveFromHistory(content: CommonContentProtocol) {
        
    }
    
    func gotoArtist(content: CommonContentProtocol) {
        
    }
    
    func gotoAlbum(content: CommonContentProtocol) {
        
    }
    
    func addToPlaylist(content: CommonContentProtocol) {
        
    }
    
    func shareMyPlaylist(content: CommonContentProtocol) {
        
    }
    
    func openQueue(_ content: CommonContentProtocol) {
        
    }

    func openSleepTimer() {
        
    }
    
    private func onThreeDotTap(book: CommonContentProtocol) {
        var chapter = book
        let menu = MoreMenuVC()
        
        
        chapter.artist = authors.compactMap({$0.name}).joined(separator: ", ")
        
        
        menu.data = chapter
        menu.delegate = self
        
        var height : CGFloat = 0
        let tt = SMContentType(rawValue: book.contentType)
        
        if tt == .audioBook {
            menu.menuType = .AudioBook
            menu.openForm = .AudioBook
            height = MenuLoader.getHeightFor(vc: .AudioBook, type: .AudioBook, operators: [])
        } else {
            return
        }
        
        var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 0)
        attribute.entryBackground = .color(color: .clear)
        attribute.border = .none
        SwiftEntryKit.display(entry: menu, using: attribute)
    }
}

extension AudioBookDetailsVC: ChapterCellUpdaterDelegate {
    func updateChapterCell(with progress: [AudioBookProgress]) {
        // Update the data source
        DispatchQueue.main.async {
            self.trackCompletion = progress
            print(self.trackCompletion)
            self.collectionView.reloadData()
        }
    }
}




extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

extension Notification.Name {
    static let reviewUpdated = Notification.Name("reviewUpdated")
}


