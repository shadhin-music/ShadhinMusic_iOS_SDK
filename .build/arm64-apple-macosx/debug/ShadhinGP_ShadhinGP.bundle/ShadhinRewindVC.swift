//
//  ViewController.swift
//  ShadhinStory
//
//  Created by Maruf on 13/12/23.
//

import UIKit
import Photos
import AVFoundation

class ShadhinRewindVC: UIViewController, NIBVCProtocol {
    private var isBeingDragged = false
    let buttonWidth = UIScreen.main.bounds.width/2
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var volumeButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var pageControl: CHIPageControlJaloro!
    @IBOutlet weak var pagerView: FSPagerView!
    var streamingData = [TopStreammingElementModel]()
    private var adapter : RewindAdapter!
    
    private var player : AVPlayer? = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
        shareButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        shareButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        //    shareButton.layer.cornerRadius = 20
        playPauseButton.setImage(UIImage(named: "rewindPause",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
        playPauseButton.setImage(UIImage(named: "rewindPlay",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .selected)
        volumeButton.setImage(UIImage(named: "rewindSound",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
        volumeButton.setImage(UIImage(named: "rewindMute",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .selected)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        let bounds = UIScreen.main.bounds
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        self.pagerView.drawHierarchy(in: bounds, afterScreenUpdates: false)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let activityViewController = UIActivityViewController(activityItems: [img!], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    @IBAction func onPlayPaue(_ sender: Any) {
        playPauseButton.isSelected = !playPauseButton.isSelected
        if !playPauseButton.isSelected{
            pagerView.automaticSlidingInterval = 3
            pagerView.reloadData()
            player?.play()
        }else{
            pagerView.automaticSlidingInterval = -1.0
            pagerView.reloadData()
            player?.pause()
            let time = pagerView.currentIndex  * 3
            player?.seek(to: .init(seconds: Double(time), preferredTimescale: 60), toleranceBefore: .init(seconds: 1, preferredTimescale: 60), toleranceAfter: .zero)
        }
        
    }
    
    
    @IBAction func onMute(_ sender: Any) {
        volumeButton.isSelected = !volumeButton.isSelected
        player?.isMuted = volumeButton.isSelected
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true){
            self.player?.pause()
            self.player = nil
        }
    }
}

extension ShadhinRewindVC {
    private func viewSetup() {

        adapter = RewindAdapter()
        pagerView.register(StoryShareStepCellOne.nib, forCellWithReuseIdentifier: StoryShareStepCellOne.identifier)
        pagerView.register(StoryShareStepCellTwo.nib, forCellWithReuseIdentifier: StoryShareStepCellTwo.identifier)
        pagerView.register(StoryShareStepCellThree.nib, forCellWithReuseIdentifier: StoryShareStepCellThree.identifier)
        pagerView.register(StoryShareStepCellFour.nib, forCellWithReuseIdentifier: StoryShareStepCellFour.identifier)
        pagerView.register(StoryShareStepCellFive.nib, forCellWithReuseIdentifier: StoryShareStepCellFive.identifier)
        pagerView.register(StoryShareStepCellSix.nib, forCellWithReuseIdentifier: StoryShareStepCellSix.identifier)
        pagerView.register(StoryShareStepCellSeven.nib, forCellWithReuseIdentifier: StoryShareStepCellSeven.identifier)
        pagerView.dataSource = adapter
        pagerView.delegate = self
        pagerView.isInfinite = true
        
        pagerView.automaticSlidingInterval = 3.0
        pagerView.transformer = FSPagerViewTransformer(type: .crossFading)
        
        pageControl.numberOfPages = 7
        pageControl.radius = 2
        pageControl.tintColor = .gray
        pageControl.currentPageTintColor = .white
        pageControl.padding = 8
        pageControl.enableTouchEvents = false
        //collectionView?.contentInset = .init(top:16, left: 16, bottom: 16, right: 16)
        self.pageControl.set(progress: 0, animated: true)
        
        if let url = Bundle.main.url(forResource: "rewind", withExtension: "mp3"){
            player = .init(url: url)
            player?.play()
        }
        NotificationCenter.default
            .addObserver(self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
                         object: player?.currentItem
        )
        adapter.addPatches(array: streamingData)
        pagerView.reloadData()
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("audio Finished")
        self.playPauseButton.isSelected = false
        
    }

}
extension  ShadhinRewindVC : FSPagerViewDelegate{
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        self.pageControl.set(progress: pagerView.currentIndex, animated: true)
        if pagerView.currentIndex == 6{
            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                pagerView.automaticSlidingInterval = -1.0
                pagerView.reloadData()
                self.player?.pause()
                self.player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
                self.playPauseButton.isSelected = true
            }
        }
    }
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.pageControl.set(progress: targetIndex, animated: true)
        if targetIndex == 6{
            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                pagerView.automaticSlidingInterval = -1.0
                pagerView.reloadData()
                self.player?.pause()
                self.player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
                self.playPauseButton.isSelected = true
            }
        }
    }
    
}


