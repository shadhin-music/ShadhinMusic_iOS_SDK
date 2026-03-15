//
//  MyMusicViewCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/24/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit


class MyMusicViewCell: UITableViewCell {
    
    public typealias MyMusicCategories = (_ tag: Int)->()
    public typealias MyMusicViewClicked = (_ tag: Int)->()
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var numberLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var upgradeProLbl: UILabel!
    @IBOutlet weak var getProBtn: UIButton!
    @IBOutlet weak var userHolder: UIStackView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNumberLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var appleSubscriptionView: UIView!
    @IBOutlet weak var bKashSubscriptionView: UIView!
    @IBOutlet weak var bKashPlanLabel: UILabel!
    @IBOutlet weak var getProBkashBtn: UIButton!
    @IBOutlet weak var activationSubLabel: UILabel!
    @IBOutlet weak var referalView: UIView!
    @IBOutlet weak var referalViewHeight: NSLayoutConstraint!
    @IBOutlet weak var referalPointsEarned: UILabel!
    @IBOutlet weak var cashBackView: UIView!
    @IBOutlet weak var cashBackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var cashbackTitle: UILabel!
    @IBOutlet weak var cashbackLabel: UILabel!
    @IBOutlet weak var playlistShareHolder: UIView!
    @IBOutlet weak var playlistShareCounter: UILabel!
    @IBOutlet weak var playlistShareHeight: NSLayoutConstraint!
    @IBOutlet weak var couponHolder: UIView!
    
    
    private var categories: MyMusicCategories?
    private var myMusicViewClick: MyMusicViewClicked?
    
    var bKashServiceID: String?
    var subsType: String?
    var appleSubsType: String?
    
    var shareCounter = 0{
        didSet{
            if playlistShareCounter != nil{
                playlistShareCounter.text = String(shareCounter)
            }
        }
    }
    
    var spinner = UIActivityIndicatorView(style: .gray)
    
    override func awakeFromNib() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfile), name: .facebookProfileUpdated, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(updateSubscription), name: .didTapBackBkashPayment, object: nil)
       // self.settingIconOutlet.tintColor = .customLabelColor(color: .black)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        playlistShareCounter.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: playlistShareCounter.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: playlistShareCounter.centerYAnchor).isActive = true
        ShadhinCore.instance.addNotifier(notifier: self)
        self.bKashSubscriptionView.alpha = 0
        addNewSubscriptionObserver()
        checkNewSubscription()
        setProfileImage()
    }
    
    func setProfileImage() {
        if let userInfo = UserInfoViewModel.shared.userInfo{
            profileImg.kf.setImage(with: URL(string: userInfo.userPic?.safeUrl() ?? ""),placeholder: UIImage(named: "ic_profile_img",in: Bundle.ShadhinMusicSdk,with: nil))
            userName.text = userInfo.userFullName
            phoneNumber.text = userInfo.phoneNumber
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        ShadhinCore.instance.removeNotifier(notifier: self)
    }
    
    fileprivate func updateFacebookProfileInfo() {
        let userName = ShadhinCore.instance.defaults.userName
        if userName.isEmpty{
            self.userNumberLabel.text = "User"
        }else{
            self.userNumberLabel.text = userName
        }
        self.userNameLabel.text = ShadhinCore.instance.defaults.userIdentity
        self.userImageView.kf.setImage(with: URL(string: ShadhinCore.instance.defaults.userProPicUrl.safeUrl()),placeholder: UIImage(named: "ic_user_2",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
    }
    
    func checkNewSubscription() {
        if ShadhinCore.instance.isUserPro {
            if let newSubscriptionDetails = ShadhinCore.instance.defaults.newSubscriptionDetails {
                self.getProBtn.isHidden = true
                self.subsType = newSubscriptionDetails.operator
                self.bKashPlanLabel.text = "\(newSubscriptionDetails.planType ?? "") Plan Activated"
                self.bKashSubscriptionView.alpha = 1
                self.appleSubscriptionView.alpha = 0
            }
        } else {
            getProBtn.isHidden = false
            bKashPlanLabel.text = "UPGRADE TO PRO"
            self.bKashSubscriptionView.alpha = 0
            self.appleSubscriptionView.alpha = 1
        }
    }
    
    func updateUserProfile() {
        self.updateFacebookProfileInfo()
    }
    
    func getStreamCounter(){
        playlistShareCounter.text = ""
        spinner.startAnimating()
        ShadhinCore.instance.api.getUserStreamingPoints{ count in
            self.spinner.stopAnimating()
            self.shareCounter = count
        }
    }
    
 
    @IBAction func notficationAction(_ sender: UIButton) {
        myMusicViewClick?(sender.tag)
    }
    
    @IBAction func didTapGoBKashPricingFromActivatedButton(_ sender: UIButton) {
        myMusicViewClick?(sender.tag)
    }
    
    func didMyMusicViewClicked(_ completion: @escaping MyMusicViewClicked) {
        myMusicViewClick = completion
    }
    
    @IBAction func myMusicCategories(_ sender: UIButton) {
        categories?(sender.tag)
        ShadhinCore.instance.isHomeLoaded = true
    }
    
    @IBAction func didTapGetProBtn(_ sender: UIButton) {
        categories?(sender.tag)
    }
    
    func didMyMusicCategoriesClicked(_ completion: @escaping MyMusicCategories) {
        categories = completion
    }
    
    @objc private func updateProfile() {
        self.updateFacebookProfileInfo()
    }
}


extension MyMusicViewCell: ShadhinCoreNotifications{
    func profileInfoUpdated() {
        updateFacebookProfileInfo()
    }
}

// MARK: - New Subscription
extension MyMusicViewCell {
    private func addNewSubscriptionObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewSubscriptionSuccess(_:)), name: .newSubscriptionUpdate, object: nil)
    }
    
    @objc func handleNewSubscriptionSuccess(_ sender: Any) {
        checkNewSubscription()
    }
}
