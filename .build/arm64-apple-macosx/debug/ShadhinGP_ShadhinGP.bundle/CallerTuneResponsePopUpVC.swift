//
//  CallerTuneResponsePopUpVC.swift
//  Shadhin
//
//  Created by Gakk Alpha on 12/8/21.
//  Copyright © 2021 Cloud 7 Limited. All rights reserved.
//

import UIKit

class CallerTuneResponsePopUpVC: UIViewController {
    
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    
    var action: (()->Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeBtn.setClickListener {
            self.action?()
        }
    }

}
