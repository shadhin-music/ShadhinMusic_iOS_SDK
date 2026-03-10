//
//  AddABookReviewVC.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 25/6/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class AddABookReviewVC: UIViewController, UITextViewDelegate {
    var selectedRating: Float = 5.0
    @IBOutlet var starsImageViews: [UIButton]!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var closeImage: UIImageView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    var reviews: AudioBookReview?
    weak var vc: AudioBookDetailsVC!
    weak var reviewVC: ReviewPopUpVC!
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCornerRadius()
        textView.delegate = self
        closeImage.setClickListener {
            SwiftEntryKit.dismiss()
        }
    }
    
    @IBAction func starClicked(_ sender: UIButton) {
        let clickedStarIndex = sender.tag
        selectedRating = Float(clickedStarIndex + 1)
        for (index, button) in starsImageViews.enumerated() {
            if index <= clickedStarIndex {
                button.setImage(UIImage(named: "star-filled-blue", in: Bundle.ShadhinMusicSdk, compatibleWith: nil), for: .normal)
            } else {
                button.setImage(UIImage(named: "star-empty", in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
            }
        }
    }
    
    @IBAction func submitBtnAction(_ sender: Any) {
        if let reviewVC = reviewVC {
            if reviewVC.isReviewVCOpen {
                // If reviewVC is not nil, perform actions for the reviewVC case
                guard let description = textView.text, !description.isEmpty else {
                    self.view.makeToast("Review text cannot be empty.")
                    return
                }
                // Create a new review object with updated fields
                let newReview = AudioBookReviews(
                    bookEpisodeId: Int(reviewVC.episodeId) ?? 0,
                    description: description,
                    fullName: ShadhinCore.instance.defaults.userName,
                    imageUrl: ShadhinCore.instance.defaults.userProPicUrl.image300,
                    rating: selectedRating,
                    usercode: ShadhinCore.instance.defaults.userIdentity
                )
                
                // Call the addReview API function
                LoadingIndicator.initLoadingIndicator(view:self.view)
                LoadingIndicator.startAnimation()
                ShadhinCore.instance.api.addReview(newReview) { response, error in
                    if let response = response, response.success {
                        DispatchQueue.main.async {
                            self.reviewVC.getAudioBookReviews()
                            self.reviewVC.collectionView.reloadData()
                        }
                        SwiftEntryKit.dismiss()
                        self.view.makeToast("Review submitted successfully!")
                        LoadingIndicator.stopAnimation()
                    } else {
                        print("Failed to submit review: \(error ?? "Unknown error")")
                        self.view.makeToast(error ?? "Failed to submit review.")
                    }
                }
            }
        } else {
            // If reviewVC is nil, proceed with the else statement
            guard let description = textView.text, !description.isEmpty else {
                self.view.makeToast("Review text cannot be empty.")
                return
            }
            
            // Create a new review object with updated fields for the vc case
            let newReview = AudioBookReviews(
                bookEpisodeId: Int(vc.episodeId) ?? 0,
                description: description,
                fullName: ShadhinCore.instance.defaults.userName,
                imageUrl: ShadhinCore.instance.defaults.userProPicUrl.image300,
                rating: selectedRating,
                usercode: ShadhinCore.instance.defaults.userIdentity
            )
            
            LoadingIndicator.initLoadingIndicator(view:self.view)
            LoadingIndicator.startAnimation()
            ShadhinCore.instance.api.addReview(newReview) { response, error in
                if let response = response, response.success {
                    DispatchQueue.main.async{
                        self.vc.getAudioBookReviews()
                        self.vc.collectionView.reloadData()
                    }
                    SwiftEntryKit.dismiss()
                    LoadingIndicator.stopAnimation()
                    self.view.makeToast("Review submitted successfully!")
                } else {
                    print("Failed to submit review: \(error ?? "Unknown error")")
                    self.view.makeToast(error ?? "Failed to submit review.")
                }
            }
        }
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeHolderLabel.isHidden = !textView.text.isEmpty
    }
    
    private func setupCornerRadius() {
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
    }
}

