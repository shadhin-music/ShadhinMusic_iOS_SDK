//
//  AddReplyPopUpVC.swift
//  Shadhin
//
//  Created by Maruf on 3/11/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class AddReplyPopUpVC: UIViewController {
    
    @IBOutlet weak var favBtn: UIButton!
    
    @IBOutlet weak var reactionLblCount: UILabel!
    @IBOutlet weak var commentTxt: UITextField!
    @IBOutlet weak var commentBtn: UIImageView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var proPicImg: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainbgView: UIView!
    var replies = [Reply]()
    var reviewId = ""
    var reviewsData: AudioBookReview?
    weak var vc: AudioBookDetailsVC!
    weak var reviewVC:ReviewPopUpVC!
    override func viewDidLoad() {
        super.viewDidLoad()
        mainbgView.layer.cornerRadius = 20
        mainbgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        mainbgView.clipsToBounds = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(RepliesCell.nib, forCellWithReuseIdentifier: RepliesCell.identifier)
//        repliesDataBind(data:reviewsData[0])
        postcommentBtnReplies()
        getAudioBookReplies()
        if let reviewsData {
            updateView(with: reviewsData)
        }
    }
  
    func updateView(with reviewsData: AudioBookReview) {
        // Update labels with data from reviewsData
        userNameLbl.text = reviewsData.fullName
        descriptionLbl.text = reviewsData.description
        timeLbl.text = reviewsData.createdDate?.toDate()?.timeAgoDisplay()
        reactionLblCount.text = String(reviewsData.reactionCount ?? 0)
        
        // Update the favorite button image based on isFavorite status
        let initialFavoriteImage = (reviewsData.reactionCount ?? 0) > 0 ? UIImage(named: "ic_mymusic_favorite",in: Bundle.ShadhinMusicSdk,compatibleWith: nil) : UIImage(named: "ic_favorite_border",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        favBtn.setImage(initialFavoriteImage, for: .normal)
        // Add action to favorite button
        favBtn.setClickListener { [weak self] in
            guard let self = self else { return }
            if ConnectionManager.shared.isNetworkAvailable {
                if ShadhinCore.instance.isUserLoggedIn && ShadhinCore.instance.isUserPro {
                    // api call
                    let toBeDeleted = reviewsData.isFavorite
                    var reviewsData = reviewsData
                    self.postReaction(String(reviewsData.reviewId ?? 0),toBeDeleted) { success in
                        if success {
                            // Toggle `isFavorite` and update `reactionCount` based on the API call success
                            reviewsData.isFavorite.toggle()
                            reviewsData.reactionCount = toBeDeleted ? (reviewsData.reactionCount ?? 0) - 1 : (reviewsData.reactionCount ?? 0) + 1
                            // Set the new image and update the reaction count label
                            let updatedImage = reviewsData.isFavorite ? UIImage(named: "ic_mymusic_favorite",in: Bundle.ShadhinMusicSdk,compatibleWith: nil) : UIImage(named: "ic_favorite_border",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                            self.favBtn.setImage(updatedImage, for: .normal)
                            self.reactionLblCount.text = "\(reviewsData.reactionCount ?? 0)"
                        } else {
                            print("Failed to update reaction.")
                        }
                    }
                } else if !ShadhinCore.instance.isUserPro {
                    SubscriptionPopUpVC.show(self)
                }
            }
        }

    }
    
    func postReaction(_ reviewId: String, _ tobeDeted: Bool, _ completion: @escaping (Bool) -> Void) {
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
    
    private func getAudioBookReplies() {
       guard !reviewId.isEmpty else {return}
       print(reviewId)
        ShadhinCore.instance.api.getAudioBookReplies(userCode: ShadhinCore.instance.defaults.userIdentity, reviewId:reviewId) {[weak self] responseModel in
           guard let self = self else {return}
           switch responseModel {
           case .success(let success):
               DispatchQueue.main.async {
                   self.replies = success.data
                   self.collectionView.reloadData()
               }
           case .failure(let failure):
               print(failure.localizedDescription)
           }
       }
   }
     func repliesDataBind(data:AudioBookReview) {
        userNameLbl.text = data.fullName
        descriptionLbl.text = data.description
        timeLbl.text =  data.createdDate?.toDate()?.timeAgoDisplay()
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        if let reviewsData {
            SwiftEntryKit.dismiss {
                NotificationCenter.default.post(name: .reviewUpdated, object: nil, userInfo: ["updatedReview": reviewsData])
            }
        }
    }


    private func postcommentBtnReplies() {
        commentBtn.setClickListener {
            // Ensure that the necessary fields are filled out
            guard let description = self.commentTxt.text, !description.isEmpty else {
                self.view.makeToast("Review text cannot be empty.")
                return
            }
            
            // Create a new review object with updated fields
            let newReplies = AudioBookReviewReplyRequest(
                description: description,
                fullName: ShadhinCore.instance.defaults.userName,
                imageUrl: ShadhinCore.instance.defaults.userProPicUrl,
                reviewId: self.reviewsData?.reviewId ?? 0,
                usercode: ShadhinCore.instance.defaults.userIdentity
            )
            // Call the addReview API function
            ShadhinCore.instance.api.addReplies(newReplies) { response, error in
                if let response = response, response.success {
                    print("Review submitted successfully!")
                  //  self.vc.reviewId = String(self.reviewsData?.reviewId ?? 0)
                    self.getAudioBookReplies()
                    SwiftEntryKit.dismiss()
                    self.view.makeToast("Review submitted successfully!")
                } else {
                    print("Failed to submit review: \(error ?? "Unknown error")")
                    // Optionally, show an alert to the user
                    self.view.makeToast(error ?? "Failed to submit review.")
                }
            }
        }
    }
    
}

extension AddReplyPopUpVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        replies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RepliesCell.identifier, for: indexPath) as? RepliesCell else{
            fatalError()
        }
        if let reviewVC = reviewVC {
            if reviewVC.isReviewVCOpen {
                cell.drawRating(rating: Int(Double(reviewVC.reviews.first?.rating ?? 0.0)))
            }
        } else {
            cell.drawRating(rating: Int(Double(vc.reviews.first?.rating ?? 0.0)))
        }
        cell.dataBind(data:replies[indexPath.item])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return RepliesCell.size
    }
    
    
}

