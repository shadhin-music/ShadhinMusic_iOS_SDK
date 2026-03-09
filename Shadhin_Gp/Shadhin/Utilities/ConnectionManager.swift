//
//  ConnectionManager.swift
//  Shadhin_Gp
//
//  Created by Maruf on 3/6/24.
//

import UIKit

class ConnectionManager {

    static let shared = ConnectionManager()
    let reachability = try? Reachability()

    func observeReachability(){
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability?.startNotifier()
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    func stopObserveReachability() {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
    var isNetworkAvailable: Bool {
        return self.reachability?.connection != .unavailable
    }

    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        if reachability.connection == .unavailable {
            print("Network lost")
        } else {
            print("Network available")
        }
    }
    
    func networkErrorHandle(err: Error?,view: UIView) {
        guard let error = err as? URLError else {return}
        var style = ToastManager.shared.style
        style.messageFont = UIFont.systemFont(ofSize: 14)
        style.messageAlignment = .center
        if error.code == .notConnectedToInternet || error.code == .networkConnectionLost {
            view.makeToast("No network available.please check your WiFi or Data connection!" ,style: style)
        }else {
            view.makeToast("Something went wrong please try again!" ,style: style)
        }
    }

}
