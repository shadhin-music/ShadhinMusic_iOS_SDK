//
//  VmaxMyProfileTVCell.swift
//  Shadhin_Gp
//
//  Created by Shadhin Music on 19/2/26.
//

import UIKit
import Vmax

class VmaxMyProfileTVCell: UITableViewCell {

    @IBOutlet private weak var overlayView: UIView!
    
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    var adSpace: VmaxAdSpace?
    var adContainer: UIStackView?
    var onAdFailed: (() -> Void)?
    var onHeightChanged: ((CGFloat) -> Void)?
    var HEIGHT_: CGFloat = 0.0
    
    override func prepareForReuse() {
        super.prepareForReuse()
        overlayView.subviews.forEach({$0.removeFromSuperview()})
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.commonInit()
    }

    func commonInit(){
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        overlayView.layer.cornerRadius = 12
        overlayView.layer.masksToBounds = true
    }

    func setupCell(tagId: String) {
        guard let result = VmaxAdSpaceManager.shared.getAdSpaceResult(for: tagId) else {
            return
        }
        adSpace = result.0
        adContainer = result.1
        addContainerToOverlayView(result.1)
        
        VmaxAdSpaceManager.shared.onAdError[tagId] = { [weak self] in
            self?.onAdFailed?()
        }
        
        VmaxAdSpaceManager.shared.onAdRender[tagId] = { [weak self] in
            self?.updateHeight()
        }
        
        VmaxAdSpaceManager.shared.onAdRefresh[tagId] = { [weak self] in
            self?.updateHeight()
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.layoutIfNeeded()
            self?.updateHeight()
        }
    }

    func addContainerToOverlayView(_ container: UIView?) {
        guard let container else { return }
        overlayView.addSubview(container)
        setAnchors(to: container, from: overlayView)
    }
    
    func setAnchors(to view: UIView, from container: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        view.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 1).isActive = true
        view.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1).isActive = true
    }
    
    func updateHeight() {
        guard let container = adContainer else { return }
        container.layoutIfNeeded()
        let targetSize = CGSize(width: container.bounds.width,
                                height: UIView.layoutFittingCompressedSize.height)
        let calculatedHeight = container.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        
        if calculatedHeight > 1.0 && calculatedHeight != HEIGHT_ {
            HEIGHT_ = calculatedHeight
            print("updateHeight() -> \(HEIGHT_)")
            onHeightChanged?(calculatedHeight)
        }
    }
}



