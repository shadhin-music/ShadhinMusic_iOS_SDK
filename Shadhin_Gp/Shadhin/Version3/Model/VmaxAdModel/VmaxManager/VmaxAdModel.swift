//
//  VmaxAdModel.swift
//  Shadhin_Gp
//
//  Created by MD Murad Hossain on 16/2/26.
//

import Foundation

var VMAX_AD_ITEM_DATA = [VmaxAdItem]()
let PATCHCODE_TO_ADCODE_MAPPING: [String: String] = [
//    "PTH0007": "4928e4d0",
//    "PTH0011": "1dd32241",
//    "PTH0026": "f214e121",
//    "PTH0032": "ad063de8",
//    "PTH0029": "3fff9713",
//    "PTH0042": "8949b8f1"
    
    "PTH0007": "4928e4d0",
    "PTH0011": "d55d58a0",
    "PTH0026": "4389c11a",
    "PTH0032": "76401d96",
    "PTH0029": "3fff9713",
    "PTH0042": "8949b8f1"
]

struct VmaxAdResponse: Codable {
    let data: [VmaxAdItem]?
    let message: String?
    let success: Bool?
    let responseCode: Int?
    let title: String?
    let error: String?
}

struct VmaxAdItem: Codable {
    let adId: String?
    let isAdEnabled: Bool?
    let adSize: String?
}

extension ShadhinApi {
    
    static func getVmaxAdResponseData(completion: @escaping (VmaxAdResponse?, Error?) -> Void) {
        
        AF.request(
            "https://connect.shadhinmusic.com/api/v1/ads",
            method: .get,
            headers: ShadhinApiContants().API_HEADER
        )
        .validate()
        .responseDecodable(of: VmaxAdResponse.self) { response in
            
            switch response.result {
            case .success(let data):
                completion(data, nil)
                
            case .failure(let err):
                let error = NSError(
                    domain: "",
                    code: 400,
                    userInfo: [NSLocalizedDescriptionKey:
                        "Experiencing technical problems now. It will be fixed soon. Thanks for your patience."
                    ]
                )
                completion(nil, error)
                Log.error(err.localizedDescription)
            }
        }
        .responseString { response in
            if let str = response.value {
                Log.info(str)
            }
        }
    }
    
    static func getVmaxAdData() {
        getVmaxAdResponseData { adData, error in
            if let ads = adData?.data  {
                let enabledAds = ads.filter { $0.isAdEnabled == true }
                let adSpotIDs = enabledAds.filter { $0.adId != nil }.map(\.adId!)
                VmaxAdSpaceManager.shared.preLoadVmaxAd(with: adSpotIDs)
                VMAX_AD_ITEM_DATA = enabledAds
            }
        }
    }
}

// MARK: -- Track Event --
public protocol ShadhinGPEventDelegate: AnyObject {
    func shadhinGP(didTriggerEvent payload: [String: Any])
}

extension ShadhinGP {
    
    func trackEvent(name: String, params: [String: Any]?) {
        let payload: [String: Any] = [
            "shadhin_gp_event_name": name,
            "shadhin_gp_parameters": params ?? [:],
            "shadhin_gp_timestamp": Date().timeIntervalSince1970
        ]
        print("📡 SDK Event: \(payload)")
        eventDelegate?.shadhinGP(didTriggerEvent: payload)
    }
}
