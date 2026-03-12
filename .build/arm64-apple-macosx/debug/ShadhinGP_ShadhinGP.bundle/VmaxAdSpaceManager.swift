//
//  VmaxAdSpaceManager.swift
//  Shadhin_GP
//
//  Created by MD Murad Hossain on 2/6/26.
//

import UIKit
import Vmax
import VmaxNativeHelper
import WebKit

typealias VmaxAdResult = (VmaxAdSpace?, UIStackView?)

final class VmaxAdSpaceManager {
    
    static let shared = VmaxAdSpaceManager()
    private init() {}
    private var adSpaceCacheForTag = [String: VmaxAdResult]()
    var onAdError: [String: (()->Void)?] = [:]
    var onAdRender: [String: (()->Void)?] = [:]
    var onAdRefresh: [String: (()->Void)?] = [:]
    
    func preLoadVmaxAd(with tagIds: [String]) {
        tagIds.forEach { tagId in
            guard adSpaceCacheForTag[tagId] == nil else {
                return
            }
        }
    }
    
    func getAdSpaceResult(for tagId: String) -> VmaxAdResult? {
        if tagId.isEmpty {
            print("Developer: Please pass valid tagId.")
            return nil
        }
        
        if let result = adSpaceCacheForTag[tagId] {
            return result
        }
        
        return createVmaxAdSpaceInternal(tagId: tagId)
    }
    
    func reset() {
        adSpaceCacheForTag.forEach { item in
            adSpaceCacheForTag[item.key]?.0?.close()
            adSpaceCacheForTag[item.key]?.0 = nil
            adSpaceCacheForTag[item.key]?.1 = nil
        }
        adSpaceCacheForTag.removeAll()
    }
}

//MARK: - PRIVATE METHODS
extension VmaxAdSpaceManager {
    
    private func getExperienceBasedLayout() -> VmaxAdLayout {
        let experienceBasedLayout = VmaxRegistry.shared.getVmaxAdLayout(
            adLayoutRegistrationType: .experienceBased
        )
        
        experienceBasedLayout.addAdLayout(
            experience: "iab.native",
            adLayout: BrandedActionCard()
        )
        
        experienceBasedLayout.addAdLayout(
            experience: "exp-783e727b0b6d4181",
            adLayout: CarouselDiscoveryCard()
        )
        
        experienceBasedLayout.addAdLayout(
            experience: "exp-a4fc951a3fa35657",
            adLayout: InfoRichPromoCard()
        )
        
        experienceBasedLayout.addAdLayout(
            experience: "exp-75f92cec1588a540",
            adLayout: HeadlineFirstCard()
        )
        
        experienceBasedLayout.addAdLayout(
            experience: "exp-c4c795ba2d3ed1f0",
            adLayout: MinimalVisualCard()
        )
        
        return experienceBasedLayout
    }
    
    private func getStackView() -> UIStackView {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .center
        return view
    }
    
    private func makeAdRequest(adSpace: VmaxAdSpace) {
        if adSpace.getState() == .initialized {
            adSpace.setVmaxAdLayout(vmaxAdLayout: getExperienceBasedLayout())
            
            let adRequest = VmaxManager.shared.createVmaxAdspotRequestBuilder()
                .addAdSpace(adSpace: adSpace)
                .build()
            VmaxManager.shared.process(vmaxRequest: adRequest)
            ShadhinGP.shared.trackEvent(name: "ad_request", params: ["ad_space_id": adSpace.getTagId()])
        }
    }
    
    @discardableResult
    private func createVmaxAdSpaceInternal(tagId: String) -> VmaxAdResult? {
        guard let vmaxAdSpace = VmaxManager.shared.createVmaxAdSpace(tagId: tagId) else {
            print("Developer: VmaxAdSpace is nil")
           if let callback = onAdError[tagId] {
                callback?()
              
            }
            return nil
        }
        vmaxAdSpace.setRefreshInterval(time: 30)
        vmaxAdSpace.addAdEventDelegate(adEventDelegate: self)
        
        let adContainer = getStackView()
        adSpaceCacheForTag[tagId] = (vmaxAdSpace, adContainer)
        makeAdRequest(adSpace: vmaxAdSpace)
        
        return (vmaxAdSpace, adContainer)
    }
    
