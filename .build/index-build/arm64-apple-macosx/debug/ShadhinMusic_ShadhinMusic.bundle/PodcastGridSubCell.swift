//
//  PodcastGridSubCell.swift
//  Shadhin_Gp
//
//  Created by Maruf on 10/2/26.
//

import UIKit

class PodcastGridSubCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    static var size : CGSize{
        return .init(width: 136, height: 136)
    }

    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)

    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

    }

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    func dataBind(data:PodcastContentVersionTwo) {
        self.imageView.kf.setImage(with: URL(string: data.imageUrl?.image300 ?? ""))
        self.titleLbl.text = data.titleEn

    }
}


