//
//  MusicPlayerV3CommentExt.swift
//  Shadhin
//
//  Created by Joy on 23/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation
extension MusicPlayerV3{
    
    func getComments() {
        
//        if cardCommentsVC != nil {
//            return
//        }
        
        guard let episodeId = Int(musicdata[songsIndex].albumId ?? ""),
            let podcastType = musicdata[songsIndex].contentType else{
                   return
        }
        
        self.bottomOptionHeight.constant =  48 + ((UIApplication.shared.currentWindow?.safeAreaInsets.bottom) ?? 0) + 8
        
        UIView.animate(withDuration: 0.9, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            self.endCardHeight = UIScreen.main.bounds.height - self.view.safeAreaInsets.top - 56
            self.startCardHeight = 48 + ((UIApplication.shared.currentWindow?.safeAreaInsets.bottom) ?? 0)
            
            self.visualEffectView = UIVisualEffectView()
            self.visualEffectView.frame = UIScreen.main.bounds
            self.visualEffectView.isUserInteractionEnabled = false
            self.view.addSubview(self.visualEffectView)
            
            let tapGestureRecognizerComment = UITapGestureRecognizer(target: self, action: #selector(self.handleCardTapComments(recognzier:)))
            let panGestureRecognizerComment = UIPanGestureRecognizer(target: self, action: #selector(self.handleCardPanComments(recognizer:)))
            
            self.cardCommentsVC = PodcastCommentVC(nibName:"PodcastCommentVC", bundle:Bundle.ShadhinMusicSdk)
            self.cardCommentsVC.episodeID = episodeId
            self.cardCommentsVC.contentType = podcastType
            self.cardCommentsVC.isFromPlayer = true
            self.cardCommentsVC.tapGestureRecognizer = tapGestureRecognizerComment
            self.cardCommentsVC.panGestureRecognizer = panGestureRecognizerComment
            self.cardCommentsVC.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.startCardHeight, width: UIScreen.main.bounds.width, height: self.endCardHeight)
            self.addChild(self.cardCommentsVC)
            self.view.addSubview(self.cardCommentsVC.view)
        }
    }
    

    // Handle tap gesture recognizer
    @objc
    func handleCardTapComments(recognzier:UITapGestureRecognizer) {
        switch recognzier.state {
            // Animate card when tap finishes
        case .ended:
            animateTransitionIfNeededComments(state: nextState, duration: 0.9)
        default:
            break
        }
    }
    
    // Handle pan gesture recognizer
    @objc
    func handleCardPanComments (recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            // Start animation if pan begins
            if (recognizer.velocity(in: cardCommentsVC.view).y > 0 && cardVisible) || !cardVisible{
                startInteractiveTransitionComments(state: nextState, duration: 0.9)
            }
            
        case .changed:
            // Update the translation according to the percentage completed
            let translation = recognizer.translation(in: self.cardCommentsVC.handleAreaComment)
            var fractionComplete = translation.y / endCardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransitionComments(fractionCompleted: fractionComplete)
        case .ended:
            // End animation when pan ends
            continueInteractiveTransitionComments()
        default:
            break
        }
    }
    
    
    // Animate transistion function
     func animateTransitionIfNeededComments (state:CardState, duration:TimeInterval) {
         // Check if frame animator is empty
         if runningAnimations.isEmpty {
             // Create a UIViewPropertyAnimator depending on the state of the popover view
             let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                 switch state {
                 case .expanded:
                     // If expanding set popover y to the ending height and blur background
                     self.cardCommentsVC.view.frame.origin.y = UIScreen.main.bounds.height - self.endCardHeight
                     self.visualEffectView.effect = UIBlurEffect(style: .dark)
    
                 case .collapsed:
                     // If collapsed set popover y to the starting height and remove background blur
                     self.cardCommentsVC.view.frame.origin.y = UIScreen.main.bounds.height - self.startCardHeight
                     
                     self.visualEffectView.effect = nil
                 }
             }
             
             // Complete animation frame
             frameAnimator.addCompletion { _ in
                 self.cardVisible = !self.cardVisible
                 self.runningAnimations.removeAll()
             }
             
             // Start animation
             frameAnimator.startAnimation()
             
             // Append animation to running animations
             runningAnimations.append(frameAnimator)
             
             // Create UIViewPropertyAnimator to round the popover view corners depending on the state of the popover
             let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                 switch state {
                 case .expanded:
                     // If the view is expanded set the corner radius to 16
                     self.cardCommentsVC.view.layer.cornerRadius = 16
                     self.cardCommentsVC.stateImg.isHighlighted = true
                 case .collapsed:
                     // If the view is collapsed set the corner radius to 0
                     self.cardCommentsVC.view.layer.cornerRadius = 0
                     self.cardCommentsVC.stateImg.isHighlighted = false
                 }
             }
             
             // Start the corner radius animation
             cornerRadiusAnimator.startAnimation()
             
             // Append animation to running animations
             runningAnimations.append(cornerRadiusAnimator)
             
         }
     }
     
     // Function to start interactive animations when view is dragged
     func startInteractiveTransitionComments(state:CardState, duration:TimeInterval) {
         
         // If animation is empty start new animation
         if runningAnimations.isEmpty {
             animateTransitionIfNeededComments(state: state, duration: duration)
         }
         
         // For each animation in runningAnimations
         for animator in runningAnimations {
             // Pause animation and update the progress to the fraction complete percentage
             animator.pauseAnimation()
             animationProgressWhenInterrupted = animator.fractionComplete
         }
     }
     
     // Funtion to update transition when view is dragged
     func updateInteractiveTransitionComments(fractionCompleted:CGFloat) {
         // For each animation in runningAnimations
         for animator in runningAnimations {
             // Update the fraction complete value to the current progress
             animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
         }
     }
     
     // Function to continue an interactive transisiton
     func continueInteractiveTransitionComments (){
         // For each animation in runningAnimations
         for animator in runningAnimations {
             // Continue the animation forwards or backwards
             animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
         }
     }
}
