//
//  MobileOperatorVC.swift
//  Shadhin
//
//  Created by Maruf on 15/2/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class MobileOperatorVC: UIViewController {
    
    @IBOutlet weak var operatorNameLabel: UILabel!
    @IBOutlet weak var planImageView: UIImageView!
    @IBOutlet weak var durationlabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var planNameLabel: UILabel!
    @IBOutlet weak var phoneNumberTxtFeild: UITextField!
    @IBOutlet weak var mobileNumberCheckIcon: UIImageView!
    
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var countryPickerView: UIStackView!
    @IBOutlet weak var countryPhnCodeLbl: UILabel!
    @IBOutlet weak var countryImg: UIImageView!
    //private let phoneNumberKit = PhoneNumberKit()
    private var mobile = ""
    private var _phoneCode: String = ""
    private var phoneCode: String {
        set{
            _phoneCode = newValue
        }
        get{
            self._phoneCode.replacingOccurrences(of: "+", with: "")
        }
    }
    
    var selectedItem: Item!
    var originalPlan: Plan!
    var planDetails: PlanDetailResponseData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.phoneCode = ""
        phoneNumberTxtFeild.text = ShadhinCore.instance.defaults.userMsisdn
        phoneNumberTxtFeild.isEnabled = false
        isNumberValid(msisdn: ShadhinCore.instance.defaults.userMsisdn)
        phoneNumberTxtFeild.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        bindData(currencySymbol: originalPlan.currencySymbol)
        confirmBtn.setTitle("Verify OTP", for: .normal)
        confirmBtn.isEnabled = true
    }
    
    
    @IBAction func confirmBtnAction(_ sender: Any) {
        guard let mobile = phoneNumberTxtFeild.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {return}
        if self.phoneCode == "880", !ShadhinCore.instance.isValidBangladeshNumber("\(self.phoneCode)\(mobile)") {
            self.view.makeToast("Invalid Bangladeshi Number")
            return
        }
        self.mobile = mobile
        RobiAnalytics.signUP()
        let vc = OTPSentForRefferalVC()
        vc.otpRequestUrl = planDetails?.checkOutUrl
        vc.verifyOTPUrl = planDetails?.otpCheckUrl
        vc.serviceId = planDetails?.serviceId
        vc.otpLength = planDetails?.otpLength ?? 6
        vc.phoneNumber = ShadhinCore.instance.defaults.userMsisdn
        vc.isForNewSubscription = true
        self.navigationController?.pushViewController(vc, animated: true)
        //SubscriptionProcessVC.show()
        
    }
    
    @objc func editingChanged() {
        guard let mobile = phoneNumberTxtFeild.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !mobile.isEmpty
        else {
            confirmBtn.isEnabled = false
            return
        }
        isNumberValid(msisdn: "\(phoneCode)\(mobile)")
        confirmBtn.setTitle("Verify OTP", for: .normal)
        confirmBtn.isEnabled = true
    }
    
    func isNumberValid(msisdn: String){
        do {
          //  let _ = try phoneNumberKit.parse(msisdn)
            self.mobileNumberCheckIcon.isHidden = false
        }catch{
            self.mobileNumberCheckIcon.isHidden = true
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func bindData(currencySymbol: String){
        operatorNameLabel.text = selectedItem.operatorName
        planImageView.kf.setImage(with: URL(string: selectedItem.icon ?? ""))
        amountLabel.text = currencySymbol + selectedItem.planPrice.getPriceDecidingDecimalPart
        durationlabel.text = "/\(originalPlan.durationInDays) \(originalPlan.durationInDays > 1 ? "days" : "day")"
        planNameLabel.text = originalPlan.planName
    }
    
}

//
//extension MobileOperatorVC: CountryPickerViewDelegate, CountryPickerViewDataSource {
//    
//    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
//        if !country.code.isEmpty && !country.name.isEmpty && !country.phoneCode.isEmpty {
//            self.phoneCode   = country.phoneCode
//            self.countryImg.image = country.flag
//            self.countryPhnCodeLbl.text = country.phoneCode
//            
//        }
//    }
//}
