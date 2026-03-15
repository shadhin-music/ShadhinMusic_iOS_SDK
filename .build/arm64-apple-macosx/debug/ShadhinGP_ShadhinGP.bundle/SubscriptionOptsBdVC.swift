//
//  SubscriptionOptsBdVC.swift
//  Shadhin
//
//  Created by Rezwan on 13/9/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit


class SubscriptionOptsBdVC: UIViewController, ButtonDelegate {

    
    @IBOutlet weak var currentPlanHolder: UIView!
    @IBOutlet weak var currentPlanDuration: UILabel!
    @IBOutlet weak var currrentPlanCost: UILabel!
    @IBOutlet weak var currentPlanDetails: UILabel!
    @IBOutlet weak var currentPlanValidLbl: UILabel!
    @IBOutlet weak var cancelBtn: UILabel!
    
    
    
    @IBOutlet var paymentMethods: [UIView]!
    @IBOutlet weak var paymentHistoryBtn: UIButton!
    
    @IBOutlet weak var telcoImageVie: UIImageView!
    @IBOutlet weak var bkash100Back: UILabel!
    
    
    var subscriptionPlatForm = "common" //"bkash"  "gp"  "robi_airtel"  "banglalink"
    var subscriptionPlanName = "common" //"daily"  "monthly" "half_yearly" "yearly"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkCurrentSub()
        paymentMethods[0].setClickListener {
           // self.goToPaymentOpts(.bKash)
        }
        paymentMethods[1].setClickListener {
           // self.goToPaymentOpts(.SSL)
        }
        paymentMethods[2].setClickListener {
         //   self.goToPaymentOpts(.telco)
        }
        paymentMethods[3].setClickListener {
          //  self.goToPaymentOpts(.upay)
        }
        paymentMethods[4].setClickListener {
           // self.goToPaymentOpts(.nagad)
        }
        
