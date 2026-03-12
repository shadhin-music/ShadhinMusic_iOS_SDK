//
//  NoInternetPopUpVC.swift
//  Shadhin
//
//  Created by Joy on 17/7/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class NoInternetPopUpVC: UIViewController,NIBVCProtocol {

    static let HEIGHT : CGFloat = 450 //UIScreen.main.bounds.height * 0.5
    var showDownloadBtn = true
    
    @IBOutlet weak var noInternetView: NoInternetView!
    @IBOutlet weak var bottomContentView: UIView!
    
    var retry : ()-> Void = {}
    var gotoDownload : ()-> Void = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomContentView.layer.cornerRadius = 16
        bottomContentView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        if showDownloadBtn {
            bottomContentView.isHidden = false
        } else {
            bottomContentView.isHidden = true
        }
     
        noInternetView.retry = {[weak self] in
            guard let self = self else {return}
            self.retry()
        }
        
        noInternetView.gotoDownload = {[weak self] in
            guard let self = self else {return}
            self.gotoDownload()
        }
    }


}
