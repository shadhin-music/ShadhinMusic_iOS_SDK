//
//  NoInternetView.swift
//  Shadhin
//
//  Created by Joy on 17/7/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class NoInternetView: UIView {
    //MARK: create nib for access this cell
    private static var identifier : String {
        let id = String(describing:  self)
        return id //"NoInternetView"
    }
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var gotoDownloadButton: UIButton!
    @IBOutlet weak var retryButton: UIButton!
    
    var retry : ()-> Void = {}
    var gotoDownload : ()-> Void = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func commonInit(){
        Bundle.ShadhinMusicSdk.loadNibNamed(NoInternetView.identifier, owner: self,options: [:])
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        self.addSubview(contentView)
    }
    
    @IBAction func onDownloadPressed(_ sender: Any) {
        gotoDownload()
    }
    @IBAction func onRetryPressed(_ sender: Any) {
        if ConnectionManager.shared.isNetworkAvailable{
            retry()
        }else{
            if let vc = self.parentViewController{
                vc.view.makeToast("Please check your Internet connection!", position: .bottom)
            }
        }
        
    }
    
}
