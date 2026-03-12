//
//  MainCoordinator.swift
//  Shadhin-BL
//
//  Created by Joy on 22/8/22.
//https://www.hackingwithswift.com/articles/71/how-to-use-the-coordinator-pattern-in-ios-apps

import Foundation
import UIKit

class MainCoordinator : NSObject,Coordinator {
    
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        //self.navigationController.isNavigationBarHidden = true
    }
    
    func start(){
        let main  = TabBarMainVCv3.instantiateNib()
        main.coordinate = self
        self.navigationController.viewControllers = [main]
    }
    
}
//MARK: HOME NAVIGATION
extension MainCoordinator{
    func gotoProfile(){
        
    }
    func gotoSearch(){
        
    }
    func gotoLeaderBoard(){
        
    }
}
//MARK: for open methods
extension MainCoordinator{
    func fromMain(contentType type : String){
        
    }
    func pop(isAnimation : Bool = true){
        self.navigationController.popViewController(animated: isAnimation)
    }
    func popMusic(){
        navigationController.closePopup(animated: true)
    }
}
