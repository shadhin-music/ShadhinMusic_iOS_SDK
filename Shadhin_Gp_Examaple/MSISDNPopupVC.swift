//
//  MSISDNPopupVC.swift
//  Shadhin_Gp_Examaple
//
//  Created by Maruf on 3/9/24.
//

import UIKit

class MSISDNPopupVC: UIViewController {

    @IBOutlet weak var userTxtField: UITextField!
    
    var setMsisdn: (String)->Void = {_ in}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTxtField.text = "8801711090920"
    }
    
    @IBAction func msisdnSubmit(_ sender: Any) {
        if let msisdn = userTxtField.text {
            setMsisdn(msisdn)
            self.dismiss(animated: true)
        }
    }
}