    private func getAdContainer(adSpace: VmaxAdSpace) -> UIStackView? {
        if let result = adSpaceCacheForTag.values.first(where: { $0.0?.getId() == adSpace.getId() }) {
            return result.1
        }
        return nil
    }
    
    private func getAdTagId(adSpace: VmaxAdSpace) -> String? {
        adSpaceCacheForTag.first(where: { $0.value.0?.getId() == adSpace.getId() })?.key
    }
}

// MARK: - VmaxAdEventDelegate, VmaxMediaEvents
extension VmaxAdSpaceManager: VmaxAdEventDelegate, VmaxMediaEvents {
    
    func onAdReady2(vmaxAdSpace: Vmax.VmaxAdSpace) {
        if let view = getAdContainer(adSpace: vmaxAdSpace) {
            vmaxAdSpace.showAd(container: view)
          
        } else {
            print("Developer: Couldn't find the vmaxAdSpace id \(vmaxAdSpace.getId()) in adSpaceDictionary")
        }
        
        ShadhinGP.shared.trackEvent(name: "ad_delivered", params: ["VmaxAd_space_id": vmaxAdSpace.getTagId()])
    }
    
    func onAdReady(vmaxAdSpace: Vmax.VmaxAdSpace) {
        if let view = getAdContainer(adSpace: vmaxAdSpace) {
            vmaxAdSpace.showAd(container: view)
            if let tagId = getAdTagId(adSpace: vmaxAdSpace),
               let callback = onAdRender[tagId] {
                DispatchQueue.main.async {
                    callback?()
                }
            }
        }
        
        ShadhinGP.shared.trackEvent(name: "ad_delivered", params: ["VmaxAd_space_id": vmaxAdSpace.getTagId()])
    }

    
    func onAdError(vmaxAdSpace: Vmax.VmaxAdSpace, vmaxError: Vmax.VmaxError) {
        if let tagId = getAdTagId(adSpace: vmaxAdSpace), let callback = onAdError[tagId] {
            callback?()
          
        }
        
        ShadhinGP.shared.trackEvent(name: "ad_load_failed", params: ["VmaxAd_space_id": vmaxAdSpace.getTagId()])
    }
    
    func onAdRender(vmaxAdSpace: Vmax.VmaxAdSpace) {
        
        if let tagId = getAdTagId(adSpace: vmaxAdSpace), let callback = onAdRender[tagId] {
            callback?()
        }
        ShadhinGP.shared.trackEvent(name: "ad_load_time", params: ["VmaxAd_space_id": vmaxAdSpace.getTagId()])
    }
    
    func onAdRefresh(vmaxAdSpace: Vmax.VmaxAdSpace) {
        if let tagId = getAdTagId(adSpace: vmaxAdSpace), let callback = onAdRefresh[tagId] {
            callback?()
        }
    }
    
    func onAdClick(vmaxAdSpace: Vmax.VmaxAdSpace) {
        
        ShadhinGP.shared.trackEvent(name: "ad_clicks", params: ["VmaxAd_space_id": vmaxAdSpace.getTagId()])
    }
    
    func onAdClose(vmaxAdSpace: Vmax.VmaxAdSpace) {
        if let tagId = getAdTagId(adSpace: vmaxAdSpace) {
            adSpaceCacheForTag[tagId]?.0 = nil
            adSpaceCacheForTag[tagId]?.1 = nil
            adSpaceCacheForTag.removeValue(forKey: tagId)
        }
        
        ShadhinGP.shared.trackEvent(name: "onAdClose", params: ["VmaxAd_space_id": vmaxAdSpace.getTagId()])
    }
    
    func onAdImpression(vmaxAdSpace: VmaxAdSpace) {
        ShadhinGP.shared.trackEvent(name: "ad_impressions", params: ["VmaxAd_space_id": vmaxAdSpace.getTagId()])
    }
}

