//
//  AudioBookVM.swift
//  Shadhin
//
//  Created by Maruf on 2/10/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

protocol AudioBookHomeVMProtocol : NSObjectProtocol {
    func handle(patches: [AudioPatchHome])
  //  func loading(isLoading: Bool)
    func refreshHome()
    func resetHome()
}
class AudioBookHomeVM:NSObject {
    weak var vc:AudioBookHomeVC!
    private weak var presenter : AudioBookHomeVMProtocol?
    private var isLoading = false
    init(presenter: AudioBookHomeVMProtocol? = nil) {
        self.presenter = presenter
        super.init()
        
    }
}
extension AudioBookHomeVM {
    func loadHomeContent(){
      //  guard !isLoading else {return}
        fetchAudioBookHomeContent()
    }
    private func fetchAudioBookHomeContent() {
        // First check if the app is offline
        if !ConnectionManager.shared.isNetworkAvailable {
            // Try to load the cached data if offline
            if let cachedData = loadAudioBookHomeData() {
                // If data exists in the cache, use it
                self.presenter?.handle(patches: cachedData)
            }
            return // Exit function to prevent further execution
        }
        // If the app is online, proceed to fetch data from the API
        LoadingIndicator.initLoadingIndicator(view: vc.view)
        LoadingIndicator.startAnimation()
        
        ShadhinCore.instance.api.getAudioPatchDetails { [weak self] data, error in
            guard let self = self else { return }
            // Stop the loading indicator regardless of success or failure
            defer { LoadingIndicator.stopAnimation() }
            
            // Handle errors first
            if let error = error {
                print("Error fetching audiobook patch details: \(error)")
                self.vc.view.makeToast("We are experiencing technical problems which will be fixed soon. Thanks for your patience.")
                return
            }
             
            // Safely unwrap data
            guard let patches = data?.data else {
                self.vc.view.makeToast("We are experiencing technical problems which will be fixed soon. Thanks for your patience.")
                return
            }
            // Save the fetched data to local storage for offline use
            self.saveAudioBookHomeData(patches)
            // Pass data to the presenter
            self.presenter?.handle(patches: patches)
            print("Successfully received audiobook patch details: \(patches)")
        }
    }
    
    // MARK: - Local Storage Methods
    
    private func saveAudioBookHomeData(_ data: [AudioPatchHome]) {
        // Convert the data to JSON
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(data)
            UserDefaults.standard.set(jsonData, forKey: "cachedAudioBookHomeData")
        } catch {
            print("Failed to save data to UserDefaults: \(error)")
        }
    }
    
    private func loadAudioBookHomeData() -> [AudioPatchHome]? {
        // Load the data from UserDefaults
        guard let jsonData = UserDefaults.standard.data(forKey: "cachedAudioBookHomeData") else {
            return nil
        }
        
        // Decode the data from JSON
        let decoder = JSONDecoder()
        do {
            let patches = try decoder.decode([AudioPatchHome].self, from: jsonData)
            return patches
        } catch {
            print("Failed to decode cached data: \(error)")
            return nil
        }
    }
}
