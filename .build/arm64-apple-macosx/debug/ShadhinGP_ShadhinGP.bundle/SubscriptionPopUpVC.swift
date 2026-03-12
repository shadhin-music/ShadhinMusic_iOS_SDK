//
//  SubscriptionPopUpVC.swift
//  Shadhin
//
//  Created by Gakk Alpha on 6/2/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit


class SubscriptionPopUpVC: UIViewController {

    static func show(_ callingVC: UIViewController?){
        
        let storyBoard = UIStoryboard(name: "Payment", bundle:Bundle.ShadhinMusicSdk)
        let myAlert = storyBoard.instantiateViewController(withIdentifier: "SubscriptionPopUpVC") as! SubscriptionPopUpVC
        myAlert.callingVC = callingVC
        var attribute = SwiftEntryKitAttributes.bottomAlertWrapAttributesRound(offsetValue: 8)
        attribute.entryBackground = .color(color: .clear)
        attribute.border = .none
        SwiftEntryKit.display(entry: myAlert, using: attribute)
    }
    
    private var callingVC: UIViewController?
    @IBOutlet weak var monthlyPlanHolder: UIView!
    @IBOutlet weak var monthlyPlanSubTitle: UILabel!
    @IBOutlet weak var seeAllPlansBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        seeAllPlansBtn.setClickListener {
            self.openSubs()
        }
        monthlyPlanHolder.setClickListener {
            self.openSubs("bkash", "monthly")
        }
    }
    
    func openSubs(_ subscriptionPlatForm :String = "common",
                  _ subscriptionPlanName :String = "common"){
        SwiftEntryKit.dismiss(){
            if self.callingVC == nil{
                self.goSubscriptionTypeVC(
                    true,
                    subscriptionPlatForm,
                    subscriptionPlanName)
            }else{
                self.callingVC?.goSubscriptionTypeVC(
                    false,
                    subscriptionPlatForm,
                    subscriptionPlanName)
            }
            
        }
    }

}

