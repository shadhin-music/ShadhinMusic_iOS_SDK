//
//  ShadhinPoweredByFooterView.swift
//  Shadhin_Gp_Examaple
//
//  Created by Shadhin Music on 9/3/26.
//


import UIKit

public class ShadhinPoweredByFooterView: UIView {

    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "shadhin music logo", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
        return iv
    }()

    private let poweredByLabel: UILabel = {
        let label = UILabel()
        label.text = "Powered By"
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor.label.withAlphaComponent(0.5)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let shadhinMusicLabel: UILabel = {
        let label = UILabel()
        label.text = "স্বাধীন মিউজিক"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.label.withAlphaComponent(0.75)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let textStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 3
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Configuration

    /// Logo size
    public var logoSize: CGFloat = 22 {
        didSet { updateLogoConstraints() }
    }

    /// Font size
    public var fontSize: CGFloat = 12 {
        didSet {
            poweredByLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
            shadhinMusicLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        }
    }

    /// Text color
    public var textColor: UIColor = UIColor.label {
        didSet {
            poweredByLabel.textColor = textColor.withAlphaComponent(0.5)
            shadhinMusicLabel.textColor = textColor.withAlphaComponent(0.75)
        }
    }

    private var logoWidthConstraint: NSLayoutConstraint?
    private var logoHeightConstraint: NSLayoutConstraint?

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup
    private func setupView() {
        backgroundColor = .clear
        containerStackView.addArrangedSubview(poweredByLabel)
        containerStackView.addArrangedSubview(logoImageView)
        containerStackView.addArrangedSubview(shadhinMusicLabel)
        
        addSubview(containerStackView)
        
        NSLayoutConstraint.activate([
            containerStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerStackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 6),
            containerStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -6),
        ])
        
        updateLogoConstraints()
    }

    private func updateLogoConstraints() {
        logoWidthConstraint?.isActive = false
        logoHeightConstraint?.isActive = false
        
        logoWidthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: logoSize)
        logoHeightConstraint = logoImageView.heightAnchor.constraint(equalToConstant: logoSize)
        
        logoWidthConstraint?.isActive = true
        logoHeightConstraint?.isActive = true
    }
}


