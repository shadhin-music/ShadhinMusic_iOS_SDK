//
//  SignalR.swift
//  Shadhin
//
//  Created by Rezwan on 21/9/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import Foundation

class SignalR {
    
    static var podcastCode = "BC"
    static let instance = SignalR()
    
    private var chatHubConnection: HubConnection?
    private var connected = false
    private var count = "0"
    
    private init(){
        
    }
    
    private func connect(){
        if connected{
            return
        }
        let serverUrl = "\(ShadhinApiURL.BASE_URL_SIGNALR)/podcastonline?contentType=\(SignalR.podcastCode.uppercased())"
        
        
        self.chatHubConnection = HubConnectionBuilder(url: URL(string: serverUrl)!)
            .withLogging(minLogLevel: .error)
            .withAutoReconnect()
            .withHubConnectionDelegate(delegate: self)
            .build()
        
        self.chatHubConnection!.on(method: "onlineuser") { response in
            guard let totalPeople = try? response.getArgument(type: String.self) else{return}
            self.count = totalPeople
            Log.info("SignalR Online count \(self.count)")
            self.delegate?(self.count)
        }
        self.chatHubConnection!.start()
    }
    
    
    
    public var delegate : ((String)->Void)? {
        didSet{
            if delegate != nil{
                self.connect()
                self.delegate?(count)
            }else{
                self.chatHubConnection?.stop()
                self.chatHubConnection = nil
                connected = false
            }
        }
    }
    
    
}

extension SignalR: HubConnectionDelegate {


    func connectionDidOpen(hubConnection: HubConnection) {
        connected = true
    }

    func connectionDidFailToOpen(error: Error) {
        connected = false
        Log.error("SignalR connectionDidFailToOpen \(error)")
    }

    func connectionDidClose(error: Error?) {
        connected = false
        Log.error("SignalR connectionDidClose \(String(describing: error))")
    }

    func connectionWillReconnect(error: Error) {
        connected = false
        Log.error("SignalR connectionWillReconnect \(error)")
    }

    func connectionDidReconnect() {
        connected = true
    }
}


protocol LiveCounter {
    func countUpdate(totalPeople : String) -> Void
}
