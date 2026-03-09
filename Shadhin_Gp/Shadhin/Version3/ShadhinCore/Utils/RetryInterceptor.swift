//
//  RetryInteraction.swift
//  Shadhin
//
//  Created by Joy on 16/7/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import Foundation


///this protocol used for user API response error message and internet status
protocol NetworkErrorProtocol{
    ///error message show from API response
    func onNetworkErrorMessage(message : String,errorCode : Int)
    ///internet  connect disconnect message show
    func internetConnectionError(isConnected : Bool)
}


class RetryInterceptor : RequestInterceptor{
    ///Retry Limit. How much time you want to retry
    private let retryLimit = 3
    ///Retry Delay time
    private let retryDelay: TimeInterval = 2
    /// retry enable or not
    private var isRetry : Bool
    ///send error message to view
    private var networkErrorProtocol : NetworkErrorProtocol? 
    
    init(isRetry: Bool = false, networkErrorProtocol: NetworkErrorProtocol?) {
        self.isRetry = isRetry
        self.networkErrorProtocol = networkErrorProtocol
    }
    
    //if we want to add additional header to the request we can add here
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        if let data = (request as? DataRequest)?.data{
            if determineErrorAndWillRetry(
                requestCurl: request.cURLDescription(),
                response: String.init(data: data , encoding: .utf8) ,
                error: error){
                return completion(.retryWithDelay(retryDelay))
            }
        }
        
        completion(.doNotRetry)
    }
    
    func determineErrorAndWillRetry(requestCurl: String, response: String?, error: Error) -> Bool{
        Log.error("Error -> request -> \(requestCurl.replacingOccurrences(of: "\n", with: " "))")
        Log.error("Error -> response -> \(response)")
        return false
    }
//    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
//        Log.info("RetryInterceptor")
//        guard let response = request.task?.response as? HTTPURLResponse else {
//            return completion(.doNotRetry)
//        }
//        let statusCode = response.statusCode
//
//        if statusCode != 200{
//            //sendLogToServer(response: response)
//        }
//        sendLogToServer(response: response)
//        if isRetry{
//            if statusCode != 200,request.retryCount < retryLimit {
//                completion(.retryWithDelay(retryDelay))
//            } else {
//              return completion(.doNotRetry)
//            }
//        }else{
//            return completion(.doNotRetry)
//        }
//
//    }
//
    private func sendLogToServer(response : HTTPURLResponse){
        let statusCode = response.statusCode
        //internet off : You are now offline. But you can still enjoy offline downloads without the internet.
        //data not found : The link you were looking for is missing. Please try again sometime later.
        //API issue : We are experiencing technical problems which will be fixed soon. Thanks for your patience.
        
        networkErrorProtocol?.onNetworkErrorMessage(message: "Test message ", errorCode: statusCode)
    }
    
    func showErrorUI(){
        
    }
}
