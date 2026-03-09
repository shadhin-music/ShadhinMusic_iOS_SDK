import UIKit

protocol PodcastGridCellDelegate: AnyObject {
    func didSelectPodcastItem(content: PodcastContentVersionTwo)
}

class PodcastGridCell: UICollectionViewCell {
    weak var delegate: PodcastGridCellDelegate?
    var dataSource = [PodcastContentVersionTwo]()
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!


    static var height : CGFloat{
        return 310
    }

    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)

    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

    }

    func dataBind(name: String, contents: [PodcastContentVersionTwo]) {
        self.titleLbl.text = name
        self.dataSource = contents
        self.collectionView.reloadData()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PodcastGridSubCell.nib, forCellWithReuseIdentifier: PodcastGridSubCell.identifier)
    }
}

extension PodcastGridCell: UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let obj = dataSource[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PodcastGridSubCell.identifier, for: indexPath) as? PodcastGridSubCell else{
            fatalError()
        }
        cell.dataBind(data: obj)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return PodcastGridSubCell.size
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let obj = dataSource[indexPath.item]
        delegate?.didSelectPodcastItem(content: obj)
    }
}

