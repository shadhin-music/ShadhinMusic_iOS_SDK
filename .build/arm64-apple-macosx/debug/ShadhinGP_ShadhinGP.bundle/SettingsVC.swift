//
//  SettingsVC.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/3/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit
import CoreData

class SettingsVC: UIViewController {
        
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var upgradeProLbl: UILabel!
    @IBOutlet weak var getProBtn: UIButton!
    @IBOutlet weak var unsubscriptionBtn: UIButton!
    @IBOutlet weak var userPointLbl: UILabel!
    @IBOutlet weak var appVersionStackView: UIStackView!
    @IBOutlet weak var appVersion: UILabel!
    
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var updateLabel: UILabel!
    @IBOutlet weak var updateImg: UIImageView!
    @IBOutlet weak var profileHolder: UIView!
    
    
    private var countNumber = 0
    private var loadingIndicator: VGPlayerLoadingIndicator! = nil
    
    var subscriptionType: String?
    var serviceID: String?
    var appleSubsType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customBGColor()
        self.navigationItem.title = "Settings"
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.appVersion.text = "App Version \(version)"
        }
        ShadhinCore.instance.addNotifier(notifier: self)
        self.updateUserProfile()
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserProfile), name: .didTapBackBkashPayment, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserProfile), name: .facebookProfileUpdated, object: nil)
        addGestureToStackView()
        profileHolder.setClickListener {
          //  let vc = MyProfileVC()
           // self.navigationController?.pushViewController(vc, animated: true)
        }
        
        //ShadhinApi.StripeSubscription.getStripSubscriptionStatus()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        ShadhinCore.instance.removeNotifier(notifier: self)
    }
    
    @objc fileprivate func updateUserProfile() {
        //Update facebook profile section.
//        if !LoginService.instance.facebookProfileName.isEmpty && !LoginService.instance.facebookProfileImage.isEmpty{
//            //updateBtn.isHidden = true
//            //updateLabel.isHidden = true
//            //updateImg.isHidden = true
//        }
        
        //self.nameLbl.text = LoginService.instance.facebookProfileName != "" ? LoginService.instance.facebookProfileName : LoginService.instance.mobileNumber
        self.nameLbl.text = ShadhinCore.instance.defaults.userIdentity
        self.imgView.kf.indicatorType = .activity
        self.imgView.kf.setImage(with: URL(string: ShadhinCore.instance.defaults.userProPicUrl.safeUrl()),placeholder: UIImage(named: "ic_user_2",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        
        if ShadhinCore.instance.isUserPro{
            // print("LOOOK --> 2")
            if ShadhinCore.instance.defaults.isBkashSubscribedUser  ||
                ShadhinCore.instance.defaults.isSSLSubscribedUser    ||
                ShadhinCore.instance.defaults.isNagadSubscribedUser    ||
                ShadhinCore.instance.defaults.isTelcoSubscribedUser{
                subscriptionType = "bKash"
                serviceID =  ShadhinCore.instance.defaults.subscriptionServiceID
                
               // print("LOOOK --> \(subscriptionType)       \(serviceID)")
            } else if ShadhinCore.instance.defaults.isStripeSubscriptionUser{
                subscriptionType = "stripe"
            }else{
                if SubscriptionAppleProducts.store.isProductPurchased(SubscriptionAppleProducts.yearlySub){
                    self.appleSubsType = "yearly"
                }else if SubscriptionAppleProducts.store.isProductPurchased(SubscriptionAppleProducts.monthlySub) {
                    self.appleSubsType = "monthly"
                }
            }
        }
        
        //update subscription view section.
        if subscriptionType == "bKash" {
            switch serviceID {
            case ShadhinCoreSubscriptions.BKASH_DAILY_NEW,
                ShadhinCoreSubscriptions.GP_DAILY,
                ShadhinCoreSubscriptions.GP_DAILY_NEW,
                ShadhinCoreSubscriptions.GP_DAILY_NEWV2,
                ShadhinCoreSubscriptions.NAGAD_DAILY,
                ShadhinCoreSubscriptions.ROBI_DAILY,
                ShadhinCoreSubscriptions.ROBI_DCB_DAILY_NEW,
                ShadhinCoreSubscriptions.BL_DAILY,
                ShadhinCoreSubscriptions.BL_DAILY_NEWV2:
                self.changeUpgradeLblWithSubsType(type: "daily")
            case ShadhinCoreSubscriptions.ROBI_3DAY_DATA_PACK,
                ShadhinCoreSubscriptions.AIRTEL_3DAY_DATA_PACK:
                self.changeUpgradeLblWithSubsType(type: "3day")
            case ShadhinCoreSubscriptions.ROBI_WEEKLY_DATA_PACK,
                ShadhinCoreSubscriptions.AIRTEL_WEEKLY_DATA_PACK,
                ShadhinCoreSubscriptions.UMOBILE_SUBSCRIPTION_WEEKLY:
                self.changeUpgradeLblWithSubsType(type: "weekly")
            case ShadhinCoreSubscriptions.ROBI_15DAY_DATA_PACK,
                ShadhinCoreSubscriptions.AIRTEL_15DAY_DATA_PACK:
                self.changeUpgradeLblWithSubsType(type: "15day")
            case "110",
                 "112",
                 "502",
                 "261",
                ShadhinCoreSubscriptions.COUPON,
                ShadhinCoreSubscriptions.BKASH_MONTHLY_NEW,
                ShadhinCoreSubscriptions.GP_MONTHLY,
                ShadhinCoreSubscriptions.GP_MONTHLY_NEW,
                ShadhinCoreSubscriptions.ROBI_MONTHLY,
                ShadhinCoreSubscriptions.ROBI_DCB_MONTHLY_NEW,
                ShadhinCoreSubscriptions.NAGAD_MONTHLY,
                ShadhinCoreSubscriptions.GP_MONTHLY_PLUS,
                ShadhinCoreSubscriptions.BL_MONTHLY,
                ShadhinCoreSubscriptions.BL_MONTHLY_NEW,
                ShadhinCoreSubscriptions.ROBI_MONTHLY_DATA_PACK,
                ShadhinCoreSubscriptions.UMOBILE_SUBSCRIPTION_MONTHLY,
                ShadhinCoreSubscriptions.AIRTEL_MONTHLY_DATA_PACK:
                  self.changeUpgradeLblWithSubsType(type: "monthly")
            case "111",
                 "113",
                 "262",
                 "1",
                 "2269",
                ShadhinCoreSubscriptions.BKASH_HALF_YEARLY_NEW,
                ShadhinCoreSubscriptions.ROBI_HALF_YEARLY,
                ShadhinCoreSubscriptions.ROBI_DCB_HALF_YEARLY_NEW,
                ShadhinCoreSubscriptions.GP_HALF_YEARLY,
                ShadhinCoreSubscriptions.GP_HALF_YEARLY_NEW,
                ShadhinCoreSubscriptions.NAGAD_HALF_YEARLY,
                ShadhinCoreSubscriptions.SSL_HALF_YEARLY,
                ShadhinCoreSubscriptions.BL_HALF_YEARLY,
                ShadhinCoreSubscriptions.BL_HALF_YEARLY_NEW,
                ShadhinCoreSubscriptions.SSL_HALF_YEARLY_NEW:
                    self.changeUpgradeLblWithSubsType(type: "halfyearly")
            case "263",
                 "2",
                ShadhinCoreSubscriptions.ROBI_YEARLY,
                ShadhinCoreSubscriptions.ROBI_DCB_YEARLY_NEW,
                ShadhinCoreSubscriptions.BKASH_YEARLY_NEW,
                ShadhinCoreSubscriptions.BL_YEARLY,
                ShadhinCoreSubscriptions.BL_YEARLY_NEW,
                ShadhinCoreSubscriptions.NAGAD_YEARLY,
                ShadhinCoreSubscriptions.GP_YEARLY_NEW,
                ShadhinCoreSubscriptions.GP_YEARLY:
                self.changeUpgradeLblWithSubsType(type: "yearly")
            case ShadhinCoreSubscriptions.BANGLA_LINK_DATA_PACK:
                self.changeUpgradeLblWithSubsType(type: "datapack")
            default:
                self.changeUpgradeLblWithSubsType(type: "")
            }
        }else if subscriptionType == "stripe"{
            if ShadhinCore.instance.defaults.subscriptionServiceID == ShadhinCoreSubscriptions.STRIPE_MONTHLY{
                self.changeUpgradeLblWithSubsType(type: "monthly")
            }else{
                self.changeUpgradeLblWithSubsType(type: "yearly")
            }
        }
        else {
            switch appleSubsType {
            case "monthly":
                self.changeUpgradeLblWithSubsType(type: "monthly")
            case "yearly":
                self.changeUpgradeLblWithSubsType(type: "yearly")
            default:
                self.changeUpgradeLblWithSubsType(type: "")
            }
        }
        //Update user point section.
        ShadhinCore.instance.api.getStreamingPoints { success, totalCount in
            if success {
                self.userPointLbl.text = totalCount
            }
        }
    }
    
//    fileprivate func enableFacebookLogin() {
//        
//        let manager = LoginManager()
//        manager.logOut()
//        manager.logIn(permissions: ["public_profile", "email"], from: self) { result, error in
//            if (result?.token) != nil{
//                ThirdPartyService.instance.getFacebookUserProfileInfo { (success, id, profileName, imageUrl) in
//                    if success {
//                        //Saving user data to offline.
//                        //print("User id is: \(id)")
//                        LoginService.instance.facebookProfileName  = profileName ?? ""
//                        LoginService.instance.facebookProfileImage = imageUrl ?? ""
//                        AuthService.instance.updatefFacebookInfo()
//                        NotificationCenter.default.post(name: .facebookProfileUpdated, object: nil)
//                        self.viewDidLoad()
//                    } else {
//                        self.makeToastAndRemoveSwiftEntryKit(msg: "Something went wrong, please try again later.")
//                    }
//                }
//            }
//        }
//    }
    
    fileprivate func addGestureToStackView() {
        self.appVersion.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickAppVersionStackView))
        appVersion.addGestureRecognizer(tapGesture)
    }
    
    fileprivate func changeUpgradeLblWithSubsType(type: String) {
        
        //print("changeUpgradeLblWithSubsType   \(type)")
        switch type {
        case "daily":
            self.upgradeProLbl.text = "DAILY"
            self.upgradeProLbl.textColor = #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1)
            self.getProBtn.isHidden = true
            self.getProBtn.isUserInteractionEnabled = false
            self.unsubscriptionBtn.isHidden = false
            self.unsubscriptionBtn.isUserInteractionEnabled = true
        case "3day":
            self.upgradeProLbl.text = "3 DAYS"
            self.upgradeProLbl.textColor = #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1)
            self.getProBtn.isHidden = true
            self.getProBtn.isUserInteractionEnabled = false
            self.unsubscriptionBtn.isHidden = false
            self.unsubscriptionBtn.isUserInteractionEnabled = true
        case "weekly":
            self.upgradeProLbl.text = "WEEKLY"
            self.upgradeProLbl.textColor = #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1)
            self.getProBtn.isHidden = true
            self.getProBtn.isUserInteractionEnabled = false
            self.unsubscriptionBtn.isHidden = false
            self.unsubscriptionBtn.isUserInteractionEnabled = true
        case "15day":
            self.upgradeProLbl.text = "15 DAYS"
            self.upgradeProLbl.textColor = #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1)
            self.getProBtn.isHidden = true
            self.getProBtn.isUserInteractionEnabled = false
            self.unsubscriptionBtn.isHidden = false
            self.unsubscriptionBtn.isUserInteractionEnabled = true
        case "monthly":
            self.upgradeProLbl.text = "MONTHLY"
            self.upgradeProLbl.textColor = #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1)
            self.getProBtn.isHidden = true
            self.getProBtn.isUserInteractionEnabled = false
            self.unsubscriptionBtn.isHidden = false
            self.unsubscriptionBtn.isUserInteractionEnabled = true
        case "yearly":
            self.upgradeProLbl.text = "YEARLY"
            self.upgradeProLbl.textColor = #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1)
            self.getProBtn.isHidden = true
            self.getProBtn.isUserInteractionEnabled = false
            self.unsubscriptionBtn.isHidden = false
            self.unsubscriptionBtn.isUserInteractionEnabled = true
        case "halfyearly":
            self.upgradeProLbl.text = "HALF YEARLY"
            self.upgradeProLbl.textColor = #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1)
            self.getProBtn.isHidden = true
            self.getProBtn.isUserInteractionEnabled = false
            self.unsubscriptionBtn.isHidden = false
            self.unsubscriptionBtn.isUserInteractionEnabled = true
        case "datapack":
            self.upgradeProLbl.text = "DATA PACK"
            self.upgradeProLbl.textColor = #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1)
            self.getProBtn.isHidden = true
            self.getProBtn.isUserInteractionEnabled = false
            self.unsubscriptionBtn.isHidden = false
            self.unsubscriptionBtn.isUserInteractionEnabled = true
        default:
            self.upgradeProLbl.text = "UPGRADE TO PRO"
            //self.upgradeProLbl.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.getProBtn.isHidden = false
            self.getProBtn.isUserInteractionEnabled = true
            self.unsubscriptionBtn.isHidden = false
            self.unsubscriptionBtn.isUserInteractionEnabled = true
        }
    }
    
    func makeToastAndRemoveSwiftEntryKit(msg: String) {
        self.view?.makeToast(msg, duration: 3, position: .bottom, title: nil, image: nil, style: .init()) { (success) in
            SwiftEntryKit.dismiss()
        }
    }
    
    // MARK: - Developer free version mode.
    @objc private func clickAppVersionStackView() {
        countNumber += 1
        if countNumber >= 10  {
            //ShadhinCoreSubscriptions.instance.subscriptionStatus = true
            //print("SUBED")
            //LoginService.instance.isUserSubscribed = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @IBAction func didTapLogoutBtn(_ sender: UIButton) {
        AudioPlayer.shared.stop()
        if MusicPlayerV3.audioPlayer.state == .stopped {
            let didReferedSignUp = ShadhinCore.instance.defaults.didReferedSignUp
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
         //   LoginManager().logOut()
            ShadhinCore.instance.api.clearDatabase()
            ShadhinCore.instance.defaults.didReferedSignUp = didReferedSignUp
            
            DispatchQueue.main.async {
//                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//                if let tabbar = (storyBoard.instantiateViewController(withIdentifier: "MainTabBar") as? MainTabBar)
//                    let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//                    tabbar.modalPresentationStyle = .fullScreen
//                    tabbar.modalTransitionStyle = .crossDissolve
//                    appDelegate.checkUserSubscription()
//                    let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
//                    if let first = tabbar.viewControllers?.first, let home = first as? HomeVCv3{
//                        Log.info("Home V3")
//                    }
//                    keyWindow?.rootViewController = tabbar
//                    keyWindow?.makeKeyAndVisible()
//
//                }
            }
            
        }
    }
    
    
//    public func clearDatabase() {
////        let appDelegate = UIApplication.shared.delegate as! AppDelegate
////        guard let url = appDelegate.persistentContainer.persistentStoreDescriptions.first?.url else { return }
////
////        let persistentStoreCoordinator = appDelegate.persistentContainer.persistentStoreCoordinator
////
////        do {
////            try persistentStoreCoordinator.destroyPersistentStore(at:url, ofType: NSSQLiteStoreType, options: nil)
////            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
////        } catch let error {
////            print("Attempted to clear persistent store: " + error.localizedDescription)
////        }
//
//        resetAllRecords(in: "AlbumMyMusic")
//        resetAllRecords(in: "FavoritesMyMusic")
//        resetAllRecords(in: "RecentlyPlayed")
//        resetAllRecords(in: "VideoHistoryAndWatchLater")
//    }
    
//    func resetAllRecords(in entity : String){
//        let context = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
//        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
//        do{
//            try context.execute(deleteRequest)
//            try context.save()
//        }
//        catch{
//            Log.error(error.localizedDescription)
//        }
//    }
    
  
    @IBAction func updateProfileUsingFacebook(_ sender: UIButton) {
//        if !LoginService.instance.facebookProfileName.isEmpty && !LoginService.instance.facebookProfileImage.isEmpty{
//            willRemoveFBLogin()
//        }else{
//            self.enableFacebookLogin()
//        }
    }
    
    func willRemoveFBLogin(){
        let alertVC = UIAlertController(title: "Confirmation", message: "Disconnect facebook profile from Shadhin?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (action) in
            self.shouldRemoveFBLogin()
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(confirmAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func shouldRemoveFBLogin(){
        ShadhinCore.instance.api.removeSocialCredentials { isSuccess in
            if isSuccess{
                //LoginService.instance.facebookProfileName  = ""
                //LoginService.instance.facebookProfileImage = ""
                NotificationCenter.default.post(name: .facebookProfileUpdated, object: nil)
            }
        }
    }
    
    @IBAction func getProAction(_ sender: Any) {
        self.goSubscriptionTypeVC()
        SMAnalytics.gotoPro()
        
    }
    
    @IBAction func didTapUnsubscriptionBtn(_ sender: UIButton) {
         self.goSubscriptionTypeVC()
    }
    
//    @IBAction func openContactUs(_ sender: UIButton) {
//        let contactUsVC = ContactUsVC()
//        let height: CGFloat = 238
//        SwiftEntryKit.display(entry: contactUsVC, using: SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 8))
//    }
    
    @IBAction func generalSettingsAction(_ sender: UIButton) {
         performSegue(withIdentifier: "toWebViewVC", sender: sender.tag)
    }
    
    @IBAction func pushNotifSwitchAction(_ sender: UISwitch) {
        if sender.isOn {
            UIApplication.shared.registerForRemoteNotifications()
        }else {
            UIApplication.shared.unregisterForRemoteNotifications()
        }
    }
    
    @IBAction func appstoreAction(_ sender: Any) {
        #if DEBUG
        let leaderboard = HomeVCv3.instantiateNib()
        self.navigationController?.pushViewController(leaderboard, animated: true)
        #else
        
        if let url = URL(string: "https://apps.apple.com/us/app/shadhin-music/id1481808365"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        #endif
        
    }
    
//    @IBAction func openAccountDeletion(_ sender: Any) {
//        let vc = AccountDeletion()
//        var attribute = SwiftEntryKitAttributes.bottomAlertWrapAttributesRound(offsetValue: 8)
//        attribute.entryBackground = .color(color: .clear)
//        attribute.border = .none
//        attribute.positionConstraints.size = .init(width: .fill, height: .intrinsic)
//        SwiftEntryKit.display(entry: vc, using: attribute)
//    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let vc = segue.destination as? SettingsWebViewVC {
//            if let tag = sender as? Int {
//                vc.btnTag = tag
//            }
//        }
//    }
}

extension SettingsVC: ShadhinCoreNotifications{
    func profileInfoUpdated() {
        updateUserProfile()
    }
}

extension SettingsVC {
    //For reference purpose
    
    // MARK: - init Core Data
//    private func reinitCoreDataStore() {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let persistentStoreCoordinator = appDelegate.persistentContainer
//        persistentStoreCoordinator.loadPersistentStores { (des, err) in
//            persistentStoreCoordinator.viewContext.automaticallyMergesChangesFromParent = true
//        }
//    }
    
//    // MARK: - Destroy Core Data Store
//    private func destroyPersistentStore() {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let persistentStoreCoordinator = appDelegate.persistentContainer.persistentStoreCoordinator
//        guard let firstStoreURL = persistentStoreCoordinator.persistentStores.first?.url else {
//            Log.error("Missing first store URL - could not destroy")
//            return
//        }
//        
//        do {
//            try persistentStoreCoordinator.destroyPersistentStore(at: firstStoreURL, ofType: NSSQLiteStoreType, options: nil)
//        } catch  {
//            Log.error("Unable to destroy persistent store: \(error) - \(error.localizedDescription)")
//        }
//    }
}
