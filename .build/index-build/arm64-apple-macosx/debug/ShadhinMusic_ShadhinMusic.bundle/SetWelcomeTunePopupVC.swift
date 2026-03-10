///
//  SetWelcomeTunePopupVC.swift
//  Shadhin
//
//  Created by Maruf on 23/11/25.
//  Copyright © 2025 Cloud 7 Limited. All rights reserved.
//

import UIKit

class SetWelcomeTunePopupVC: UIViewController, NIBVCProtocol {
    
    @IBOutlet weak var artistNameLbl: UILabel!
    @IBOutlet weak var musicNameLBl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var subscriptionPlans: [RBTSubscriptionPlan] = []
    private var selectedPlanIndex: Int?
    private var isLoading = false
    var topImageView: UIImage?
    var musicName = ""
    var artsitName = ""
    var contentId = ""
       private var overlayView: UIView = {
           let view = UIView()
           view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
           view.translatesAutoresizingMaskIntoConstraints = false
           view.isHidden = true
           return view
       }()
    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = UIColor.tint
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5) // ✅ force larger size
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = topImageView
        musicNameLBl.text = musicName
        artistNameLbl.text = artsitName
        setupCollectionView()
        setupIndicator()
        loadRBTProducts()
    }

    private func setupCollectionView() {
        collectionView.register(RbtPlanCell.nib, forCellWithReuseIdentifier: RbtPlanCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    @MainActor
    private func loadRBTProducts() {
        isLoading = true

        Task {
            do {
                let response = try await ShadhinCore.instance.api.getRBTProducts(operatorName: "GP")
                await MainActor.run {
                    self.isLoading = false
                    if response.value.success {
                        self.subscriptionPlans = response.value.data
                          if !self.subscriptionPlans.isEmpty {
                              self.selectedPlanIndex = 0
                          }
                        self.collectionView.reloadData()
                    } else {
                        self.showError(message: response.value.message)
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.showError(message: error.localizedDescription)
                }
            }
        }
    }

    @MainActor
    private func purchaseRBTCombo() {
        guard let selectedIndex = selectedPlanIndex else {
            showError(message: "Please select a plan first")
            return
        }

        let selectedPlan = subscriptionPlans[selectedIndex]
        isLoading = true

        Task {
            do {
                let response = try await ShadhinCore.instance.api.purchaseRBTCombo(
                    msisdn:ShadhinCore.instance.defaults.userMsisdn,
                    contentId:contentId,
                    productId:selectedPlan.id,
                    operatorName: selectedPlan.operator,
                    purchaseMode: "shadhin-app"
                )
                hideIndicator()

                self.isLoading = false

                if response.success {
                    showSuccessPopup()
                } else {
                    let apiMessage =
                            response.error?.message ??
                            response.message ??
                            "Something went wrong"
                        showTechnicalErrorPopup(errorMsg: apiMessage)
                }
            } catch let error as AFError {
                hideIndicator()
                handleAPIError(error)
            } catch {
                hideIndicator()
                showError(message: "Something went wrong. Please try again.")
            }
        }
    }



    private func showError(message: String) {
           let alert = UIAlertController(
               title: "Error",
               message: message,
               preferredStyle: .alert
           )
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           present(alert, animated: true)
       }

       private func handleAPIError(_ error: AFError) {
           var errorMessage = "Something went wrong. Please try again."

           if let statusCode = error.responseCode {
               switch statusCode {
               case 400:
                   errorMessage = "Invalid request. Please check your information."
               case 401:
                   errorMessage = "Unauthorized. Please login again."
               case 403:
                   errorMessage = "Access denied."
               case 404:
                   errorMessage = "Service not found."
               case 500...599:
                   errorMessage = "Server error. Please try again later."
               default:
                   errorMessage = "Error: \(statusCode)"
               }
           } else if let underlyingError = error.underlyingError {
               errorMessage = underlyingError.localizedDescription
           }

           showError(message: errorMessage)
       }

    // MARK: - Helper Methods
        private func showSuccessPopup() {
            // Dismiss current popup first
            SwiftEntryKit.dismiss()

            // Show success popup
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let vc = AlreadyWelcomeTuneSetPopupVC.instantiateNib()
                vc.image = self.topImageView
                vc.musicName = self.musicName
                vc.artsitName = self.artsitName
                var attribute = SwiftEntryKitAttributes.bottomAlertWrapAttributesRound(offsetValue: 0)
                attribute.entryBackground = .color(color: .clear)
                attribute.border = .none
                attribute.positionConstraints.size = .init(width: .fill, height: .constant(value: 440))
                SwiftEntryKit.display(entry: vc, using: attribute)
            }
        }

    private func showTechnicalErrorPopup(errorMsg:String) {
        // Dismiss current popup first
        SwiftEntryKit.dismiss()

        // Show success popup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let vc = TechnicalErrorPopupVC.instantiateNib()
            vc.errorDetails = errorMsg
            vc.image = self.topImageView
            vc.musicName = self.musicName
            vc.artsitName = self.artsitName
            var attribute = SwiftEntryKitAttributes.bottomAlertWrapAttributesRound(offsetValue: 0)
            attribute.entryBackground = .color(color: .clear)
            attribute.border = .none
            attribute.positionConstraints.size = .init(width: .fill, height: .constant(value: 640))
            SwiftEntryKit.display(entry: vc, using: attribute)
        }
    }

    // MARK: - Actions
    @IBAction func setWelcomeTuneAction(_ sender: Any) {
        guard selectedPlanIndex != nil else {
            showError(message: "Please select a plan first")
            return
        }
        showIndicator()
        purchaseRBTCombo()
    }

    @IBAction func notNowAction(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }

}

// MARK: - UICollectionView DataSource & Delegate
extension SetWelcomeTunePopupVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subscriptionPlans.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RbtPlanCell.identifier, for: indexPath) as? RbtPlanCell else {
            fatalError("Unable to dequeue RbtPlanCell")
        }

        let plan = subscriptionPlans[indexPath.item]
        let isSelected = selectedPlanIndex == indexPath.item

        cell.configure(with: plan, isSelected: isSelected)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 10
        let totalSpacing = spacing * 4 // Left + Right + 2 inter-item spacing
        let width = (collectionView.bounds.width - totalSpacing) / 3
        return CGSize(width: width, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPlanIndex = indexPath.item
        collectionView.reloadData()
        let selectedPlan = subscriptionPlans[indexPath.item]
        print("Plan selected - ID: \(selectedPlan.id), Duration: \(selectedPlan.duration) days, Price: ৳\(selectedPlan.price)")
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }


}

extension SetWelcomeTunePopupVC {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupIndicator()
    }

    private func setupIndicator() {
        // Add directly to self.view, but on top of everything
        view.addSubview(overlayView)
        view.addSubview(activityIndicator) // ✅ add indicator directly to view, NOT inside overlay

        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func showIndicator() {
        view.bringSubviewToFront(overlayView)
        view.bringSubviewToFront(activityIndicator) // ✅ bring both to front
        overlayView.isHidden = false
        activityIndicator.startAnimating()
    }

    private func hideIndicator() {
        overlayView.isHidden = true
        activityIndicator.stopAnimating()
    }

}
