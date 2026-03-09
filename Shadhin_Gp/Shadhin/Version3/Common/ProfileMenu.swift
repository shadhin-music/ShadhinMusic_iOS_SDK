//
//  ProfileMenu.swift
//  Shadhin_Gp_Examaple
//
//  Created by MD Murad Hossain  on 9/10/25.
//


import UIKit

enum ProfileMenu: CaseIterable {
    case settings
    case shadhinPro
    case helpSupport
    case inviteFriends
    
    var title: String {
        switch self {
        case .settings: return "Settings"
        case .shadhinPro: return ShadhinCore.instance.isUserPro ? "My Subscription" : "Shadhin Pro"
        case .helpSupport: return "Help & Support"
        case .inviteFriends: return "Invite Friends"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .settings:
            return UIImage(named: "settings_icon", in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        case .shadhinPro:
            return UIImage(named: "crown_icon", in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        case .helpSupport:
            return UIImage(named: "headphone_icon", in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        case .inviteFriends:
            return UIImage(named: "shareapp_icon_2", in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        }
    }
}
