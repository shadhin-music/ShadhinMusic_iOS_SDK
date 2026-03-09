//
//  ShadhinApi+NewSubscription.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 15/4/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi {
    func getNewUsersubscriptionPaymentProducts(
        _ completion : @escaping (_ responseModel: Result<NewSubscriptionResponseObj,AFError> )->()){
            print(NEWSUBSCRIPTION_GET_PRODUCTS(ShadhinCore.instance.defaults.userIdentity, ShadhinCore.instance.defaults.userCountryCode))
            AF.request(
                NEWSUBSCRIPTION_GET_PRODUCTS(ShadhinCore.instance.defaults.userIdentity, ShadhinCore.instance.defaults.userCountryCode),
                method: .get,
                parameters: nil,
                encoding: JSONEncoding.default,
                headers: API_HEADER
            ).responseDecodable(of: NewSubscriptionResponseObj.self) { response in
                completion(response.result)
            }
        }
    
    func getNewUsersubscriptionPaymentOptions(planName: String,
        _ completion : @escaping (_ responseModel: Result<PaymentMethodSuccessResponseObj,AFError> )->()){
        print(NEWSUBSCRIPTION_GET_PAYMENT_OPTIONS(planName, ShadhinCore.instance.defaults.userCountryCode))
            AF.request(
                NEWSUBSCRIPTION_GET_PAYMENT_OPTIONS(planName, ShadhinCore.instance.defaults.userCountryCode),
                method: .get,
                parameters: nil,
                encoding: JSONEncoding.default,
                headers: API_HEADER
            ).responseDecodable(of: PaymentMethodSuccessResponseObj.self) { response in
                completion(response.result)
            }
        }
    
    func getPlanDetails(planId: String,_ completion : @escaping (_ responseModel: Result<PlanDetailModel,AFError> )->()){
        AF.request(
            GET_PLAN_DETAILS(planId),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: PlanDetailModel.self) { response in
            completion(response.result)
        }
    }
    
    func getNewUserSubscriptionDetails(_ completion : @escaping (_ responseModel: Result<SubscriptionDetailsResponseOBj,AFError> )->()){
        AF.request(
            NEWSUBSCRIPTION_DETAILS,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: SubscriptionDetailsResponseOBj.self) { response in
            completion(response.result)
        }
    }
    
    func getWebViewUrl(body: [String: Any], url: String, _ completion: @escaping (_ responseModel: Result<PaymentResponseModel, AFError>) -> ()) {
        AF.request(
            url,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: API_HEADER)
        .validate(statusCode: 200..<300)  // ✅ Validate before decoding
        .responseDecodable(of: PaymentResponseModel.self) { response in

            switch response.result {
            case .success:
                completion(response.result)

            case .failure(let error):
                // ✅ Extract plain text error message from server
                if let data = response.data,
                   let serverMessage = String(data: data, encoding: .utf8) {
                    print("Server error: \(serverMessage)") // "Invalid user code or msisdn!"
                }
                completion(.failure(error))
            }
        }
    }

    func cancelSubscription(body: [String : Any], url: String, _ completion : @escaping (_ response: Result<CancelSubscriptionModel,AFError>)->()) {
        
        guard let jsonBodyData = try? JSONSerialization.data(withJSONObject: body, options: []),
              let jsonBodyString = String(data: jsonBodyData, encoding: .ascii),
              let encryptedJsonBodyString = CryptoCBC.shared.encryptMessage(message: "\(jsonBodyString)", encryptionKey: "secretKeyb1DEYmhXrTYiyU65EWI8U1h", iv: "ivSec1HJFhYrhcr5"),
              let data = "\"\(encryptedJsonBodyString)\"".data(using: .utf8)
        else { return }
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(ShadhinCore.instance.defaults.userSessionToken)", forHTTPHeaderField: "Authorization")
        request.setValue("Sv0390cf388d6bc429d9fd09741b0abf7c8T", forHTTPHeaderField: "x-api-key")
        request.httpBody = data
        
        AF.request(request).responseDecodable(of: CancelSubscriptionModel.self) { response in
            completion(response.result)
        }
    }
    
    func renewSubscription(body: [String : Any], url: String, _ completion : @escaping (_ response: Result<RenewSubscriptionModel,AFError>)->()) {
        AF.request(
            url,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: API_HEADER)
        .responseDecodable(of: RenewSubscriptionModel.self) { response in
            completion(response.result)
        }
    }
    
    func sendTransactionToken(
        receiptData     : String,
        serviceName     : String,
        completion: @escaping (Bool)-> Void
    )
    {
        guard receiptData != ShadhinCore.instance.defaults.receiptData, !receiptData.isEmpty else {return}
        
        let body = [
            "platform": "ios",
            "ServiceName": serviceName,
            "SubToken": receiptData

        ]
        AF.request(
            "https://connect.shadhinmusic.com/api/v1/payment/digital-subscription",
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseData { response in
            if response.response?.statusCode == 200{
                ShadhinCore.instance.defaults.receiptData = receiptData
                completion(true)
            } else {
                completion(false)
            }
        }
    }    
}
