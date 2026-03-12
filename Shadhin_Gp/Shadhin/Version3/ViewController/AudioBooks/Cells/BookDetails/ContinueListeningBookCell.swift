//
//  ContinueListeningBookCell1.swift
//  Shadhin
//
//  Created by Maruf on 7/10/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class ContinueListeningBookCell: UICollectionViewCell {
    var dataSource = [CommonContentProtocol]()
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var onSeeAll: (()->Void)?
    unowned var vc: HomeAdapterProtocol?
    var streamingData : [StreamingHistoryContent] = []
    @IBOutlet weak var seeAllbtn: UIButton!
    var audioBookHome = [AudioPatchContent]()
    @IBOutlet weak var titleNameLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var size: CGSize {
        let aspectRatio = 360.0/280.0
        let width = SCREEN_WIDTH - 32 
        let height = width/aspectRatio
        return CGSize(width: width, height: height)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ContinueListeningEffectViewCell.nib, forCellWithReuseIdentifier: ContinueListeningEffectViewCell.identifier)
    }
    func bind(title:String,with data : HomeV3Patch) {
        titleNameLbl.text  = title
        self.dataSource = data.contents
        seeAllbtn.isHidden = data.patch.isSeeAllActive
    }
     func getStreamingHistoryContent() {
        indicator.startAnimating()
        ShadhinCore.instance.api.getStreamingHistory { [weak self] responseModel in
            guard let self = self else { return }
            indicator.stopAnimating()
            indicator.isHidden = true
            switch responseModel {
            case .success(let success):
                self.streamingData = success.data.contents
                self.collectionView.reloadData()
            case .failure(let error):
                print("Streaming history fetch failed: \(error)")
            }
        }
    }
    
    func bindAudioBookContinueListening(with patch:AudioPatchHome) {
        audioBookHome = patch.contents
        titleNameLbl.text = patch.patch.title
        print("\(audioBookHome)")
    }

    @IBAction func seeAllClicked(_ sender: Any) {
        let vc = HomeSeeAllVC.instantiateNib()
        vc.isStreamingHistoryData = true
        let historyData = StreamingHistoryData(contents: streamingData)
        vc.streamingHistoryContent = historyData
        self.navigationController()?.pushViewController(vc, animated: true)
    }
    
}

extension ContinueListeningBookCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        streamingData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContinueListeningEffectViewCell.identifier, for: indexPath) as? ContinueListeningEffectViewCell else{
            fatalError()
        }
        cell.bindStreamingData(content: streamingData[indexPath.item])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return ContinueListeningEffectViewCell.size
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let content = streamingData[indexPath.row]
        let vc  = AudioBookDetailsVC()
        let contentId = content.contentId
        vc.selectedTrackID = String(content.contentId)
        vc.episodeId = String(contentId)
        MusicPlayerV3.shared.episodeId = String(contentId)
        vc.artistId = String(contentId)
        print("\(contentId)")
        navigationController()?.pushViewController(vc, animated: true)
    }
    
}
