//
//  GamesVC.swift
//  Shadhin
//
//  Created by Gakk Alpha on 10/20/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit
import WebKit

class GamesVC: UIViewController {
    
    @IBOutlet weak var rightBackArea: UIView!
    @IBOutlet weak var leftBackArea: UIView!
    @IBOutlet weak var webView: WKWebView!
    
    var item: CommonContentProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureRecognizers()
        let _url = URL (string: "https://html5.qplaze.com/games/real_goalkeeper/index.html")
        guard let url = _url else {
            return 
        }
        let requestObj = URLRequest(url: url)
        webView.load(requestObj)
    }
    
    override func viewDidAppear(_ animated: Bool) {
      //  AppUtility.lockOrientation(.landscape, andRotateTo: .landscapeRight)
        var style = ToastManager.shared.style
        style.messageFont = UIFont.systemFont(ofSize: 16)
        style.messageAlignment = .center
        self.view.makeToast("Swipe from left edge or right edge to close this window", duration: .init(10), style: style)
    }

    override func viewWillDisappear(_ animated: Bool) {
       // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    func setupGestureRecognizers() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeAction(swipe:)))
        leftSwipe.direction = UISwipeGestureRecognizer.Direction.left
        rightBackArea.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeAction(swipe:)))
        rightSwipe.direction = UISwipeGestureRecognizer.Direction.right
        leftBackArea.addGestureRecognizer(rightSwipe)
    }
    
    @objc func swipeAction(swipe: UISwipeGestureRecognizer) {
        //Log.info("swipeAction fired")
        self.dismiss(animated: true)
    }
}
