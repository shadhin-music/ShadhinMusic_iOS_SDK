//
//  SettingDetailsVC.swift
//  Shadhin_Gp
//
//  Created by MD Murad Hossain  on 13/10/25.
//

import UIKit

class SettingDetailsVC: UIViewController, NIBVCProtocol {

    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var darkModeDataArray: [DarkModeData] = [
        DarkModeData(title: "On", appModeType: .dark),
        DarkModeData(title: "Off", appModeType: .light),
        DarkModeData(title: "Use System Settings",
                     appModeType: .system,
                     subTitle: "We’ll adjust your appearance based on your device’s system settings.",
                     isSystemMode: true),
    ]
    
    var settingType = SettingEnumType.darkMode
    private var helpCenterItemCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupCollectionView()
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SettingDetailsVC {
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SettingDarkModeCVCell.nib, forCellWithReuseIdentifier: SettingDarkModeCVCell.identifier)
        collectionView.register(HelpCenterCVCell.nib, forCellWithReuseIdentifier: HelpCenterCVCell.identifier)
        collectionView.register(HelpCenterCVCell2.nib, forCellWithReuseIdentifier: HelpCenterCVCell2.identifier)
        collectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        collectionView.reloadData()
        
        switch settingType {
            
        case .darkMode:
            // Auto-select the current app mode
            self.navTitleLabel.text = "Dark Mode"
            if let selectedIndex = darkModeDataArray.firstIndex(where: { $0.appModeType == ShadhinCore.instance.defaults.appModeType }) {
                let indexPath = IndexPath(row: selectedIndex, section: 0)
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
            }
            
        case .helpCenter:
            self.navTitleLabel.text = "Help Center"
        }
    }
}


extension SettingDetailsVC : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settingType == .darkMode ? darkModeDataArray.count : 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch settingType {
            
        case .darkMode:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingDarkModeCVCell.identifier, for: indexPath) as! SettingDarkModeCVCell
            cell.dataBindCell(data: darkModeDataArray[indexPath.row])
            cell.bgView.applyCornerStyle(isFirst: indexPath.row == 0, isLast: indexPath.row == darkModeDataArray.count - 1)
            return cell
            
        case .helpCenter:
            
            switch indexPath.row {
            case 0:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HelpCenterCVCell.identifier, for: indexPath) as! HelpCenterCVCell
                
                cell.sendEmailClick = {
                    self.sendEmail()
                }
                
                cell.sendMessengerClick = {
                    self.sendMessenger()
                }
                
                return cell
                
            case 1:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HelpCenterCVCell2.identifier, for: indexPath) as! HelpCenterCVCell2
                cell.delegate = self
                return cell
                
            default:
                return UICollectionViewCell()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch settingType {
            
        case .darkMode:
            let selectedMode = darkModeDataArray[indexPath.row].appModeType
            
            switch selectedMode {
            case .dark:
                overrideUserInterfaceStyle = .dark
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
                UserDefaults.standard.set("dark", forKey: "AppAppearance")
                ShadhinCore.instance.defaults.isLighTheam = false
                ShadhinCore.instance.defaults.appModeType = .dark
            case .light:
                overrideUserInterfaceStyle = .light
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
                UserDefaults.standard.set("light", forKey: "AppAppearance")
                ShadhinCore.instance.defaults.isLighTheam = true
                ShadhinCore.instance.defaults.appModeType = .light
            case .system:
                overrideUserInterfaceStyle = .unspecified
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
                UserDefaults.standard.set("system", forKey: "AppAppearance")
                let currentStyle = UIScreen.main.traitCollection.userInterfaceStyle
                ShadhinCore.instance.defaults.appModeType = .system
                ShadhinCore.instance.defaults.isLighTheam = (currentStyle == .light)
            }
            
        case .helpCenter:
            break

        }
        
    }
}


extension SettingDetailsVC : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch settingType {
        case .darkMode:
            return CGSize(width: self.collectionView.bounds.width, height: indexPath.row == 2 ? 95 : 68)
            
        case .helpCenter:
            
            switch indexPath.row {
            case 0:
                return CGSize(width: self.collectionView.bounds.width, height: 159)
                
            case 1:
                let dynamicHeight = 108 + (68 * helpCenterItemCount)
                return CGSize(width: self.collectionView.bounds.width, height: CGFloat(dynamicHeight))

            default:
                return CGSize(width: self.collectionView.bounds.width, height: 50)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension SettingDetailsVC: HelpCenterCVCell2Delegate {
    func didSelectHelpCenterData(_ data: [FAQSubCategory], navTitle: String) {
        let vc = SettingSubDetailsVC.instantiateNib()
        vc.helpCenterSubData = data
        vc.titleText = navTitle
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func helpCenterCell2DidUpdateHeight(_ cell: HelpCenterCVCell2, itemCount: Int) {
        self.helpCenterItemCount = itemCount
        self.collectionView.performBatchUpdates(nil)
    }
}
