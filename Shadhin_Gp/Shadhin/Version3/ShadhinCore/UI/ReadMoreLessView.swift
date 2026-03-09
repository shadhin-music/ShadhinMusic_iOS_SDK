//
//  ReadMoreLessView.swift
//  Shadhin
//
//  Created by Gakk Alpha on 9/22/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation
import UIKit

protocol ReadMoreLessViewDelegate: AnyObject{
    func didChangeState(_ readMoreLessView: ReadMoreLessView)
    func didClickButton(_ readMoreLessView: ReadMoreLessView)
}

@IBDesignable class ReadMoreLessView : UIView {
    
    @IBInspectable var maxNumberOfLinesCollapsed: Int = 3{
        didSet{
            if state == .collapsed{
                textLabel.numberOfLines = maxNumberOfLinesCollapsed
            }
        }
    }
    fileprivate var kvoContext = 0
    
    @IBInspectable var textColor: UIColor = .darkGray {
        didSet{
            textLabel.textColor = textColor
        }
    }
    
    @IBInspectable var buttonColor: UIColor = .orange {
        didSet{
            moreLessButton.setTitleColor(buttonColor, for: UIControl.State())
        }
    }
    
    @IBInspectable var textLabelFont: UIFont = .systemFont(ofSize: 14) {
        didSet{
            textLabel.font = textLabelFont
        }
    }
    
    @IBInspectable var moreLessButtonFont: UIFont = .systemFont(ofSize: 12) {
        didSet{
            moreLessButton.titleLabel!.font = moreLessButtonFont as UIFont
        }
    }
    
    @IBInspectable var text: String = "" {
        didSet{
            if !text.isEmpty{
                setText(text: text)
            }
        }
    }
    
    var autoExpandCollapse = false
    
    var moreText = "Read More"
    var lessText = "Read Less"
 
    enum ReadMoreLessViewState {
        case collapsed
        case expanded
        
        mutating func toggle() {
            switch self {
            case .collapsed:
                self = .expanded
            case .expanded:
                self = .collapsed
            }
        }
    }
    
    weak var delegate: ReadMoreLessViewDelegate?
    
    var state: ReadMoreLessViewState = .collapsed {
        didSet {
            guard oldValue != state else {return}
            switch state {
            case .collapsed:
                textLabel.lineBreakMode = .byTruncatingTail
                textLabel.numberOfLines = maxNumberOfLinesCollapsed
                moreLessButton.setTitle(getButtonText(), for: UIControl.State())
            case .expanded:
                textLabel.lineBreakMode = .byWordWrapping
                textLabel.numberOfLines = 0
                moreLessButton.setTitle(getButtonText(), for: UIControl.State())
            }
            invalidateIntrinsicContentSize()
            delegate?.didChangeState(self)
        }
    }
    
    @objc func buttonTouched(_ sender: UIButton) {
        
        if autoExpandCollapse{
            state.toggle()
        }else{
            delegate?.didClickButton(self)
        }
    }
    
    lazy fileprivate var moreLessButton: UIButton! = {
        let button = UIButton(frame: CGRect.zero)
        button.backgroundColor = UIColor.clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(ReadMoreLessView.buttonTouched(_:)), for: .touchUpInside)
        button.setTitleColor(buttonColor, for: UIControl.State())
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        button.setContentHuggingPriority(.required, for: .vertical)
        button.contentHorizontalAlignment = .right
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        return button
    }()
    
    lazy fileprivate var textLabel: UILabel! = {
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .black
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    lazy fileprivate var theStackView: UIStackView = {
        let v = UIStackView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .vertical
        v.alignment = .fill
        v.distribution = .fill
        v.spacing = 0
        v.backgroundColor = .clear
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureViews()
    }
    
    fileprivate func initComponents() {
        textLabel.font = textLabelFont
        textLabel.textColor = textColor
        moreLessButton.titleLabel!.font = moreLessButtonFont
        moreLessButton.setTitleColor(buttonColor, for: UIControl.State())
        moreLessButton.setTitle(getButtonText(), for: UIControl.State())
        textLabel.layer.addObserver(self, forKeyPath: "bounds", options: [], context: &kvoContext)
    }
    
    fileprivate func getButtonText() -> String{
        if state == .collapsed{
            return moreText
        }
        return lessText
    }
    
    fileprivate func configureViews() {
        //state = .collapsed
        addSubview(theStackView)
        
        let rightLabel =
        NSLayoutConstraint(item: theStackView, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0)
        let leftLabel =
        NSLayoutConstraint(item: theStackView, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0)
        let topLabel =
        NSLayoutConstraint(item: theStackView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
        let bottomLabel =
        NSLayoutConstraint(item: theStackView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([rightLabel, leftLabel, topLabel, bottomLabel])
        
        //for empty text
        //let spacer = UIView(frame: CGRect(origin: .zero, size: .init(width: 1, height: 1)))
        textLabel.contentCompressionResistancePriority = .required
        moreLessButton.contentCompressionResistancePriority = .required
        theStackView.addArrangedSubview(textLabel!)
        theStackView.addArrangedSubview(moreLessButton!)
        //theStackView.addArrangedSubview(spacer)
        initComponents()
    }
    
    func setText(text: String, state: ReadMoreLessViewState? = nil) {
        guard let textLabel = textLabel else { return }
        textLabel.text = text
        if text.isEmpty {
            moreLessButton.isHidden = true
            moreLessButton.isEnabled = false
        } else {
            moreLessButton.isHidden = false
            moreLessButton.isEnabled = true
        }
        if state != nil{
            self.state = state!
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            if let textLabel = textLabel, let text = textLabel.text, !text.isEmpty {
                if maxNumberOfLinesCollapsed == 0 ||
                   countLabelLines(label: textLabel) <= maxNumberOfLinesCollapsed {
                    moreLessButton.isHidden = true
                }else{
                    moreLessButton.isHidden = false
                    layoutIfNeeded()
                }
            }
        }else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    fileprivate func countLabelLines(label: UILabel) -> Int {
        layoutIfNeeded()
        let myText = label.text! as NSString
        let attributes = [NSAttributedString.Key.font : label.font as UIFont]
        let labelSize = myText.boundingRect(with: CGSize(width: label.bounds.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        let returnValue = Int(ceil(CGFloat(labelSize.height) / label.font.lineHeight))
        return returnValue
    }
    
    deinit {
        textLabel.layer.removeObserver(self, forKeyPath: "bounds")
    }
    
    // MARK: Interface Builder
    
    override func prepareForInterfaceBuilder() {
        let bodytext = "Lorem ipsum dolor sit amet, eam eu veri corpora, eu sit zril eirmod integre, his purto quaestio ut. Lorem ipsum dolor sit amet, eam eu veri corpora, eu sit zril eirmod integre, his purto quaestio ut."
        setText(text: text.isEmpty ? bodytext : text)
    }

}
