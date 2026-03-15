//
//  AlreadyWelcomeTuneSetPopupVC.swift
//  Shadhin
//
//  Created by Maruf on 24/11/25.
//  Copyright © 2025 Cloud 7 Limited. All rights reserved.
//

import UIKit

class AlreadyWelcomeTuneSetPopupVC: UIViewController, NIBVCProtocol {
    
    @IBOutlet weak var imageName: UIImageView!
    @IBOutlet weak var musicNameLbl: UILabel!
    @IBOutlet weak var mainbgView: UIView!
    @IBOutlet weak var artistNameLbl: UILabel!
    @IBOutlet weak var OkButton: UIButton!
    
    var image: UIImage?
    var musicName = ""
    var artsitName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {
        self.imageName.image = self.image
        self.musicNameLbl.text = self.musicName
        self.artistNameLbl.text = self.artsitName
    }

    @IBAction func obButtonAction(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
}
