//
//  MusicPlayerV3LyricsExt.swift
//  Shadhin
//
//  Created by Joy on 23/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

extension MusicPlayerV3{
    
    func setupLyricsCard(_ lyrics : String,_ _contentId: String) {
        // Setup starting and ending card height
        //        endCardHeight = self.view.frame.height * 0.8
        //        startCardHeight = self.view.frame.height * 0.3
        guard let contentId = musicdata[songsIndex].contentID, contentId == _contentId else{
            return
        }
        
        if cardLyricsVC != nil{
            //removeCard()
            cardLyricsVC.update(str: lyrics)
            return
        }
        
        self.bottomOptionHeight.constant =  48 + 8// + ((UIApplication.shared.windows.first{$0.isKeyWindow }?.safeAreaInsets.bottom) ?? 0) + 8//54
        
        UIView.animate(withDuration: 0.9, animations: {
            self.view.layoutIfNeeded()
            self.setup(lyrics: lyrics)
        }) { (bool) in
            if bool{
                return
            }
            self.setup(lyrics: lyrics)
        }
        
        
    }
    
    private func setup(lyrics : String){
        self.endCardHeight = UIScreen.main.bounds.height - self.view.safeAreaInsets.top - 56
        self.startCardHeight = 48 + ((UIApplication.shared.windows.first{$0.isKeyWindow }?.safeAreaInsets.bottom) ?? 0)
        
        self.visualEffectView = UIVisualEffectView()
        self.visualEffectView.frame = UIScreen.main.bounds
        self.visualEffectView.isUserInteractionEnabled = false
        self.view.addSubview(self.visualEffectView)
        
        let tapGestureRecognizerLyrics = UITapGestureRecognizer(target: self, action: #selector(self.handleCardTapLyrics(recognzier:)))
        let panGestureRecognizerLyrics = UIPanGestureRecognizer(target: self, action: #selector(self.handleCardPanLyrics(recognizer:)))
        
        self.cardLyricsVC = LyricsCardVC(nibName:"LyricsCardVC", bundle:Bundle.ShadhinMusicSdk)
        self.cardLyricsVC.lyrics = lyrics
        self.cardLyricsVC.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.startCardHeight, width: UIScreen.main.bounds.width, height: self.endCardHeight)
        self.cardLyricsVC.tapGestureRecognizer = tapGestureRecognizerLyrics
        self.cardLyricsVC.panGestureRecognizer = panGestureRecognizerLyrics
        
        self.addChild(self.cardLyricsVC)
        self.view.addSubview(self.cardLyricsVC.view)
    }
    
    
    
    
    // Handle tap gesture recognizer
    @objc
    func handleCardTapLyrics(recognzier:UITapGestureRecognizer) {
        if cardLyricsVC.lyrics.isEmpty{
            return
        }
        switch recognzier.state {
        // Animate card when tap finishes
        case .ended:
            animateTransitionIfNeededLyrics(state: nextState, duration: 0.9)
        default:
            break
        }
    }
    
    // Handle pan gesture recognizer
    @objc
    func handleCardPanLyrics (recognizer:UIPanGestureRecognizer) {
        if cardLyricsVC.lyrics.isEmpty{
            return
        }
        switch recognizer.state {
        case .began:
            // Start animation if pan begins
            if (recognizer.velocity(in: cardLyricsVC.view).y > 0 && cardVisible) || !cardVisible{
                startInteractiveTransitionLyrics(state: nextState, duration: 0.9)
            }
            
        case .changed:
            // Update the translation according to the percentage completed
            let translation = recognizer.translation(in: self.cardLyricsVC.handleAreaLyrics)
            var fractionComplete = translation.y / endCardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransitionLyrics(fractionCompleted: fractionComplete)
        case .ended:
            // End animation when pan ends
            continueInteractiveTransitionLyrics()
        default:
            break
        }
    }
    
    
    // Animate transistion function
    func animateTransitionIfNeededLyrics (state:CardState, duration:TimeInterval) {
        // Check if frame animator is empty
        if runningAnimations.isEmpty {
            // Create a UIViewPropertyAnimator depending on the state of the popover view
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    // If expanding set popover y to the ending height and blur background
                    guard let vc = self.cardLyricsVC, let _view = vc.view else {return}
                    _view.frame.origin.y = UIScreen.main.bounds.height - self.endCardHeight
                    
                    guard let _visualEffectView = self.visualEffectView else {return}
                    _visualEffectView.effect = UIBlurEffect(style: .dark)
                    
                case .collapsed:
                    // If collapsed set popover y to the starting height and remove background blur
                    guard let vc = self.cardLyricsVC, let _view = vc.view else {return}
                    _view.frame.origin.y = UIScreen.main.bounds.height - self.startCardHeight
                    
                    guard let _visualEffectView = self.visualEffectView else {return}
                    _visualEffectView.effect = nil
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
                    self.cardLyricsVC.view.layer.cornerRadius = 16
                    self.cardLyricsVC.stateImg.isHighlighted = true
                case .collapsed:
                    // If the view is collapsed set the corner radius to 0
                    self.cardLyricsVC.view.layer.cornerRadius = 0
                    self.cardLyricsVC.stateImg.isHighlighted = false
                }
            }
            
            // Start the corner radius animation
            cornerRadiusAnimator.startAnimation()
            
            // Append animation to running animations
            runningAnimations.append(cornerRadiusAnimator)
            
        }
    }
    
    // Function to start interactive animations when view is dragged
    func startInteractiveTransitionLyrics(state:CardState, duration:TimeInterval) {
        
        // If animation is empty start new animation
        if runningAnimations.isEmpty {
            animateTransitionIfNeededLyrics(state: state, duration: duration)
        }
        
        // For each animation in runningAnimations
        for animator in runningAnimations {
            // Pause animation and update the progress to the fraction complete percentage
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    // Funtion to update transition when view is dragged
    func updateInteractiveTransitionLyrics(fractionCompleted:CGFloat) {
        // For each animation in runningAnimations
        for animator in runningAnimations {
            // Update the fraction complete value to the current progress
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    // Function to continue an interactive transisiton
    func continueInteractiveTransitionLyrics (){
        // For each animation in runningAnimations
        for animator in runningAnimations {
            // Continue the animation forwards or backwards
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
}
