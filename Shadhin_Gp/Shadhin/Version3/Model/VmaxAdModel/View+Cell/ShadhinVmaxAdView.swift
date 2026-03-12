//
//  ShadhinVmaxAdView.swift
//  Shadhin_Gp
//
//  Created by Shadhin Music on 15/2/26.
//

import UIKit
import Vmax

class ShadhinVmaxAdView: UIView {

    // MARK: - Outlets
    @IBOutlet var contentView: UIView!

    // MARK: - Properties
    private var adSpace: VmaxAdSpace?
    var adContainer: UIView?
    var onAdFailed: (() -> Void)?
    var onHeightUpdate: ((CGFloat) -> Void)?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

// MARK: -- Private Methods --
extension ShadhinVmaxAdView {
    private func commonInit() {
        Bundle.ShadhinMusicSdk.loadNibNamed("ShadhinVmaxAdView", owner: self, options: [:])
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
        layer.cornerRadius = 12
        clipsToBounds = true
    }
    
    func setSpotAd(spotID: String) {
        guard let result = VmaxAdSpaceManager.shared.getAdSpaceResult(for: spotID) else {
            return
        }
        
        self.adSpace = result.0
        self.setAdStackView(to: result.1)
        VmaxAdSpaceManager.shared.onAdError[spotID] = { [weak self] in
            self?.onAdFailed?()
        }
        
//        addContainerToOverlayView(result.1)
//        adSpace = result.0
//        adContainer = result.1
//        VmaxAdSpaceManager.shared.onAdError[spotID] = { [weak self] in
//            self?.onAdFailed?()
//        }
    }
    
    func setAdStackView(to container: UIStackView?) {
        guard let container else { return }
        contentView.addSubview(container)
        adContainer?.backgroundColor = .red
        container.translatesAutoresizingMaskIntoConstraints = false
        container.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    func addContainerToOverlayView(_ container: UIView?) {
        guard let container else { return }
        contentView.addSubview(container)
        adContainer?.backgroundColor = .red
        setAnchors(to: container, from: self.contentView)
    }
    
    func setAnchors(to view: UIView, from container: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        view.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 1).isActive = true
        view.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1).isActive = true
    }
}
