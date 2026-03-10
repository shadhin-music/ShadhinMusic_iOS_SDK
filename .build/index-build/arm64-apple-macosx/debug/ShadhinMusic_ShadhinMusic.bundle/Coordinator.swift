//
//  Coordinator.swift
//  Shadhin-BL
//
//  Created by Joy on 22/8/22.
//

import Foundation
import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}
//this use for
protocol NIBVCProtocol{
    static func instantiateNib() -> Self
}
        
extension NIBVCProtocol where Self: UIViewController {
    static func instantiateNib() -> Self {
        let name = String(describing: self)
        let vc = Self.init(nibName: name, bundle: Bundle.ShadhinMusicSdk)
        vc.applyAppTheme()
        return vc
    }
    
}

protocol Storyboarded {
    static func instantiate() -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate() -> Self {
        // this pulls out "MyApp.MyViewController"
        let fullName = NSStringFromClass(self)

        // this splits by the dot and uses everything after, giving "MyViewController"
        let className = fullName.components(separatedBy: ".")[1]

        // load our storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.ShadhinMusicSdk)

        // instantiate a view controller with that identifier, and force cast as the type that was requested
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }
}


extension Bundle{
    static var ShadhinMusicSdk : Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: HomeVCv3.self)
        #endif
    }
}


extension UIViewController {
    
    func applyAppTheme() {
        if #available(iOS 13.0, *) {
            let appMode = ShadhinCore.instance.defaults.appModeType
            let window = UIApplication.shared.windows.first
            
            switch appMode {
            case .light:
                overrideUserInterfaceStyle = .light
                window?.overrideUserInterfaceStyle = .light
                ShadhinCore.instance.defaults.isLighTheam = true
            case .dark:
                overrideUserInterfaceStyle = .dark
                window?.overrideUserInterfaceStyle = .dark
                ShadhinCore.instance.defaults.isLighTheam = false
            case .system:
                overrideUserInterfaceStyle = .unspecified
                window?.overrideUserInterfaceStyle = .unspecified
                let currentStyle = UIScreen.main.traitCollection.userInterfaceStyle
                ShadhinCore.instance.defaults.isLighTheam = (currentStyle == .light)
            }
        }
    }
}
