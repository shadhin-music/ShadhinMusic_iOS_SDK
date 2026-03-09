//
//  NavigationHelper.swift
//  Shadhin_Gp
//
//  Created by Maruf on 19/8/24.
//

import Foundation

class NavigationHelper {
    static let shared = NavigationHelper()
    private init() {}

     func navigateToSubscription(from viewController: UIViewController?) {
         // Instantiate the view controller
                 let anotherViewController = SubscriptionVCv3.instantiateNib()
                 
                 // Create a new navigation controller with the target view controller as its root
                 let navController = UINavigationController(rootViewController: anotherViewController)
                 
                 // Customize the navigation controller
                 navController.modalPresentationStyle = .fullScreen
                 navController.navigationItem.hidesBackButton = true
                 navController.setNavigationBarHidden(true, animated: true)
                 
                 // Present the navigation controller modally
         viewController?.present(navController, animated: true, completion: nil)
    }
}

