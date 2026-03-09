//
//  CallerTunePaymentOptionsVC.swift
//  Shadhin
//
//  Created by Gakk Alpha on 12/8/21.
//  Copyright © 2021 Cloud 7 Limited. All rights reserved.
//

import UIKit


class CallerTunePaymentOptionsVC: UIViewController {
    
    static func setRbtOnContent(_ parent : UIViewController, _ song : CommonContentProtocol){
        let storyBoard = UIStoryboard(name: "CallerTune", bundle:Bundle.ShadhinMusicSdk)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CallerTunePaymentOptionsVC") as! CallerTunePaymentOptionsVC
        vc.song = song
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        parent.present(navVC, animated: true, completion: nil)
    }
    
    var availableServices : [CallerTuneObj] = []
    var selectedService : CallerTuneObj?
    var isAutoRenewal : RBTSubType = .OneTime
    var telcoBrand : Telco = .Unknown
    @IBOutlet weak var optionsStackView: UIStackView!
    @IBOutlet weak var setBtn: UIButton!
    @IBOutlet weak var titleStr: UILabel!
    @IBOutlet weak var disclaimer: UILabel!
    
    var song : CommonContentProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard (ShadhinCore.instance.isGP() || ShadhinCore.instance.isBanglalink()) else{
            setBtn.backgroundColor = .gray
            setBtn.isEnabled = false
            return
        }
        disclaimer.isHidden = true
        availableServices = ShadhinApiContants.getCallerTuneServices()
        if !availableServices.isEmpty{
            selectedService = availableServices[0]
        }
        telcoBrand = ShadhinCore.instance.getUserTelcoBrand()
        for (index, item) in optionsStackView.subviews.enumerated(){
            if index < availableServices.count{
                (item.viewWithTag(2) as? UILabel)?.text = availableServices[index].amount
                (item.viewWithTag(3) as? UILabel)?.text = availableServices[index].duration
                item.setClickListener {
                    self.onOptionsSelected(index: index)
                }
            }else{
                item.isHidden = true
            }
        }
        if ShadhinCore.instance.isBanglalink(){
            titleStr.text = "Set Amar Tune"
        }
        
//        optionsStackView.subviews[0].setClickListener {
//            self.onOptionsSelected(index: 0)
//        }
//        optionsStackView.subviews[1].setClickListener {
//            self.onOptionsSelected(index: 1)
//        }
//        optionsStackView.subviews[2].setClickListener {
//            self.onOptionsSelected(index: 2)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true)
    }
    
    @IBAction func autoRenewal(_ sender: UIButton) {
        if isAutoRenewal == .AutoRenewal{
            isAutoRenewal = .OneTime
            sender.setImage(#imageLiteral(resourceName: "rbt_checkbox_unchecked.pdf"), for: .normal)
        }else{
            isAutoRenewal = .AutoRenewal
            sender.setImage(#imageLiteral(resourceName: "rbt_checkbox_checked.pdf"), for: .normal)
        }
        
    }
    
    private func onOptionsSelected(index : Int){
        selectedService = availableServices[index]
        for view in optionsStackView.subviews{
            let img = view.viewWithTag(99) as! UIImageView
            if index == view.tag{
                img.image = #imageLiteral(resourceName: "rbt_radio_check")
                view.borderColor = UIColor.init(rgb: 0x00B0FF)
            }else{
                img.image = #imageLiteral(resourceName: "rbt_radio_unchecked")
                view.borderColor = .secondaryLabelColor()
            }
        }
    }
    
    @IBAction func didTapSetBtn(_ sender: Any) {
        
        guard let contentId = song.contentID,
              let artistId = song.artistId,
              let selectedService = selectedService else {return self.view.makeToast("Some required parameters missing")}
        
        if ShadhinCore.instance.defaults.userMsisdn.isEmpty{
          //  LinkMsisdnVC.show("Phone number is required to proceed with Caller Tunes...")
            return
        }
        
        if !ShadhinCore.instance.isValidBangladeshNumber() {
            self.view.makeToast("Caller tune is only available for bangladeshi number")
            return
        }
        
        self.view.lock()
        ShadhinCore.instance.api.setRBT(
            contentId: contentId,
            artistId: artistId,
            callerTune: selectedService,
            subType: self.isAutoRenewal) {
                succcess, msg, subType in
            
            self.view.unlock()
            
            if succcess, subType == .AutoRenewal, self.telcoBrand == .GrameenPhone{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CallerTuneResponsePopUpVC") as! CallerTuneResponsePopUpVC
                
                vc.action = {
                    SwiftEntryKit.dismiss()
                    self.navigationController?.dismiss(animated: true)
                }
                let height: CGFloat = 354
                
                var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 8)
                attribute.entryBackground = .color(color: .clear)
                attribute.border = .none
                SwiftEntryKit.display(entry: vc, using: attribute)
            }else{
                self.navigationController?.presentingViewController?.view.makeToast(msg)
                self.navigationController?.dismiss(animated: true)
            }
        }
        
        
//        let vc = storyboard?.instantiateViewController(withIdentifier: "CallerTuneResponsePopUpVC") as! CallerTuneResponsePopUpVC
//        let height: CGFloat = 354
//
//        var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 8)
//        attribute.entryBackground = .color(color: .clear)
//        attribute.border = .none
//        SwiftEntryKit.display(entry: vc, using: attribute)
    }
    
}