        if ShadhinCore.instance.isGP(){
            let img = UIImage(named: "GrameenphoneNew",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            telcoImageVie.image = img
        }else if ShadhinCore.instance.isAirtelOrRobi(){
            let img = UIImage(named: "RobiAirtelNew",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            telcoImageVie.image = img
        }else if ShadhinCore.instance.isBanglalink(){
            let img = UIImage(named: "BanglalinkNew",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            telcoImageVie.image = img
        }else{
            telcoImageVie.image = UIImage(resource: ImageResource(name: "ic_logo_telco", bundle:Bundle.ShadhinMusicSdk))
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkCurrentSubFromAPi), name: .didTapBackBkashPayment, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func checkCurrentSubFromAPi(){
        checkCurrentSub(true)
        //print("Check -> checkCurrentSubFromAPi")
    }
    
    @objc private func checkCurrentSub(_ fromApi : Bool = false){
        
        if ShadhinCore.instance.isUserPro{
            currentPlanHolder.isHidden = false
            paymentMethods.forEach({$0.isHidden = true})
            
            self.cancelBtn.setClickListener {
                self.cancelSub()
            }
            let expireDate = ShadhinCore.instance.defaults.expireDate  
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSS" //"MM/dd/yyyy hh:mm:ss a"
            let dateFormatter0 = DateFormatter()
            dateFormatter0.dateFormat = "MMM d, yyyy"
            if !expireDate.isEmpty,
               let expDate = dateFormatter.date(from: expireDate){
                currentPlanValidLbl.isHidden = false
                currentPlanValidLbl.text = "Valid till \(dateFormatter0.string(from: expDate))"
            }
            //print("Check -> checkCurrentSub \(SubscriptionService.instance.servicePackageID)")
            switch ShadhinCore.instance.defaults.subscriptionServiceID {
            case ShadhinCoreSubscriptions.BKASH_DAILY_NEW:
                currentPlanDuration.text = "Daily"
                currrentPlanCost.text = "৳2.00 (Auto Renewal)"
                currentPlanDetails.text = "You'er in Daily Plan using bKash"
                paymentHistoryBtn.isHidden = false
                paymentHistoryBtn.setClickListener {
                   // self.showBkashHistory()
                }
                break
            case ShadhinCoreSubscriptions.BKASH_MONTHLY,
                ShadhinCoreSubscriptions.BKASH_MONTHLY_NEW:
                currentPlanDuration.text = "Monthly"
                currrentPlanCost.text = "৳20.00 (Auto Renewal)"
                currentPlanDetails.text = "You'er in Monthly Plan using bKash"
                paymentHistoryBtn.isHidden = false
                paymentHistoryBtn.setClickListener {
              //      self.showBkashHistory()
                }
                break
            case ShadhinCoreSubscriptions.BKASH_HALF_YEARLY,
                ShadhinCoreSubscriptions.BKASH_HALF_YEARLY_NEW:
                currentPlanDuration.text = "Half Yearly"
                currrentPlanCost.text = "৳99.00 (Auto Renewal)"
                currentPlanDetails.text = "You'er in Half Yearly Plan using bKash"
                paymentHistoryBtn.isHidden = false
                paymentHistoryBtn.setClickListener {
                 //   self.showBkashHistory()
                }
                break
            case ShadhinCoreSubscriptions.BKASH_YEARLY_NEW:
                currentPlanDuration.text = "Yearly"
                currrentPlanCost.text = "৳199.00 (Auto Renewal)"
                currentPlanDetails.text = "You'er in Yearly Plan using bKash"
                paymentHistoryBtn.isHidden = false
                paymentHistoryBtn.setClickListener {
                //    self.showBkashHistory()
                }
                break
            case ShadhinCoreSubscriptions.SSL_MONTHLY:
                currentPlanDuration.text = "Monthly"
                currrentPlanCost.text = "৳20.00"
                currentPlanDetails.text = "You'er in Monthly Plan using Debit/Credit & Others"
                paymentHistoryBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.SSL_HALF_YEARLY,
                ShadhinCoreSubscriptions.SSL_HALF_YEARLY_OLD:
                currentPlanDuration.text = "Half Yearly"
                currrentPlanCost.text = "৳99.00"
                currentPlanDetails.text = "You'er in Half Yearly Plan using Debit/Credit & Others"
                paymentHistoryBtn.isHidden = true
                self.cancelBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.SSL_HALF_YEARLY_NEW:
                currentPlanDuration.text = "Half Yearly"
                currrentPlanCost.text = "৳99.00"
                currentPlanDetails.text = "You'er in Half Yearly Plan using Debit/Credit & Others"
                paymentHistoryBtn.isHidden = true
                
                if let item = ShadhinCore.instance.defaults.stripeSSLDetails{
                    if item.status.uppercased().elementsEqual("ACTIVE"){
                        self.cancelBtn.text = "Cancel"
                    }else{
                        self.cancelBtn.text = "Canceled"
                    }
                }
                
            case ShadhinCoreSubscriptions.GP_DAILY,
                ShadhinCoreSubscriptions.GP_DAILY_NEW,
                ShadhinCoreSubscriptions.GP_DAILY_NEWV2,
                ShadhinCoreSubscriptions.ROBI_DAILY,
                ShadhinCoreSubscriptions.ROBI_DCB_DAILY_NEW,
                ShadhinCoreSubscriptions.BL_DAILY,
                ShadhinCoreSubscriptions.BL_DAILY_NEWV2:
                currentPlanDuration.text = "Daily"
                currrentPlanCost.text = "৳3.00 (Auto Renewal, Exclusive of VAT, SD & SC)"
                currentPlanDetails.text = "You'er in Daily Plan using Telco Charging"
                paymentHistoryBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.GP_MONTHLY,
                ShadhinCoreSubscriptions.GP_MONTHLY_NEW,
                ShadhinCoreSubscriptions.ROBI_MONTHLY,
                ShadhinCoreSubscriptions.ROBI_DCB_MONTHLY_NEW,
                ShadhinCoreSubscriptions.BL_MONTHLY,
                ShadhinCoreSubscriptions.BL_MONTHLY_NEW:
                currentPlanDuration.text = "Monthly"
                currrentPlanCost.text = "৳20.00 (Auto Renewal, Inclusive of VAT, SD & SC)"
                currentPlanDetails.text = "You'er in Monthly Plan using Telco Charging"
                paymentHistoryBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.GP_MONTHLY_PLUS:
                currentPlanDuration.text = "Monthly Plus"
                currrentPlanCost.text = "৳30.00 (Non Auto Renewal, Exclusive of VAT, SD & SC)"
                currentPlanDetails.text = "You'er in Monthly Plus Plan using Telco Charging"
                paymentHistoryBtn.isHidden = true
                self.cancelBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.GP_HALF_YEARLY,
                ShadhinCoreSubscriptions.GP_HALF_YEARLY_NEW,
                ShadhinCoreSubscriptions.ROBI_HALF_YEARLY,
                ShadhinCoreSubscriptions.ROBI_DCB_HALF_YEARLY_NEW,
                ShadhinCoreSubscriptions.BL_HALF_YEARLY,
                ShadhinCoreSubscriptions.BL_HALF_YEARLY_NEW:
                currentPlanDuration.text = "Half Yearly"
                currrentPlanCost.text = "৳99.00 (Auto Renewal, Inclusive of VAT, SD & SC)"
                currentPlanDetails.text = "You'er in Half Year Plan using Telco Charging"
                paymentHistoryBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.GP_YEARLY,
                ShadhinCoreSubscriptions.GP_YEARLY_NEW,
                ShadhinCoreSubscriptions.ROBI_YEARLY,
                ShadhinCoreSubscriptions.ROBI_DCB_YEARLY_NEW,
                ShadhinCoreSubscriptions.BL_YEARLY,
                ShadhinCoreSubscriptions.BL_YEARLY_NEW:
                currentPlanDuration.text = "Yearly"
                currrentPlanCost.text = "৳199.00 (Auto Renewal, Inclusive of VAT, SD & SC)"
                currentPlanDetails.text = "You'er in Year Plan using Telco Charging"
                paymentHistoryBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.EVALY_HALF_YEARLY:
                currentPlanDuration.text = "Half Yearly"
                currrentPlanCost.text = ""
                currentPlanDetails.text = "You'er in Half Yearly Plan using Evaly"
                paymentHistoryBtn.isHidden = true
                self.cancelBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.EVALY_YEARLY:
                currentPlanDuration.text = "Yearly"
                currrentPlanCost.text = ""
                currentPlanDetails.text = "You'er in Yearly Plan using Evaly"
                paymentHistoryBtn.isHidden = true
                self.cancelBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.COUPON:
                currentPlanDuration.text = "Monthly"
                currrentPlanCost.text = ""
                currentPlanDetails.text = "You'er using Coupon"
                paymentHistoryBtn.isHidden = true
                self.cancelBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.ROBI_3DAY_DATA_PACK:
                currentPlanDuration.text = "3 Days"
                currrentPlanCost.text = ""
                currentPlanDetails.text = "You'er in 3 Days Plan using Robi Data Pack"
                paymentHistoryBtn.isHidden = true
                self.cancelBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.ROBI_WEEKLY_DATA_PACK:
                currentPlanDuration.text = "Weekly"
                currrentPlanCost.text = ""
                currentPlanDetails.text = "You'er in weekly Plan using Robi Data Pack"
                paymentHistoryBtn.isHidden = true
                self.cancelBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.ROBI_15DAY_DATA_PACK:
                currentPlanDuration.text = "15 Days"
                currrentPlanCost.text = ""
                currentPlanDetails.text = "You'er in 15 Days Plan using Robi Data Pack"
                paymentHistoryBtn.isHidden = true
                self.cancelBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.ROBI_MONTHLY_DATA_PACK:
                currentPlanDuration.text = "Monthly"
                currrentPlanCost.text = ""
                currentPlanDetails.text = "You'er in monthly Plan using Robi Data Pack"
                paymentHistoryBtn.isHidden = true
                self.cancelBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.AIRTEL_3DAY_DATA_PACK:
                currentPlanDuration.text = "3 Days"
                currrentPlanCost.text = ""
                currentPlanDetails.text = "You'er in 3 Days Plan using Airtel Data Pack"
                paymentHistoryBtn.isHidden = true
                self.cancelBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.AIRTEL_WEEKLY_DATA_PACK:
                currentPlanDuration.text = "Weekly"
                currrentPlanCost.text = ""
                currentPlanDetails.text = "You'er in weekly Plan using Airtel Data Pack"
                paymentHistoryBtn.isHidden = true
                self.cancelBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.AIRTEL_15DAY_DATA_PACK:
                currentPlanDuration.text = "15 Days"
                currrentPlanCost.text = ""
                currentPlanDetails.text = "You'er in 15 Days Plan using Airtel Data Pack"
                paymentHistoryBtn.isHidden = true
                self.cancelBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.AIRTEL_MONTHLY_DATA_PACK:
                currentPlanDuration.text = "Monthly"
                currrentPlanCost.text = ""
                currentPlanDetails.text = "You'er in monthly Plan using Airtel Data Pack"
                paymentHistoryBtn.isHidden = true
                self.cancelBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.UPAY_HALF_YEARLY:
                currentPlanDuration.text = "Half Yearly"
                currrentPlanCost.text = ""
                currentPlanDetails.text = "You'er in Half Yearly Plan using Upay"
                paymentHistoryBtn.isHidden = true
                self.cancelBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.NAGAD_DAILY:
                currentPlanDuration.text = "Daily"
                currrentPlanCost.text = ""
                currentPlanDetails.text = "You'er in Daily Plan using Nagad"
                paymentHistoryBtn.isHidden = true
                self.cancelBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.NAGAD_MONTHLY:
                currentPlanDuration.text = "Monthly"
                currrentPlanCost.text = ""
                currentPlanDetails.text = "You'er in Monthly Plan using Nagad"
                paymentHistoryBtn.isHidden = true
                self.cancelBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.NAGAD_HALF_YEARLY:
                currentPlanDuration.text = "Half Yearly"
                currrentPlanCost.text = ""
                currentPlanDetails.text = "You'er in Half Yearly Plan using Nagad"
                paymentHistoryBtn.isHidden = true
                self.cancelBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.NAGAD_YEARLY:
                currentPlanDuration.text = "Yearly"
                currrentPlanCost.text = ""
                currentPlanDetails.text = "You'er in Yearly Plan using Nagad"
                paymentHistoryBtn.isHidden = true
                self.cancelBtn.isHidden = true
            case ShadhinCoreSubscriptions.BANGLA_LINK_DATA_PACK:
                currentPlanDuration.text = "Banglalink"
                currrentPlanCost.text = ""
                currentPlanDetails.text = "You'er in Data Pack Plan using Banglalink"
                paymentHistoryBtn.isHidden = true
                self.cancelBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.APP_YEARLY,
                ShadhinCoreSubscriptions.APP_MONTHLY:
                currentPlanDuration.text = "Apple Subscription"
                currrentPlanCost.text = ""
                currentPlanDetails.text = "Go to App Store to manage your subscription"
                paymentHistoryBtn.isHidden = true
                self.cancelBtn.isHidden = true
                break
            case ShadhinCoreSubscriptions.STRIPE_MONTHLY:
                currentPlanDuration.text = "Stripe Subscription"
                currrentPlanCost.text = "$0.99"
                currentPlanDetails.text = "You'er in Monthly Plan using Stripe"
                paymentHistoryBtn.isHidden = true
                self.cancelBtn.isHidden = false
                if let item = ShadhinCore.instance.defaults.stripeSSLDetails{
                    if item.status.uppercased().elementsEqual("ACTIVE"){
                        self.cancelBtn.text = "Cancel"
                    }else{
                        self.cancelBtn.text = "Canceled"
                    }
                }
            case ShadhinCoreSubscriptions.STRIPE_YEARLY:
                currentPlanDuration.text = "Stripe Subscription"
                currrentPlanCost.text = "$9.99"
                currentPlanDetails.text = "You'er in Yearly Plan using Stripe"
                paymentHistoryBtn.isHidden = true
                self.cancelBtn.isHidden = false
                if let item = ShadhinCore.instance.defaults.stripeSSLDetails{
                    if item.status.uppercased().elementsEqual("ACTIVE"){
                        self.cancelBtn.text = "Cancel"
                    }else{
                        self.cancelBtn.text = "Canceled"
                    }
                }
            default:
                break
            }
            
        }else{
            
            paymentHistoryBtn.isHidden = false //bkash payment history
            paymentHistoryBtn.setClickListener {
              //  self.restoreApple()
            }
            currentPlanHolder.isHidden = true
            paymentMethods.forEach({$0.isHidden = false})
            
            if fromApi{
                //print("checkCurrentSub being called after api")
              //  proceedToSpecificSub()
            }
            
        }
        
    }
    
//    private func restoreApple(){
//        SubscriptionAppleProducts.store.restorePurchases()
//        SubscriptionAppleProducts.store.restorePurchasesCompleted { (success) in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//              if success {
//                  AppDelegate.shared?.checkUserSubscription()
//                  self.view.makeToast("Product successfully restored.")
//                  AppDelegate.shared?.getReceiptData()
//              }else {
//                  self.view.makeToast("Failed to restore of product")
//              }
//            }
//        }
//    }
////    
//    private func proceedToSpecificSub(){
//        switch subscriptionPlatForm{
//        case "bkash":
//       //     self.goToPaymentOpts(.bKash, true)
//        case "gp":
//            if ShadhinCore.instance.isGP(){
//             //   self.goToPaymentOpts(.telco, true)
//            }
//        case "robi_airtel":
//            if ShadhinCore.instance.isAirtelOrRobi(){
//                self.goToPaymentOpts(.telco, true)
//            }
//        case "banglalink":
//            if ShadhinCore.instance.isBanglalink(){
//                self.goToPaymentOpts(.telco, true)
//            }
//        case "ssl":
//            self.goToPaymentOpts(.SSL, true)
//        case "upay":
//            self.goToPaymentOpts(.upay, true)
//        default:
//            break
//        }
//        subscriptionPlatForm = "common"
//        subscriptionPlanName = "common"
//    }
    
    private func cancelSub(){
        if ShadhinCore.instance.defaults.isBkashSubscribedUser{
            cancelBkashNew()
        }
       
        if ShadhinCore.instance.defaults.isTelcoSubscribedUser{
            cancelTelco()
        }
        if ShadhinCore.instance.defaults.isStripeSubscriptionUser{
            if let item = ShadhinCore.instance.defaults.stripeSSLDetails{
                if item.status.uppercased().elementsEqual("ACTIVE"){
                    cancelStripe()
                }else{
                    AlertPopUp.show(self,
                                    image: #imageLiteral(resourceName: "shadhin_logo"),
                                    tileString: "Alert",
                                    msgString: "You already canceled this subscription.",
                                    positiveString: nil,
                                    negativeString: nil,
                                    buttonDelegate: nil)
                }
            }
            
        }
        if ShadhinCore.instance.defaults.isSSLSubscribedUser, ShadhinCore.instance.defaults.subscriptionServiceID == ShadhinCoreSubscriptions.SSL_HALF_YEARLY_NEW{
            if let item = ShadhinCore.instance.defaults.stripeSSLDetails{
                if item.status.uppercased().elementsEqual("ACTIVE"){
                    cancelNewSSLAlert()
                }else{
                    AlertPopUp.show(self,
                                    image: #imageLiteral(resourceName: "shadhin_logo"),
                                    tileString: "Alert",
                                    msgString: "You already canceled this subscription.",
                                    positiveString: nil,
                                    negativeString: nil,
                                    buttonDelegate: nil)
                }
            }
        }else if ShadhinCore.instance.defaults.isSSLSubscribedUser{
            cancelSSL()
        }
        
    }
    
    
    private func cancelTelco(){
        let message = "You have requested to Cancel Telco subscription. Are you sure?"
        let alertVC = UIAlertController(title: "Confirmation", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (action) in
            //SubscriptionService.instance.subUnsubRobiAirtel(willRegister: false, serverId: SubscriptionService.instance.servicePackageID, vc: self)
            self.confirmedCancelTelco()
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(confirmAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    private func confirmedCancelTelco(){
        if ShadhinCore.instance.isGP(){
            self.cancelGpSub()
        }else if ShadhinCore.instance.isBanglalink(){
            self.cancelBlSub()
        }else{
            self.cancelRobiSubNew()
        }
    }
    
    private func cancelBlSub(){
        if ShadhinCore.instance.defaults.subscriptionServiceID == ShadhinCoreSubscriptions.BL_DAILY ||
           ShadhinCore.instance.defaults.subscriptionServiceID == ShadhinCoreSubscriptions.BL_MONTHLY ||
           ShadhinCore.instance.defaults.subscriptionServiceID == ShadhinCoreSubscriptions.BL_HALF_YEARLY ||
           ShadhinCore.instance.defaults.subscriptionServiceID == ShadhinCoreSubscriptions.BL_YEARLY {
            ShadhinCore.instance.api.cancelBLSub{ success in
                ShadhinCore.instance.defaults.subscriptionServiceID = ""
                ShadhinCore.instance.defaults.isTelcoSubscribedUser = false
                self.checkCurrentSub()
                NotificationCenter.default.post(name: .didTapBackBkashPayment, object: nil)
            }
        }else{
            ShadhinApi.BLSubscription.cancelBLSub { result in
                switch result {
                case .success(let msg):
                    
                    if !msg.isEmpty,msg.lowercased() == "successful"{
                        AlertPopUp.show(self,
                                        image: #imageLiteral(resourceName: "shadhin_logo"),
                                        tileString: "Alert",
                                        msgString: msg,
                                        positiveString: nil,
                                        negativeString: nil,
                                        buttonDelegate: self)
                        
                        ShadhinCore.instance.defaults.subscriptionServiceID = ""
                        ShadhinCore.instance.defaults.isTelcoSubscribedUser = false
                        self.checkCurrentSub()
                        NotificationCenter.default.post(name: .didTapBackBkashPayment, object: nil)
                    } else {
                        AlertPopUp.show(self,
                                        image: #imageLiteral(resourceName: "shadhin_logo"),
                                        tileString: "Alert",
                                        msgString: msg,
                                        positiveString: nil,
                                        negativeString: nil,
                                        buttonDelegate: self)
                    }
                    
                case .failure(let failure):
                    AlertPopUp.show(self,
                                    image: #imageLiteral(resourceName: "shadhin_logo"),
                                    tileString: "Alert",
                                    msgString: failure.localizedDescription,
                                    positiveString: nil,
                                    negativeString: nil,
                                    buttonDelegate: self)
                }
                
            }
        }
    }
    
    private func cancelRobiSubNew(){
        
        if ShadhinCore.instance.defaults.subscriptionServiceID == ShadhinCoreSubscriptions.ROBI_DAILY || ShadhinCore.instance.defaults.subscriptionServiceID == ShadhinCoreSubscriptions.ROBI_MONTHLY ||
            ShadhinCore.instance.defaults.subscriptionServiceID == ShadhinCoreSubscriptions.ROBI_HALF_YEARLY ||
            ShadhinCore.instance.defaults.subscriptionServiceID == ShadhinCoreSubscriptions.ROBI_YEARLY {
            cancelRobiSub()
        } else if ShadhinCore.instance.defaults.subscriptionServiceID == ShadhinCoreSubscriptions.ROBI_DCB_DAILY_NEW ||
           ShadhinCore.instance.defaults.subscriptionServiceID == ShadhinCoreSubscriptions.ROBI_DCB_MONTHLY_NEW ||
           ShadhinCore.instance.defaults.subscriptionServiceID == ShadhinCoreSubscriptions.ROBI_DCB_HALF_YEARLY_NEW ||
           ShadhinCore.instance.defaults.subscriptionServiceID == ShadhinCoreSubscriptions.ROBI_DCB_YEARLY_NEW {
            ShadhinApi.RobiSubscription.cancelRobiSub { success in
                ShadhinCore.instance.defaults.subscriptionServiceID = ""
                ShadhinCore.instance.defaults.isTelcoSubscribedUser = false
                self.checkCurrentSub()
                NotificationCenter.default.post(name: .didTapBackBkashPayment, object: nil)
          }
        } else {
            ShadhinApi.RobiSubscription.cancelRobiSub { result in
                switch result {
                case .success(let msg):
                    
                    if !msg.isEmpty,msg.lowercased() == "successful"{
                        AlertPopUp.show(self,
                                        image: #imageLiteral(resourceName: "shadhin_logo"),
                                        tileString: "Alert",
                                        msgString: msg,
                                        positiveString: nil,
                                        negativeString: nil,
                                        buttonDelegate: self)
                        
                        ShadhinCore.instance.defaults.subscriptionServiceID = ""
                        ShadhinCore.instance.defaults.isTelcoSubscribedUser = false
                        self.checkCurrentSub()
                        NotificationCenter.default.post(name: .didTapBackBkashPayment, object: nil)
                    } else {
                        AlertPopUp.show(self,
                                        image: #imageLiteral(resourceName: "shadhin_logo"),
                                        tileString: "Alert",
                                        msgString: msg,
                                        positiveString: nil,
                                        negativeString: nil,
                                        buttonDelegate: self)
                    }
                    
                case .failure(let failure):
                    AlertPopUp.show(self,
                                    image: #imageLiteral(resourceName: "shadhin_logo"),
                                    tileString: "Alert",
                                    msgString: failure.localizedDescription,
                                    positiveString: nil,
                                    negativeString: nil,
                                    buttonDelegate: self)
                }
                
            }
        }
    }
    
    private func cancelRobiSub(){
        ShadhinCore.instance.api.cancelRobiSubscriptionNew { msg in
            if msg.lowercased().contains("successful"){
                ShadhinCore.instance.defaults.subscriptionServiceID = ""
                ShadhinCore.instance.defaults.isTelcoSubscribedUser = false
                self.checkCurrentSub()
                NotificationCenter.default.post(name: .didTapBackBkashPayment, object: nil)
            }else{
                AlertPopUp.show(self,
                                image: #imageLiteral(resourceName: "shadhin_logo"),
                                tileString: "Alert",
                                msgString: msg,
                                positiveString: nil,
                                negativeString: nil,
                                buttonDelegate: self)
            }
        }
    }
    
    func buttonTaped(_ state: AlertPopUp.State,_ intanceID: Int) {
        self.backBtnTapped("")
//        AppDelegate.shared?.checkUserSubscription()
    }
    
    
    private func cancelGpSub(){
 
        ShadhinCore.instance.api.cancelGpSub() { success in
            if success{
                ShadhinCore.instance.defaults.subscriptionServiceID = ""
                ShadhinCore.instance.defaults.isTelcoSubscribedUser = false
                self.checkCurrentSub()
                NotificationCenter.default.post(name: .didTapBackBkashPayment, object: nil)
            }
        }
    }
    private func cancelNewSSLAlert(){
        let message = "You have requested to Cancel Sslcommerz subscription. Are you sure?"
        let alertVC = UIAlertController(title: "Confirmation", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (action) in
            self.cancelNewSSL()
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(confirmAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    private func cancelSSL(){
        let message = "You have requested to Cancel Sslcommerz subscription. Are you sure?"
        let alertVC = UIAlertController(title: "Confirmation", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (action) in
            self.clearSubFromOurServer()
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(confirmAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    private func clearSubFromOurServer(){
        ShadhinCore.instance.api.tryClearFromShadhinServer(
            subscriptionID: ShadhinCore.instance.defaults.subscriptionServiceID,
            subscribeNumber: ShadhinCore.instance.defaults.userMsisdn)
        { ignore in
            //print("Cancel sub called update")
            ShadhinCore.instance.defaults.isBkashSubscribedUser = false
            ShadhinCore.instance.defaults.isSSLSubscribedUser = false
            ShadhinCore.instance.defaults.subscriptionServiceID = ""
            self.checkCurrentSub()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didTapBackBkashPayment, object: nil)
            }
        }
    }
    
    
    private func cancelBkashNew(){
        let message = "You have requested to Cancel Bkash subscription. Are you sure?"
        let alertVC = UIAlertController(title: "Confirmation", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (action) in
            ShadhinCore.instance.api.cancelBkashSubscriptionV2 { responseStr in
                if responseStr.uppercased() == "CANCELLED"{
                    ShadhinCore.instance.defaults.isBkashSubscribedUser = false
                    ShadhinCore.instance.defaults.subscriptionServiceID = ""
                    self.checkCurrentSub()
                    NotificationCenter.default.post(name: .didTapBackBkashPayment, object: nil)
                }else{
                    self.makeToast(msg: "Error : \(responseStr)")
                }
            }
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(confirmAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func cancelStripe(){
        ShadhinApi.StripeSubscription.subscriptionCancel(subscriptionId: ShadhinCore.instance.defaults.subscriptionIDForStripeAndSSL) { result in
            switch result {
            case .success(_):
                AlertPopUp.show(self,
                                image: #imageLiteral(resourceName: "shadhin_logo"),
                                tileString: "Alert",
                                msgString: "You canceled this subscription.",
                                positiveString: nil,
                                negativeString: nil,
                                buttonDelegate: self)
                
            case .failure(let failure):
                self.makeToast(msg: failure.localizedDescription)
            }
        }
    }
    
    func cancelNewSSL(){
        ShadhinApi.SSLSubscription.sslSubscriptionCancel(id: ShadhinCore.instance.defaults.subscriptionIDForStripeAndSSL) { result in
            switch result {
            case .success(let success):
                AlertPopUp.show(self,
                                image: #imageLiteral(resourceName: "shadhin_logo"),
                                tileString: "Alert",
                                msgString: success.message ?? "You canceled this subscription.",
                                positiveString: nil,
                                negativeString: nil,
                                buttonDelegate: self)
                
            case .failure(let failure):
                self.makeToast(msg: failure.localizedDescription)
            }
        }
    }
    
    func makeToast(msg: String) {
        self.view?.makeToast(msg, duration: 4, position: .bottom, title: nil, image: nil, style: .init()) { (success) in
        }
    }
    
 
    
//    private func showBkashHistory(){
//        //print("Called")
//        let vc = storyboard!.instantiateViewController(withIdentifier: "BkashSubHistoryVC") as! BkashSubHistoryVC
//        //let navVC = UINavigationController(rootViewController: vc)
//        present(vc, animated: true, completion: nil)
//    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
       // self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func termsAndUseAction(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "MyMusic", bundle: Bundle.ShadhinMusicSdk)
//        let webVC = storyBoard.instantiateViewController(withIdentifier: "SettingsWebViewVC") as! SettingsWebViewVC
//        webVC.btnTag = sender.tag
//        webVC.isFromSetting = false
//        let navVC = UINavigationController(rootViewController: webVC)
//        present(navVC, animated: true, completion: nil)
    }
    
    
//    private func goToPaymentOpts(_ method : PaymentOptsBdVC.PaymentMethod, _ willAutoRedirect : Bool = false){
//        
////        if ShadhinCoreSubscriptions.instance.shouldBlockFutherRequest{
////            self.view.makeToast("A bKash invoice is underprocess please wait up 10 mins to complete the process & restart the App")
////            return
//        }
//        if method == .telco, isUnsupportedTelco(){ //|| isNotInMobileData(){
//            return
//        }
        
        
//        
//        let vc = storyboard!.instantiateViewController(withIdentifier: "PaymentOptsBdVC") as! PaymentOptsBdVC
//        vc.selectedMethod = method
//        if willAutoRedirect{
//            vc.subscriptionPlanName = subscriptionPlanName
//        }
//        vc.navVC = self.navigationController
//        let height: CGFloat = vc.getHeight(method: method)//603
//        var attributes = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 0)
//        attributes.entryBackground = .color(color: .clear)
//        attributes.border = .none
//        SwiftEntryKit.display(entry: vc, using: attributes)
        
        //<-->
        
        
//        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
//        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
//        attributes.positionConstraints.keyboardRelation = keyboardRelation

        
        
        
        //<-->
        
        //self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func isUnsupportedTelco() -> Bool{        
        if ShadhinCore.instance.isAirtelOrRobi() ||
           ShadhinCore.instance.isGP()
        || ShadhinCore.instance.isBanglalink()
        {
            return false
        }else{
            if ShadhinCore.instance.defaults.userMsisdn.isEmpty{
//                LinkMsisdnVC.show("Phone number is required to proceed with BD subscriptions...")
//                return true
            }
            let alert = UIAlertController(title: "Notice", message: "Only GP, Banglalink & Robi/Airtel numbers are supported!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
          //  self.present(alert, animated: true, completion: nil)
            return true
        }
    }
    
    private func isNotInMobileData() -> Bool{
        
#if DEBUG
        return false
#endif
        
        if let status = ConnectionManager.shared.reachability?.connection, status == .cellular{
            return false
        } else {
            let alert = UIAlertController(title: "Notice", message: "Mobile Data is required for telco charging, Please switch to Mobile Data.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
           // self.present(alert, animated: true, completion: nil)
            return true
        }
    }
    
