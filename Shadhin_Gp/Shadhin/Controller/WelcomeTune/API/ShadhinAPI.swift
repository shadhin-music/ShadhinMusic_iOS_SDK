//
//  ShadhinAPI.swift
//  Shadhin_Gp
//
//  Created by Maruf on 2/2/26.
//

import Foundation

extension ShadhinApi {
    // Modern async/await version (if using iOS 13+)
    @available(iOS 13.0.0, *)
    func getRBTProducts(operatorName: String) async throws -> RBTSubscriptionResponse {
        try await AF.request(
            GET_RBT_PRODUCTS_GP_SDK(operatorName),
            method: .get,
            encoding: URLEncoding.default,
            headers: API_HEADER
        )
        .serializingDecodable(RBTSubscriptionResponse.self)
        .value
    }
    
    // MARK: - Purchase RBT Combo
    @available(iOS 13.0.0, *)
    func purchaseRBTCombo(
        msisdn: String,
        contentId: String,
        productId: String,
        operatorName: String,
        purchaseMode: String
    ) async throws -> WelcomeTuneResponse {
        // Create request body
        let parameters: [String: Any] = [
            "msisdn": msisdn,
            "contentId": contentId,
            "productId": productId,
            "operator": operatorName,
            "purchaseMode":purchaseMode
        ]
        return try await AF.request(
            PURCHASE_RBT_COMBO,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,  // ✅ Use JSONEncoding for Dictionary
            headers: API_HEADER
        )
//        .validate()
        .serializingDecodable(WelcomeTuneResponse.self)
        .value
    }
}

