//
//  TechnicalErrorPopupVC.swift
//  Shadhin
//
//  Created by Maruf on 24/11/25.
//  Copyright © 2025 Cloud 7 Limited. All rights reserved.
//

import UIKit

class TechnicalErrorPopupVC: UIViewController, NIBVCProtocol {

    @IBOutlet weak var mainbgView: UIView!
    @IBOutlet weak var artistImgView: UIImageView!
    @IBOutlet weak var musicNameLbl: UILabel!
    @IBOutlet weak var songLbl: UILabel!
    @IBOutlet weak var tecnicalErrorLbl: UILabel!
    @IBOutlet weak var technicalErrorSubtitle: UILabel!
    @IBOutlet weak var okButton: UIButton!
    
    var errorDetails = ""
    var image: UIImage?
    var musicName = ""
    var artsitName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {
        self.technicalErrorSubtitle.text = errorDetails
        self.artistImgView.image = self.image
        self.musicNameLbl.text = self.musicName
        self.songLbl.text = self.artsitName
    }

    @IBAction func confirm(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
}
