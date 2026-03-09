//
//  TestVc.swift
//  Shadhin_Gp_Examaple
//
//  Created by MD Murad Hossain on 1/8/24.
//

import UIKit
import Shadhin_Gp
import Vmax

class TestVc: UIViewController, ShadhinMusicViewDelegate {
    
    @IBOutlet weak var gpMusicView: ShadhinMusicView!
    
    var msisdn: String?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        gpMusicView.gpDeletegate = self
        ShadhinGP.shared.eventDelegate = self
        gpMusicView.exPlore = {
            self.showMsisdnPopup()
        }
    }
    
    func showMsisdnPopup() {
        let vc = MSISDNPopupVC()
        vc.setMsisdn = setMsisdn
        self.present(vc, animated: true)
    }
    
    func setMsisdn(msisdn: String) {
        self.msisdn = msisdn
        self.gpMusicView.gotoShadhinSDK()
    }
    
    func gotoShadhinSDK(completionHandler: @escaping (UIViewController, String) -> Void) {
        guard let msisdn = self.msisdn else {
            self.view.makeToast("Please provide msisdn")
            return
        }
        
        loginUser(msisdn: msisdn) { [weak self] token in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                ShadhinVmaxInitializer.shared.initialize(
                    vmaxAccountKey: "grameenphone",
                    vmaxAppId: "4408938",
                    vmaxPrivateKey: "CWbEvz3OiwCEk7MmIwwmhaeMVvEhvIpnkdlX62ZAduo=",
                    vmaxKeyId: "409f39f7c15332caa93bd1d87e14f296f2fe3890364336a8b675015e05ab6d39",
                    delegate: self
                )
                completionHandler(self, token)
            }
        }
    }
    
    
    func loginUser(msisdn: String, completion: @escaping (String)->Void) {
        let url = URL(string: "https://connect.shadhinmusic.com/api/v1/user/gp-login")!
        
        let json: [String: Any] = [
            "MSISDN": msisdn,
            "vendorId": "vendorId-\(msisdn)",
            "deviceId": "deviceId-\(msisdn)",
            "deviceName": "testDevice-\(msisdn)"
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("c723f1cc52054ce0be96ebc5487c55", forHTTPHeaderField: "x-api-key")
        request.setValue("b1446eb392414d74901aeabd0e6ff2388b78b816", forHTTPHeaderField: "client-secret")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data")
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let data = jsonResponse["data"] as? [String: Any],
                   let accessToken = data["accessToken"] as? String {
                    print("Access Token: \(accessToken)")
                    completion(accessToken)
                } else {
                    print("Could not find access token in the response")
                }
            } catch {
                print("JSON parsing error: \(error)")
            }
        }
        
        task.resume()
    }
}


extension TestVc : InitializationStatusDelegate {
    func onSuccess() {
        ShadhinGP.shared.isVmaxInitialized = true
        print("✅ Vmax Initialized Successfully")
    }
    
    func onFailure(error: Vmax.VmaxError) {
        ShadhinGP.shared.isVmaxInitialized = false
        print("❌ Vmax Initialization Failed: \(error.localizedDescription)")
    }
}

extension TestVc : ShadhinGPEventDelegate {
    func shadhinGP(didTriggerEvent payload: [String : Any]) {
        print(payload)
    }
}
