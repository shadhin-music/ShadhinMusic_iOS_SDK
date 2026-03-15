//
//  FAQAnswerScrollTVCell.swift
//  Shadhin_Gp
//
//  Created by Shadhin Music on 6/11/25.
//

import UIKit

class FAQAnswerScrollTVCell: UITableViewCell {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imgView: UIImageView!

    static var identifier: String {
        return String(describing: self)
    }
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        scrollView.layer.cornerRadius = 12
        imgView.layer.cornerRadius = 12
        imgView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgView.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func dataBindCell(_ data: FAQAnswerData) {
        if let url = URL(string: data.imageUrl ?? "") {
            loadImage(from: url)
        }
    }
}


// MARK: - Helpers
extension FAQAnswerScrollTVCell {

    private func loadImage(from url: URL) {
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.imgView.image = image
                self.setupImageZoom()
                self.updateImageViewAspectRatio(for: image)
            }
        }
    }

    private func setupImageZoom() {
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.delegate = self

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }

    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        let zoomScale = scrollView.zoomScale == 1.0 ? 3.0 : 1.0
        scrollView.setZoomScale(zoomScale, animated: true)
    }

    private func updateImageViewAspectRatio(for image: UIImage) {
        let aspectRatio = image.size.height / image.size.width
        let width = UIScreen.main.bounds.width - 32
        let newHeight = width * aspectRatio
        imgView.heightAnchor.constraint(equalToConstant: newHeight).isActive = true
        layoutIfNeeded()
    }
}

// MARK: - UIScrollViewDelegate (Zoom)
extension FAQAnswerScrollTVCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgView
    }
}
