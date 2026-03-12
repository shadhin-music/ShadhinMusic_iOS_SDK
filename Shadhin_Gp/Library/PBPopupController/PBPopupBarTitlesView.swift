//
//  PBPopupBarTitlesView.swift
//  PBPopupTest
//
//  Created by Joy on 21/11/22.
//

import UIKit

public class PBPopupBarTitlesView: UIStackView {
    
    @objc public var titleLabel : UILabel?{
        get{
            if let top = arrangedSubviews.first{
                return top as? UILabel
            }else {
                return nil
            }
        }
    }
    @objc public var subtitleLabel : UILabel?{
        get{
            if let last = arrangedSubviews.last{
                return last as? UILabel
            }
            return nil
        }
    }
    @objc public var popupContentView: PBPopupContentView? {
        return self.popupContentViewFor(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.axis = .vertical
        self.distribution = .fillEqually
    }
    
    required init(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        self.axis = .vertical
        self.distribution = .fillEqually
    }
    static func initial()-> PBPopupBarTitlesView{
        let ss = PBPopupBarTitlesView(frame: .zero)
        let titleLabel = UILabel()
        let subtitleLabel = UILabel()
        ss.addArrangedSubview(titleLabel)
        ss.addArrangedSubview(subtitleLabel)
        return ss
    }
}
