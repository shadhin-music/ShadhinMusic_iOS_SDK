//
//  RbtPlanCell.swift
//  Shadhin_Gp
//
//  Created by Maruf on 28/1/26.
//

import UIKit

class RbtPlanCell: UICollectionViewCell {

    @IBOutlet weak var checkIconSet: UIImageView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!

    //MARK: create nib for access this cell
    static var identifier: String {
        return String(describing: self)
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    // MARK: - Setup UI
    private func setupUI() {
        // Add corner radius and border
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor

        // Initially hide checkmark
        checkIconSet.isHidden = true

        // Optional: Add shadow for better appearance
        // layer.shadowColor = UIColor.black.cgColor
        // layer.shadowOffset = CGSize(width: 0, height: 2)
        // layer.shadowOpacity = 0.1
        // layer.shadowRadius = 4
    }

    // MARK: - Configure Cell
    func configure(with plan: RBTSubscriptionPlan) {
        // Set price with currency symbol
        priceLbl.text = "৳\(String(format: "%.2f", plan.price))"

        // Set duration with proper singular/plural
        if plan.duration == 1 {
            durationLbl.text = "\(plan.duration) Day"
        } else {
            durationLbl.text = "\(plan.duration) Days"
        }
    }

    // MARK: - Configure with Selection State
    func configure(with plan: RBTSubscriptionPlan, isSelected: Bool) {
        // First configure with plan data
        configure(with: plan)
        // Update selection state
        if isSelected {
            // Show checkmark
            checkIconSet.isHidden = false

            // Update border and background
            layer.borderColor = UIColor.appTint.cgColor
            layer.borderWidth = 1
            backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)

        } else {
            // Hide checkmark
            checkIconSet.isHidden = true
            layer.borderColor = UIColor.lightGray.cgColor
            layer.borderWidth = 1
            backgroundColor = .white
        }
    }

    // MARK: - Prepare for Reuse
    override func prepareForReuse() {
        super.prepareForReuse()

        // Reset all properties
        priceLbl.text = nil
        durationLbl.text = nil
        checkIconSet.isHidden = true

        // Reset styling
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1
        backgroundColor = .white
//        priceLbl.textColor = .label
//        durationLbl.textColor = .secondaryLabel
    }
}
