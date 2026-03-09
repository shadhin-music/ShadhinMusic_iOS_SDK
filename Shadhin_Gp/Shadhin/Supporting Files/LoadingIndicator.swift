//
//  LoadingIndicator.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 2/6/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class LoadingIndicator {
    
    static var loadingIndicator: VGPlayerLoadingIndicator? = nil{
        didSet{
            if oldValue != nil{
                oldValue?.removeFromSuperview()
            }
        }
    }
    
    static func initLoadingIndicator(view: UIView) {
        loadingIndicator = VGPlayerLoadingIndicator(frame: .init(x: view.bounds.midX - 20, y: view.bounds.midY - 20, width: 40, height: 40))
        loadingIndicator?.lineWidth = 4
        if #available(iOS 13.0, *) {
            loadingIndicator?.strokeColor = .tintColor
        }
        if let indicatior = loadingIndicator{
            view.addSubview(indicatior)
        }
    }
    
    static func startAnimation(_ reload : Bool = false) {
        if reload, let loadingIndicator = loadingIndicator, let parent = loadingIndicator.superview{
            loadingIndicator.removeFromSuperview()
            initLoadingIndicator(view: parent)
        }
        loadingIndicator?.isHidden = false
        loadingIndicator?.startAnimating()
    }
    
    static func stopAnimation() {
        loadingIndicator?.stopAnimating()
        loadingIndicator?.isHidden = true
    }
    
    static func isLoading() -> Bool{
        return !(loadingIndicator?.isHidden ?? false)
    }
}
