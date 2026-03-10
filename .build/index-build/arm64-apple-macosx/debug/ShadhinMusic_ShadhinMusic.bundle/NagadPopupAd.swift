//
//  NagadPopupAd.swift
//  Shadhin
//
//  Created by Rezwan on 14/6/21.
//  Copyright © 2021 Cloud 7 Limited. All rights reserved.
//

import UIKit

class NagadPopupAd: UIViewController {
    
    static var isShowing = false

    static func show() {
        if isShowing {
            return
        }
        let myAlert = NagadPopupAd(nibName:"NagadPopupAd", bundle:Bundle.ShadhinMusicSdk)
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(myAlert, animated: true, completion: nil)
        }
    }
    
    @IBOutlet var background: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var mainHolder: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NagadPopupAd.isShowing = true
        background.setClickListener {
            self.dismiss(animated: true, completion: nil)
        }
        closeBtn.setClickListener {
            self.dismiss(animated: true, completion: nil)
        }
        mainHolder.addGestureRecognizer(UITapGestureRecognizer(target: nil, action: .none))
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        NagadPopupAd.isShowing = false
        super.dismiss(animated: flag, completion: completion)
    }
    
}
