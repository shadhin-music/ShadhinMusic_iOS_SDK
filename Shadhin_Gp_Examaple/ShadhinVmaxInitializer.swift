//
//  ShadhinVmaxInitializer.swift
//  Shadhin_GP_Example
//
//  Created by MD Murad Hossain on 29/12/25.
//

import Vmax
import VmaxNativeHelper
import VmaxDisplayHelper
import VmaxOM

public final class ShadhinVmaxInitializer: NSObject {
    
    public static let shared = ShadhinVmaxInitializer()
    private var initialized = false
    private override init() {}
    
    public func initialize(
        vmaxAccountKey: String,
        vmaxAppId: String,
        vmaxPrivateKey: String,
        vmaxKeyId: String,
        delegate: InitializationStatusDelegate
    ) {
        
        guard !initialized else { return }
        initialized = true
        VmaxRegistry.shared.addVmaxAds(vmaxAds: [
            VmaxAdDisplay.self,
            VmaxAdNative.self
        ])
        
        VmaxRegistry.shared.registerViewability(viewability: VmaxOMViewability.self)
        VmaxRegistry.shared.addCustomSignatureForVmaxAd(signature: "exp-2460f4471b7122fe", vmaxAd: VmaxAdDisplay.self)
        VmaxRegistry.shared.addCustomSignatureForVmaxAd(signature: "exp-509fe6b43e6ba226", vmaxAd: VmaxAdDisplay.self)
        VmaxRegistry.shared.addCustomSignatureForVmaxAd(signature: "exp-94adad43ecaf4caf", vmaxAd: VmaxAdDisplay.self)
        VmaxRegistry.shared.addCustomSignatureForVmaxAd(signature: "exp-783e727b0b6d4181", vmaxAd: VmaxAdNative.self)
        VmaxRegistry.shared.addCustomSignatureForVmaxAd(signature: "exp-a4fc951a3fa35657", vmaxAd: VmaxAdNative.self)
        VmaxRegistry.shared.addCustomSignatureForVmaxAd(signature: "exp-75f92cec1588a540", vmaxAd: VmaxAdNative.self)
        VmaxRegistry.shared.addCustomSignatureForVmaxAd(signature: "exp-c4c795ba2d3ed1f0", vmaxAd: VmaxAdNative.self)
        
        VmaxManager.shared.initialize(
            accountKey: vmaxAccountKey,
            appId: vmaxAppId,
            privateKey: vmaxPrivateKey,
            keyId: vmaxKeyId,
            delegate: delegate
        )
    }
}
