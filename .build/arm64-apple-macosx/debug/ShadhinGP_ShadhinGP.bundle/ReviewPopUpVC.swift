//
//  ReviewPopUpVC.swift
//  Shadhin
//
//  Created by Maruf on 3/11/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class ReviewPopUpVC: UIViewController {
    @IBOutlet weak var totalRatings: UILabel!
    @IBOutlet weak var avgRating: UILabel!
    var reviews = [AudioBookReview]()
    var averageReview: ReviewRatingCount?
    var isReviewVCOpen:Bool = false
    @IBOutlet weak var dismissView: UIView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var handleAreaComment: UIView!
    @IBOutlet weak var mainbgView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var tapGestureRecognizer: UITapGestureRecognizer!
    var panGestureRecognizer: UIPanGestureRecognizer!
    var headerHeightConstant : CGFloat = 42
    var contentType = "BK"
    var episodeID = 0
//    var episodeId = ""
    var frame: CGRect = .zero
    var isFromPlayer = false
    unowned var homeVC: AudioBookDetailsVC?
    var episodeId = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        handleAreaComment.layer.cornerRadius = 12
        handleAreaComment.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        handleAreaComment.clipsToBounds = true
        collectionView.register(CommentCollectionCell.nib, forCellWithReuseIdentifier: CommentCollectionCell.identifier)
        collectionView.register(ReviewCell.nib, forCellWithReuseIdentifier: ReviewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource  = self
        
        // Do any additional setup after loading the view.
        if isFromPlayer{
            self.view.frame = frame
            self.view.clipsToBounds = true
            self.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            self.handleAreaComment.addGestureRecognizer(tapGestureRecognizer)
            self.view.addGestureRecognizer(panGestureRecognizer)
        }
        handleAreaComment.layer.cornerRadius = 12 // Adjust the radius as needed
        handleAreaComment.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Top-left and top-right corners
      //  handleAreaComment.clipsToBounds = true // Ens
        handleAreaComment.isHidden = false
        headerHeightConstraint.constant = headerHeightConstant
        dismissView.isHidden = true
        mainbgView.backgroundColor = .clear
        getAudioBookReviews()
    }
    
    
    func postReaction(_ index: IndexPath, reviewId: String, tobeDeted: Bool, completion: @escaping (Bool) -> Void) {
        ShadhinCore.instance.api.addReaction(reviewId, tobeDeted) { response, error in
            if let response = response, response.success {
                completion(true) // Call completion with success
            } else {
                print("Failed to submit reaction: \(error ?? "Unknown error")")
                self.view.makeToast(error ?? "Failed to submit reaction.")
                completion(false) // Call completion with failure
            }
        }
    }
    
    
    func getAudioBookReviews() {
        guard !episodeId.isEmpty else {
            print("Episode ID is either nil or empty.")
            return
        }
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
    
}

extension ReviewPopUpVC:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return reviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCell.identifier, for: indexPath) as? ReviewCell else{
                fatalError()
            }
            if reviews.indices.contains(indexPath.item) {
                let reviews = reviews[indexPath.item]
                cell.reviws = reviews
            }
            cell.reviewvC = self
            if reviews.count == 0 {
                cell.bindDataNoRevies()
            }
            if let averageReview {
                cell.bindData(data: averageReview)
            }
            return cell
        }
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
            // self.addreplyPopupView()
            let vc =  AddReplyPopUpVC()
            vc.reviewId = String(review.reviewId ?? 0)
            vc.reviewsData = review
            vc.reviewVC = self
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
            let vc =  AddReplyPopUpVC()
            vc.reviewId = String(review.reviewId ?? 0)
            vc.reviewsData = review
            vc.reviewVC = self
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return ReviewCell.size
        }
        let review = self.reviews[indexPath.item]
        if (review.replyCount == 0) {
            return CommentCollectionCell.sizeForNoReplies()
        }
        return CommentCollectionCell.size(textHeight: (reviews[indexPath.item].description ?? "").heightOfAttributedString(withFont: .init(name: "OpenSans-Regular", size: 12.0) ?? .init(), width: SCREEN_WIDTH - (7.0 + 40.0 + 32.0)))
        
    }
}
