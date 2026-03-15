//
//  SubscriptionTypeVC.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 3/23/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit
import CoreTelephony


class SubscriptionTypeVC: UIViewController {
    
    @IBOutlet weak var spinnerOutlet: UIActivityIndicatorView!
    
    //let phoneNumberKit = PhoneNumberKit()
    let networkInfo = CTTelephonyNetworkInfo()
    
    var isNeedSubs = false
    var selectedCountry = ""
    
    var subscriptionPlatForm = "common" //"bkash"  "gp"  "robi_airtel"  "banglalink" "ssl" "upay"
    var subscriptionPlanName = "common" //"daily"  "monthly" "half_yearly" "yearly"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //NotificationCenter.default.addObserver(self, selector: #selector(dismissVC), name: .didTapBackBkashPayment, object: nil)
        self.spinnerOutlet.isHidden = false
        self.spinnerOutlet.startAnimating()
        //self.isLoggedInFrom()
//        if !ShadhinCore.instance.isUserPro{
//            RobiAnalytics.gotoPro()
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.goToSubscriptionVC()
//        if ShadhinCore.instance.userInBD(){
//            self.goToSubscriptionOptsBdVC()
////        }
////        else{
////            self.goToSubscriptionVC()
////        }
    }
    
    deinit {
         NotificationCenter.default.removeObserver(self)
     }
    
    private func goToSubscriptionVC() {
        self.dismiss(animated: false) {
            //let storyBoard = UIStoryboard(name: "Payment", bundle: nil)
            let vc = SubscriptionVCv3.instantiateNib() //storyBoard.instantiateViewController(withIdentifier: "SubscriptionVC") as! SubscriptionVC
            let navVC = UINavigationController(rootViewController: vc)
            navVC.isNavigationBarHidden = true
            navVC.modalPresentationStyle = .fullScreen
            navVC.modalTransitionStyle = .coverVertical
            //vc.isInBD = ShadhinCore.instance.userInBD()
            if var top = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = top.presentedViewController {
                    top = presentedViewController
                }
                top.present(navVC, animated: true, completion: nil)
            }
        }
        
    }
    
//    private func goToSubscriptionOptsBdVC(){
//        self.dismiss(animated: false) {
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.checkUserSubscription()
//            let storyBoard = UIStoryboard(name: "Payment", bundle: nil)
//            let vc = storyBoard.instantiateViewController(withIdentifier: "SubscriptionOptsBdVC") as! SubscriptionOptsBdVC
//            vc.subscriptionPlanName = self.subscriptionPlanName
//            vc.subscriptionPlatForm = self.subscriptionPlatForm
//            let navVC = UINavigationController(rootViewController: vc)
//            navVC.isNavigationBarHidden = true
//            navVC.modalPresentationStyle = .fullScreen
//            navVC.modalTransitionStyle = .coverVertical
//            if var top = UIApplication.shared.keyWindow?.rootViewController {
//                while let presentedViewController = top.presentedViewController {
//                    top = presentedViewController
//                }
//                top.present(navVC, animated: true, completion: nil)
//            }
//        }
//    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true)
    }
    
   
}




