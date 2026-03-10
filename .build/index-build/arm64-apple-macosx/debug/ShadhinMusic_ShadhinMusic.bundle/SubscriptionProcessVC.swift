//
//  SubscriptionProcessVC.swift
//  Shadhin
//
//  Created by Maruf on 15/2/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class SubscriptionProcessVC: UIViewController,NIBVCProtocol {
    
    @IBOutlet weak var successFailedImage: UIImageView!
    @IBOutlet weak var subscriptionBtn: UIView!
    @IBOutlet weak var subscriptionBgImg: UIImageView!
    
    @IBOutlet weak var underProcessLabel: UILabel!
    @IBOutlet weak var btnLbl: UILabel!
    @IBOutlet weak var procressLbl: UILabel!
    @IBOutlet weak var showIndicator: UIActivityIndicatorView!
    var onSuccess: ()->Void = {}
    var onFailure: ()->Void = {}
    var goBackToCurrentPlan: () -> Void = {}
    private var callingVC: UIViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        showIndicatorChange()
        subscriptionBGImageChange()
        subscriptionBtn.isHidden = true
        
    }
    private func showIndicatorChange() {
        showIndicator.startAnimating()
        // if subscription is running then indicator will be running
        // if  subscription is succesfull then succes icon will be added.
        //if subscription is faild then here faild icon will be added
    }
    
    func showSucces() {
        GPSDKSubscription.getNewUserSubscriptionDetails {[weak self] isSubscribed in
            guard let self = self else { return }
            if isSubscribed {
                self.confirmBtnLabelChange()
            }
        }
    }
    
    func showFailed(message: String, okAction: @escaping () -> Void) {
        showIndicator.stopAnimating()
        showIndicator.isHidden = true
        successFailedImage.image = UIImage(named: "ic_failed_newsub",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        underProcessLabel.text = "Subscription Failed!"
        procressLbl.text = message
        subscriptionBtn.isHidden = false
        subscriptionBtn.setClickListener {
            okAction()
        }
    }
    
    private func  subscriptionBGImageChange()  {
        subscriptionBgImg.isHidden = true
    }
    
    private func confirmBtnLabelChange() {
        btnLbl.text =  "Enjoy Shadhin Music!"
        showIndicator.stopAnimating()
        showIndicator.isHidden = true
        successFailedImage.image = UIImage(named: "ic_done_newsub",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        underProcessLabel.text = "Successfully Subscribed!"
        procressLbl.text = "Congratulations. You are now successfully subscribed to Shadhin Pro."
        subscriptionBtn.isHidden = false
        subscriptionBtn.setClickListener {
            self.enjoyShadhinMusicButtonPressed()
        }
    }
    
    private func enjoyShadhinMusicButtonPressed() {
        SwiftEntryKit.dismiss()
        nootifySubscritionSuccessAndBackToRoot()
    }
    
    private func nootifySubscritionSuccessAndBackToRoot(){
        NotificationCenter.default.post(name: .newSubscriptionUpdate, object: nil)
        goBackToCurrentPlan()
    }
}

extension Notification.Name {
    static let newSubscriptionUpdate = Notification.Name("newSubscriptionUpdate")
}
