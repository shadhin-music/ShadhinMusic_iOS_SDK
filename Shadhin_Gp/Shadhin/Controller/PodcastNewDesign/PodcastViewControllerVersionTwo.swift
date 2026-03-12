//
//  PodcastViewControllerVersionTwo.swift
//  Shadhin_Gp
//

import UIKit

// MARK: - UI Models
enum PodcastUpdateDesignType: Int {
    case shadhinPodcast = 25
    case TopChart = 15
    case UNKNOWN = -1
}

enum PodcastSectionItem {
    case content(PodcastSectionVersionTwo)
    case ad(String)
}

class PodcastViewControllerVersionTwo: UIViewController, NIBVCProtocol {
    private let refreshControl = UIRefreshControl()
    @IBOutlet weak var collectionView: UICollectionView!

    var dataSource = [PodcastSectionItem]()
    private let adTagIds = [
        "76401d96",
        "a8dc943f",
        "07a87b0a",
        "ac092e46",
        "1f52ec73",
        "76766237"
    ]
    private var adHeights: [String: CGFloat] = [:]
    
    // MARK: - Loader
    private let loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupLoader()
        fetchPodcastData()
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PodcastGridCell.nib, forCellWithReuseIdentifier: PodcastGridCell.identifier)
        collectionView.register(VmaxCommonAdCell.nib, forCellWithReuseIdentifier: VmaxCommonAdCell.identifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "EmptyCell")
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 20, right: 16)

        // Pull to refresh
        refreshControl.tintColor = .appTint
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    @objc private func handleRefresh() {
        fetchPodcastData(isPullToRefresh: true)
    }

    private func fetchPodcastData(isPullToRefresh: Bool = false) {
        if isPullToRefresh {
            adHeights.removeAll()
        } else {
            LoadingIndicator.initLoadingIndicator(view: self.view)
            LoadingIndicator.startAnimation(true)
        }

        ShadhinApi().getPodcastPatchDetails { [weak self] (response, error) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                LoadingIndicator.stopAnimation()
                self.refreshControl.endRefreshing()
            }

            if let error = error {
                print("Error fetching podcasts: \(error.localizedDescription)")
                return
            }

            if let data = response?.data {
                var updatedData: [PodcastSectionItem] = []
                for (index, item) in data.enumerated() {
                    updatedData.append(.content(item))
                    if index < self.adTagIds.count {
                        let tagId = self.adTagIds[index]
                        updatedData.append(.ad(tagId))
                    }
                }

                self.dataSource = updatedData
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }

    private func setupLoader() {
        self.collectionView.addSubview(loader)
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
    }

    // MARK: - 3. The API Call Logic
    private func fetchPodcastData() {
        LoadingIndicator.initLoadingIndicator(view: self.view)
        LoadingIndicator.startAnimation(true)

        ShadhinApi().getPodcastPatchDetails { [weak self] (response, error) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                LoadingIndicator.stopAnimation() // ALWAYS STOP LOADER
            }

            if let error = error {
                print("Error fetching podcasts: \(error.localizedDescription)")
                return
            }

            if let data = response?.data {
                var updatedData: [PodcastSectionItem] = []
                for (index, item) in data.enumerated() {
                    
                    updatedData.append(.content(item))
                    if index < adTagIds.count {
                        let tagId = adTagIds[index]
                        updatedData.append(.ad(tagId))
                    }
                }
                
                self.dataSource = updatedData
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

// MARK: - Collection View Delegate & Data Source
extension PodcastViewControllerVersionTwo: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch dataSource[indexPath.item] {
        case .content(let sectionData):
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PodcastGridCell.identifier,
                for: indexPath) as? PodcastGridCell else {
                fatalError("Unable to dequeue PodcastGridCell")
            }
            
            cell.delegate = self
            cell.dataBind(
                name: sectionData.patch.title,
                contents: sectionData.contents
            )
            
            return cell
            
            
        case .ad(let tagId):
            print("AD CELL HIT:", tagId)
            
            if ShadhinGP.shared.isVmaxInitialized &&
                !ShadhinCore.instance.isUserPro &&
                VMAX_AD_ITEM_DATA.contains(where: { $0.adId == tagId }) {
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: VmaxCommonAdCell.identifier,
                    for: indexPath
                ) as? VmaxCommonAdCell else {
                    fatalError()
                }

                cell.setupCell(tagId: tagId)
                cell.onAdFailed = { [weak self] in
                    self?.adHeights[tagId] = 0
                    self?.collectionView.performBatchUpdates(nil)
                }
                
                cell.onHeightChanged = { [weak self] newHeight in
                    guard let self = self else { return }
                    if self.adHeights[tagId] == newHeight { return }
                    self.adHeights[tagId] = newHeight
                    
                    DispatchQueue.main.async {
                        self.collectionView.performBatchUpdates({
                            self.collectionView.collectionViewLayout.invalidateLayout()
                        })
                    }
                }
                return cell
            }
            return collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = SCREEN_WIDTH - 32
        switch dataSource[indexPath.item] {
            
        case .content:
            return CGSize(width: width, height: PodcastGridCell.height)
            
        case .ad(let tagId):
            if ShadhinGP.shared.isVmaxInitialized &&
                !ShadhinCore.instance.isUserPro &&
                VMAX_AD_ITEM_DATA.contains(where: { $0.adId == tagId }) {
                let height = adHeights[tagId] ?? 1.1
                return height > 1 ? CGSize(width: width, height: height) : .zero
            }
            return .zero
        }
    }
}

// MARK: - Cell Delegate
extension PodcastViewControllerVersionTwo: PodcastGridCellDelegate {
    
    func didSelectPodcastItem(content: PodcastContentVersionTwo) {
        let storyboard = UIStoryboard(name: "PodCast", bundle: Bundle.ShadhinMusicSdk)
        
        guard let vc = storyboard.instantiateViewController(withIdentifier: "PodcastVC") as? PodcastVC else {
            return
        }
        let episodeID = getActualContentId(content: content)
        vc.podcastCode = content.contentType
        vc.selectedEpisode = episodeID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getActualContentId(content: PodcastContentVersionTwo) -> Int {
        let subType = content.podcast?.contentSubType?.uppercased() ?? ""
        if subType == "TRACK" {
            return content.release?.id ?? 0
        } else if subType == "EPISODE" {
            return content.contentId
        } else {
            return 0
        }
    }
}
