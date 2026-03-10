//
//  SettingsV3VC.swift
//  Shadhin_Gp
//
//  Created by MD Murad Hossain  on 12/10/25.
//

import UIKit

class SettingsV3VC: UIViewController, NIBVCProtocol {
    
    // MARK: --- Outlet Properties ---
    @IBOutlet weak var stackBgView: UIView!
    @IBOutlet weak var subscriptionTitle: UILabel!
    @IBOutlet weak var supportImgView: UIImageView!
    @IBOutlet weak var subscriptionImgView: UIImageView!
    @IBOutlet weak var darkModeImgView: UIImageView!
    @IBOutlet weak var shareAppImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupWillApper()
    }

    // MARK: --- Button Action ---
    
    @IBAction func subsctionBtnAction(_ sender: UIButton) {
        self.gotoProVC()
    }
    
    @IBAction func modeTypeBtnAction(_ sender: UIButton) {
        self.gotoSettingDetailsVC(type: .darkMode)
    }
    
    @IBAction func helpSupportBtnAction(_ sender: UIButton) {
        self.gotoSettingDetailsVC(type: .helpCenter)
    }
    
    @IBAction func shareAppBtnAction(_ sender: UIButton) {
        self.shareAppLink()
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}


// MARK: --- Private Methods ---

extension SettingsV3VC {
    
    private func setupUI() {
        self.stackBgView.layer.cornerRadius = 20
    }
    
    private func setupWillApper() {
        self.applyAppTheme()
        self.supportImgView.image = UIImage(named: "headphone_icon", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
        self.subscriptionImgView.image = UIImage(named: "crown_icon", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
        self.darkModeImgView.image = UIImage(named: "modetype_icon", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
        self.shareAppImgView.image = UIImage(named: "shareapp_icon", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
        self.subscriptionTitle.text = ShadhinCore.instance.isUserPro ? "My Subscriptions" : "Subscriptions"
    }
    
    private func gotoProVC() {
        let proVC = SubscriptionVCv3.instantiateNib()
        proVC.isSettigns = true
        let navController = UINavigationController(rootViewController: proVC)
        navController.modalPresentationStyle = .fullScreen
        navController.navigationItem.hidesBackButton = true
        navController.setNavigationBarHidden(true, animated: true)
        self.present(navController, animated: false, completion: nil)
    }
    
    private func gotoSettingDetailsVC(type: SettingEnumType) {
        let vc = SettingDetailsVC.instantiateNib()
        vc.settingType = type
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
