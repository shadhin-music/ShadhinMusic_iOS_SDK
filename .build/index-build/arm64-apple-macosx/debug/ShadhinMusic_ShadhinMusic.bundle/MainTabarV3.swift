//
//  MainTabarV3.swift
//  Shadhin_Gp
//
//  Created by Maruf on 4/6/24.
//
import UIKit

class TabBarMainVCv3: UITabBarController,NIBVCProtocol {

    weak var coordinate : MainCoordinator?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let homeItem = UITabBarItem(title: "Home", image: UIImage(named: "ic_home_2",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), tag: 0)
        let home = HomeVCv3.instantiateNib()
        home.tabBarItem = homeItem
       // home.coordinate = self.coordinate
        viewControllers = [home]
    }
    

}
