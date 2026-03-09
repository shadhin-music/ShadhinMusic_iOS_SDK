//
//  NewContentPopUpVC.swift
//  Shadhin
//
//  Created by Joy on 18/7/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit


class NewContentPopUpVC: UIViewController,NIBVCProtocol {

    
    static let HEIGHT : CGFloat = UIScreen.main.bounds.height * 0.65 - (40 + 30 + 32)
    
    static func show(from : UIViewController,content : [PopUpObj.Content],contentPressed : @escaping (PopUpObj.Content)-> Void ){
        let vc = NewContentPopUpVC.instantiateNib()
        vc.contentPressed = contentPressed
        vc.contents =  content
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        from.present(vc, animated: true)
        
    }
    
    @IBOutlet weak var effectView: UIVisualEffectView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pagerView: FSPagerView!
    
    private var contents = [PopUpObj.Content]()
    var contentPressed : (PopUpObj.Content)-> Void = {content in}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pagerView.register(NewContentCell.nib, forCellWithReuseIdentifier: NewContentCell.identifier)
        pagerView.delegate = self
        pagerView.dataSource = self
        pagerView.interitemSpacing = 10
        self.pageControl.numberOfPages = self.contents.count
        
        if let obj = self.contents.first{
            setButtonText(obj: obj)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = pagerView.height
        pagerView.itemSize = .init(width: height -  80, height: height)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                if traitCollection.userInterfaceStyle == .dark {
                    //Dark
                    //self.effectView.effect = UIBlurEffect(style: .dark)
                }
                else {
                    //Light
                    //self.effectView.effect = UIBlurEffect(style: .light)
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    @IBAction func onTapGesture(_ sender: Any) {
        self.dismiss(animated: true)
        
    }
    @IBAction func onActionPressed(_ sender: Any) {
        self.dismiss(animated: true) {[weak self] in
            guard let self = self else{return}
            let obj = self.contents[self.pagerView.currentIndex]
            self.contentPressed(obj)
        }
    }
    
}

extension NewContentPopUpVC : FSPagerViewDelegate,FSPagerViewDataSource{
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return contents.count
    }
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        guard let cell = pagerView.dequeueReusableCell(withReuseIdentifier: NewContentCell.identifier, at: index) as? NewContentCell else {
            fatalError()
        }
        let obj = contents[index]
        cell.bind(content: obj)
        return cell
    }
    
    func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        pageControl.currentPage = pagerView.currentIndex
        let obj = contents[pagerView.currentIndex]
        setButtonText(obj: obj)
        
    }
    private func setButtonText(obj : PopUpObj.Content){
        if obj.contentType?.uppercased() == "SUBS"{
            actionButton.setTitle("Get Pro", for: .normal)
        }else{
            actionButton.setTitle("Listen Now", for: .normal)
//            let contentType = SMContentType.init(rawValue: obj.contentType)
//            switch contentType {
//            case .artist:
//                actionButton.setTitle("Goto Artist", for: .normal)
//            case .album:
//                actionButton.setTitle("Goto Album", for: .normal)
//            case .song:
//                actionButton.setTitle("Goto Song", for: .normal)
//            case .podcast:
//                actionButton.setTitle("Goto Podcast", for: .normal)
//            case .podcastVideo:
//                actionButton.setTitle("Goto Video Podcast", for: .normal)
//            case .video:
//                actionButton.setTitle("Goto Video", for: .normal)
//            case .playlist:
//                actionButton.setTitle("Goto Playlist", for: .normal)
//            case .unknown:
//                actionButton.setTitle("Go Pro", for: .normal)
//            }
        }
        
    }
}
