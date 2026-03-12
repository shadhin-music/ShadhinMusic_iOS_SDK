//
//  HomeAdapter.swift
//  Shadhin
//
//  Created by Joy on 10/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

enum HomePatchType : Int{
    case BILLBOARD                                  = 1
    case TWO_ROW_SQR_WITH_DESC_LEFT                 = 2
    case SINGLE_ITEM_WITH_SEE_ALL                   = -8
    case CIRCULAR_WITH_FAV_BTN                      = 4
    case RECENTLY_PLAYED                            = -5
    case DOWNLOADED                                 = 6
    case TWO_ROW_SQR                                = 7
    case PATCH_DESC_TOP_WITH_SQR_DESC_BELOW         = 8
    case SQR_PAGER_WITH_DESC_BELOW                  = -9
    case TWO_ROW_SQR_WITH_DESC_BELOW                = 10
    case CIRCULAR_WITH_DESC_BELOW                   = 11
    case REC_PAGER_WITH_DESC_INSIDE                 = -12
    case TWO_ROW_REC_DESC_BELOW                     = 13
    case TEASER                                     = 14
    case PATCH_DESC_TOP_WITH_REC_PORT_DESC_BELOW    = 15
    case SINGLE_LINE_WITH_DESCRIPTION               = 16
    case SQR_WITH_DESC_BELOW                        = -17
    case AI_PLAYLIST                                = -18
    case LATEST_AUDIO_BOOK                          = -19
    case CONTINUE_LESTING                           = 23
    case BOOK_CATAGORIES                            = -22
    case RECOMMENDED_BOOKS                          = -20
    case SQR                                        = -3
    case WIN_AND_STREAM                             = -24
    case TICKET                                     = -55
    case REWIND                                     = -6
    case AD                                         = -77
    case VAMX_AD                                    = -88
    case UNKNOWN                                    = -1
}

protocol HomeAdapterProtocol : NSObjectProtocol{
    // Read-write property
    var parentCollectionView: UICollectionView? {get set}
    var homeAdapter: HomeAdapter? { get set }
    var homeVM: HomeVM? {get set}
    func loadMorePatchs()
    func onScroll(y: Double)
    func onItemClicked(patch: HomeV3Patch, content: CommonContentProtocol)
    func getNavController() -> UINavigationController
//    func gotoLeaderBoard2(method : PaymentMethod, campaignType : String)
    func gotoLeaderBoard(method : CampaignWrapper, campaignType : String)
    func particapetClick(payment : PaymentMethod)
    func seeAllClick(patch : HomeV3Patch)
    func onRewind(rewindData : [TopStreammingElementModel])
    func onSubscription()
    func navigateToAIGeneratedContent(content: AIPlaylistResponseModel?, imageUrl: String, playlistName: String, playlistId: String)
    func reloadView(indexPath: IndexPath)
    func refreshHome()
    func viewMackToastShow(message: String)
    func gotoPurchaseVC()
}


class HomeAdapter: NSObject {
    
    private weak var delegate : HomeAdapterProtocol?
    private var dataSourceV3: [HomeV3Patch] = []
    var aiPlaylists: [NewContent]?
    var isCheckingAIPlaylistExists = false
    private var vamxAdsInserted = false
    private var insertedAdCodes: Set<String> = []
    private var adHeights: [String: CGFloat] = [:]

    private var recentPlayList : [CommonContentProtocol] {
        do{
            return try RecentlyPlayedDatabase.instance.getDataFromDatabase(fetchLimit: 10)
        }catch{
            Log.error(error.localizedDescription)
        }
        return []
    }
    
    private var downloadList : [CommonContentProtocol] {
        return DatabaseContext.shared.getRecentlyDownloadList()
    }
    
    private var streamNwinCampaignResponse : CampaignResponseNew?
    var simpleCompaign: [SimpleCampaign]?
    private var concertEventObj : ConcertEventObj?
    private var rewindData : [TopStreammingElementModel] = []
    
    var lastContentOffset = SCREEN_SAFE_TOP + 56
    var page : Int = 0
    var noNativeAd = true
    
    init(delegate: HomeAdapterProtocol) {
        self.delegate = delegate
        super.init()
    }
    func reset(){
        ShadhinApi.getVmaxAdData()
        aiPlaylists = nil
        isCheckingAIPlaylistExists = false
        dataSourceV3.removeAll()
        vamxAdsInserted = false
        insertedAdCodes.removeAll()
        page = 0
    }

    func addPatchesV3Main(array: [HomeV3Patch]) {
        dataSourceV3.append(contentsOf: array)
        dataSourceV3 = dataSourceV3.sorted(by: {$0.patch.sort < $1.patch.sort})
        page = page + 1
        
        HOMEV3PATCH = dataSourceV3
        print(dataSourceV3)
        debugPrint("page : ",page)
    }
    
    func addPatchesV3(array: [HomeV3Patch]) {
        dataSourceV3.append(contentsOf: array)
        dataSourceV3 = dataSourceV3.sorted(by: {$0.patch.sort < $1.patch.sort})
        
        if !vamxAdsInserted {
            var insertionOffset = 0
            for (patchCode, adCode) in PATCHCODE_TO_ADCODE_MAPPING {
                if insertedAdCodes.contains(patchCode) {
                    continue
                }
                
                if let targetIndex = dataSourceV3.firstIndex(where: { $0.patch.code == patchCode }) {
                    let adjustedIndex = targetIndex + insertionOffset + 1
                    print("✅ Found \(patchCode) at index \(targetIndex), inserting ad at \(adjustedIndex)")
                    
                    let adPatch = HomeV3Patch(
                        patch: HomeV3PatchDetails(
                            id: adjustedIndex,
                            code: adCode,
                            title: "Vmax Ad",
                            description: "",
                            imageURL: "",
                            designType: -88,
                            isSeeAllActive: false,
                            isShuffle: false,
                            sort: dataSourceV3[targetIndex].patch.sort + 1
                        ),
                        contents: []
                    )
                    
                    dataSourceV3.insert(adPatch, at: adjustedIndex)
                    
                    for i in (adjustedIndex + 1)..<dataSourceV3.count {
                        dataSourceV3[i].patch.sort += 1
                    }
                    
                    insertedAdCodes.insert(patchCode)
                    insertionOffset += 1
                } else {
                    print("⚠️ Patch code \(patchCode) not found")
                }
            }
            
            page += 1
            HOMEV3PATCH = dataSourceV3
            print("📊 Total patches after VMAX insertion: \(dataSourceV3.count)")
            print(dataSourceV3)
            debugPrint("page : ",page)
        }
    }

    func addStreamNwin(stream : CampaignResponseNew) {
        if stream.success {
            self.streamNwinCampaignResponse = stream
        } else {
            self.streamNwinCampaignResponse = nil
        }
    }
    func addTicket(ticket : ConcertEventObj){
        self.concertEventObj = ticket
    }
    func addRewind(rewind : [TopStreammingElementModel]){
        self.rewindData = rewind
    }
    
    private func isIndexOfAnAd(index : Int) -> Bool{
        if ShadhinCore.instance.isUserPro || noNativeAd{
            return false
        }
        return (index > 2) && isMultipleOfFour(index+1)
    }
    
    func isMultipleOfFour(_ number: Int) -> Bool {
        return number % 4 == 0
    }
    
    private func getMultiplier(index: Int) -> Int{
        let n = (Double(index) - 3) / 4.0
        return Int((floor(n) + 1))
    }
    
    private func getAdsAdjustedIndex(index: Int) -> Int{
        if ShadhinCore.instance.isUserPro || noNativeAd{
            return index
        }
        let n = getMultiplier(index: index)
        let adjustedIndex = n > 0 ? index - n : index
        return adjustedIndex
    }
}

extension HomeAdapter : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSourceV3.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = getAdsAdjustedIndex(index: indexPath.row)
      //  let patchType = isIndexOfAnAd(index: indexPath.row) ? .AD : dataSource[index].getDesign()
        let patchTypeV3 = isIndexOfAnAd(index: indexPath.row) ? .AD : dataSourceV3[index].patch.getDesign()
      //  let obj = dataSource[index]
        let obj3 = dataSourceV3[index]
        switch patchTypeV3{
        case .BILLBOARD:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Billboard.identifier, for: indexPath) as? Billboard else{
                fatalError()
            }
            cell.configureCell(patch: obj3)
            cell.onClick = {[weak self ] item in
                guard let self = self else {return}
                Log.info("\(item)")
                self.delegate?.onItemClicked(patch: obj3, content: item)
            }
            return cell
        case .TWO_ROW_SQR_WITH_DESC_LEFT:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TwoRowSqrWithDescLeft.identifier, for: indexPath) as? TwoRowSqrWithDescLeft else{
                fatalError()
            }
            //        cell.bind(with: obj)
            cell.onItemClick = {[weak self ] item in
                guard let self = self else {return}
                self.delegate?.onItemClicked(patch: obj3, content: item)
            }
            cell.onSeeAllClick = {[weak self] in
                guard let self = self else {return}
                self.delegate?.seeAllClick(patch: obj3)
            }
            return cell
        case .CIRCULAR_WITH_FAV_BTN:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CircularWithFavBtn.identifier, for: indexPath) as? CircularWithFavBtn else{
                fatalError()
            }
            cell.bind(title: obj3.patch.title, data: obj3.contents,isSeeAll: obj3.patch.isSeeAllActive)
            
            cell.onItemClick = {[weak self] content in
                guard let self = self else {return}
                self.delegate?.onItemClicked(patch: obj3, content: content)
            }
            //            cell.onFollow = {[weak self] content in
            //                guard let _ = self else {return}
            //            }
            cell.onSeeAllClick = {[weak self] in
                guard let self = self else {return}
                self.delegate?.seeAllClick(patch: obj3)
            }
            return cell
            
        case .RECENTLY_PLAYED:
            if ShadhinCore.instance.isUserLoggedIn{
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentlyPlayerCell.identifier, for: indexPath) as? RecentlyPlayerCell else {
                    fatalError()
                }
                cell.bind(with: obj3.patch.title, dataSource: self.recentPlayList, isSeeAll: obj3.patch.isSeeAllActive)
                cell.onItemClick = {[weak self] content in
                    guard let self = self else {return}
                    IS_RECENTPLAY = true
                    self.delegate?.onItemClicked(patch: obj3, content: content)
                }
                cell.onSeeAllClick = {[weak self] in
                    guard let self = self else {return}
                    self.delegate?.seeAllClick(patch: obj3)
                }
                return cell
            }
            return collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
            
        case .DOWNLOADED:
            if !ShadhinCore.instance.isUserPro || downloadList.isEmpty{
                return collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
            }
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DownloadsHomeCell.identifier, for: indexPath) as? DownloadsHomeCell else {fatalError()}
            cell.bind(with: obj3.patch.title, subtitle: obj3.patch.description ?? "", dataSource: downloadList, isSeeAll: obj3.patch.isSeeAllActive)
            cell.onItemClick = {[weak self] content in
                guard let self = self else {return}
                self.delegate?.onItemClicked(patch: obj3, content: content)
            }
            cell.onSeeAll = { [weak self] in
                guard let self = self else {return}
                self.delegate?.seeAllClick(patch: obj3)
            }
            return cell
            
        case .TWO_ROW_SQR:
            if obj3.patch.title != "Playlist Mixes For You" {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TwoRowSqr.identifier, for: indexPath) as? TwoRowSqr else{
                    fatalError()
                }
                cell.bind(with: obj3)
                cell.onItemClick = {[weak self] content in
                    guard let self = self else {return}
                    self.delegate?.onItemClicked(patch: obj3, content: content)
                }
                cell.onSeeAllClick = { [weak self] in
                    guard let self = self else {return}
                    self.delegate?.seeAllClick(patch: obj3)
                }
                
                return cell
            } else {
                return collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
            }
            
        case .PATCH_DESC_TOP_WITH_SQR_DESC_BELOW:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PatchDescTopWithSqrDescBelow.identifier, for: indexPath) as? PatchDescTopWithSqrDescBelow else{
                fatalError()
            }
            cell.bind(with: obj3)
            cell.onItemClick = {[weak self] content in
                guard let self = self else {return}
                self.delegate?.onItemClicked(patch: obj3, content: content)
            }
            
            return cell
        case .SQR_PAGER_WITH_DESC_BELOW:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SqrPagerWithDescBelow.identifier, for: indexPath) as? SqrPagerWithDescBelow else{
                fatalError()
            }
            cell.bind(with: obj3.contents)
            cell.onItemClick = {[weak self] content in
                guard let self = self else {return}
                self.delegate?.onItemClicked(patch: obj3, content: content)
            }
            cell.seeAllClick = {[weak self] in
                guard let self = self else {return}
                self.delegate?.seeAllClick(patch: obj3)
            }
            return cell
        case .TWO_ROW_SQR_WITH_DESC_BELOW:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TwoRowSqrWithDescBelow.identifier, for: indexPath) as? TwoRowSqrWithDescBelow else{
                fatalError()
            }
            cell.bind(with: obj3.patch.title, dataSource: obj3.contents)
            cell.onItemClick = {[weak self] content in
                guard let self = self else {return}
                self.delegate?.onItemClicked(patch: obj3, content: content)
            }
            cell.onSeeAll = {[weak self] in
                guard let self = self else {return}
                self.delegate?.seeAllClick(patch: obj3)
            }
            return cell
        case .CIRCULAR_WITH_DESC_BELOW:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CircularWithDescBelow.identifier, for: indexPath) as? CircularWithDescBelow else{
                fatalError()
            }
            cell.bind(with: obj3.patch.title, obj3.contents,isSeeAll: obj3.patch.isSeeAllActive)
            cell.onItemClick = {[weak self] content in
                guard let self = self else {return}
                self.delegate?.onItemClicked(patch: obj3, content: content)
            }
            cell.onSeeAll = {[weak self] in
                guard let self = self else {return}
                self.delegate?.seeAllClick(patch: obj3)
            }
            return cell
        case .SINGLE_LINE_WITH_DESCRIPTION:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SqrWithDescBelow.identifier, for: indexPath) as? SqrWithDescBelow else{
                fatalError()
            }
            cell.bind(with: obj3)
            cell.onItemClick = {[weak self] content in
                guard let self = self else {return}
                self.delegate?.onItemClicked(patch: obj3, content: content)
            }
            cell.onSeeAll = {[weak self] in
                guard let self = self else {return}
                self.delegate?.seeAllClick(patch: obj3)
            }
            return cell
        case .SQR_WITH_DESC_BELOW:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleImageItemCell.identifier, for: indexPath) as? SingleImageItemCell else{
                fatalError()
            }
            cell.bind(with: obj3)
            cell.onItemClick = {[weak self] content in
                guard let self = self else {return}
                self.delegate?.onItemClicked(patch: obj3, content: content)
            }
            cell.onSeeAll = {[weak self] in
                guard let self = self else {return}
                self.delegate?.seeAllClick(patch: obj3)
            }
            return cell
        case .REC_PAGER_WITH_DESC_INSIDE:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecPagerWithDescInside.identifier, for: indexPath) as? RecPagerWithDescInside else{
                fatalError()
            }
            cell.bind(with: obj3.contents)
            cell.onItemClick = {[weak self] content in
                guard let self = self else {return}
                self.delegate?.onItemClicked(patch: obj3, content: content)
            }
            return cell
        case .TWO_ROW_REC_DESC_BELOW:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TwoRowRecDescBelow.identifier, for: indexPath) as? TwoRowRecDescBelow else{
                fatalError()
            }
            cell.configureCell(with: dataSourceV3[index])
            cell.onItemClick = {[weak self] content in
                guard let self = self else {return}
                self.delegate?.onItemClicked(patch: obj3, content: content)
            }
            cell.onSeeAll = {[weak self] in
                guard let self = self else {return}
                self.delegate?.seeAllClick(patch: obj3)
            }
            return cell
        case .TEASER:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Teaser.identifier, for: indexPath) as? Teaser else{
                fatalError()
            }
            if let content = obj3.contents.first{
                cell.bind(with: content)
            }
            cell.onPaidContent = { [weak self] in
                self?.delegate?.onSubscription()
            }
            
            return cell
        case .PATCH_DESC_TOP_WITH_REC_PORT_DESC_BELOW:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PatchDescTopWithRecPortDescBelow.identifier, for: indexPath) as? PatchDescTopWithRecPortDescBelow else{
                fatalError()
            }
            cell.bind(with: obj3)
            cell.onItemClick = {[weak self] content in
                guard let self = self else {return}
                IS_RECENTPLAY = false
                self.delegate?.onItemClicked(patch: obj3, content: content)
            }
            return cell
        case .SINGLE_ITEM_WITH_SEE_ALL:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleItemWithSeeAll.identifier, for: indexPath) as? SingleItemWithSeeAll else{
                fatalError()
            }
            cell.bind(with: obj3.contents)
            cell.onSeeAll = {[weak self] in
                guard let self = self else {return}
                self.delegate?.seeAllClick(patch: obj3)
            }
            return cell
        case .SQR:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
        case .UNKNOWN:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
            
        case .WIN_AND_STREAM:
            guard let stream = streamNwinCampaignResponse else {
                return collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
            }
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StreamNwinCollectionCell.identifier, for: indexPath) as? StreamNwinCollectionCell else {
                fatalError()
            }
            
            cell.viewTostCallBack = { [weak self] errorMessage in
                self?.delegate?.viewMackToastShow(message: errorMessage)
            }

            cell.gotoPurchaseVC = { [weak self] in
                self?.delegate?.gotoPurchaseVC()
            }
            
            cell.gotoLeaderboard = {[weak self] camapign in
                guard let self = self else {return}
                self.delegate?.gotoLeaderBoard(method: camapign, campaignType: self.streamNwinCampaignResponse?.title ?? "Stream New Win")
            }
            
            if case .multipleCampaigns(let simpleCampaigns) = stream.data {
                if let firstCampaign = simpleCampaigns.first {
                    cell.bind(with: firstCampaign)
                }
            }
            return cell
        case .TICKET:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
            
        case .REWIND:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SquareImageCell.identifier, for: indexPath) as? SquareImageCell else {
                fatalError()
            }
            cell.imageIV.image = UIImage(named: "rewind",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            cell.setClickListener {[weak self] in
                guard let self = self else {return}
                self.delegate?.onRewind(rewindData: self.rewindData)
            }
            return cell
        case .AI_PLAYLIST :
            if let aiPlaylists {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AIPlaylistItemCell.identifier, for: indexPath) as? AIPlaylistItemCell else {
                    fatalError()
                }
                cell.vc = delegate
                cell.aiPlaylists = aiPlaylists
                return cell
            } else {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AIPlayList.identifier, for: indexPath) as? AIPlayList else {
                    fatalError()
                }
                cell.vc = delegate
                return cell
            }
            
            
        case .LATEST_AUDIO_BOOK:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookHomeCell.identifier, for: indexPath) as? BookHomeCell else {
                fatalError()
            }
            cell.bind(title: obj3.patch.title, with:obj3)
            return cell
            
        case .CONTINUE_LESTING:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContinueListeningBookCell.identifier, for: indexPath) as? ContinueListeningBookCell else {
                fatalError()
            }
            cell.bind(title: obj3.patch.title, with: obj3)
            return cell
            
        case .BOOK_CATAGORIES:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AudiobookCategoriesCell.identifier, for: indexPath) as? AudiobookCategoriesCell else {
                fatalError()
            }
            cell.isHomeV3Content = true
            cell.bind(title: obj3.patch.title, with: obj3)
            cell.bindBookCatagoriesv3(with:obj3)
            return cell
            
        case .RECOMMENDED_BOOKS:
            if ShadhinCore.instance.isUserLoggedIn {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookHomeCell.identifier, for: indexPath) as? BookHomeCell else {
                    fatalError()
                }
                cell.bindRecommended(title: obj3.patch.title, with:obj3)
                return cell
            }
            return collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
        case .AD:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NativeAdLargeCell.identifier, for: indexPath) as? NativeAdLargeCell else{
                fatalError()
            }
            //            if let ad = NativeAdLargeCell.shared(delegate.getNavController()).getNativeAd(){
            //                cell.loadAd(nativeAd: ad)
            //            }
            return cell
            
        case .VAMX_AD:
             
            let tagId = obj3.patch.code
            if ShadhinGP.shared.isVmaxInitialized
                && !ShadhinCore.instance.isUserPro
                && VMAX_AD_ITEM_DATA.contains(where: { $0.adId == tagId }) {
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: VmaxCommonAdCell.identifier,
                    for: indexPath
                ) as? VmaxCommonAdCell else {
                    fatalError()
                }

                cell.setupCell(tagId: tagId)
                cell.onAdFailed = { [weak self] in
                    self?.adHeights[tagId] = 0
                    collectionView.performBatchUpdates(nil)
                }
                
                cell.onHeightChanged = { [weak self] newHeight in
                    guard let self = self else { return }
                    if self.adHeights[tagId] == newHeight { return }
                    self.adHeights[tagId] = newHeight
                    
                    DispatchQueue.main.async {
                        collectionView.performBatchUpdates({
                            collectionView.collectionViewLayout.invalidateLayout()
                        })
                    }
                }
                return cell
            }
            return collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row >= collectionView.numberOfItems(inSection: 0) - 5{
            delegate?.loadMorePatchs()
        }
        if let cell = cell as? Teaser{
            cell.startVideo()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? Teaser, !cell.isFullScreenTapped {
            cell.clearPlayer()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let index = getAdsAdjustedIndex(index: indexPath.row)
        let obj3 = dataSourceV3[index]
        let pathTypeV3 = isIndexOfAnAd(index: indexPath.row) ? .AD : dataSourceV3[index].patch.getDesign()
        let width = SCREEN_WIDTH - 32
        switch pathTypeV3 {
        case .BILLBOARD:
            return .init(width: width, height: Billboard.height)
        case .TWO_ROW_SQR_WITH_DESC_LEFT:
            return .init(width: width, height: TwoRowSqrWithDescLeft.height)
        case .SINGLE_ITEM_WITH_SEE_ALL:
            return .init(width: width, height:SingleItemWithSeeAll.height)
        case .CIRCULAR_WITH_FAV_BTN:
            return .init(width: width, height: CircularWithFavBtn.height)
        case .RECENTLY_PLAYED:
            if ShadhinCore.instance.isUserLoggedIn && !recentPlayList.isEmpty{
                return .init(width: width, height: RecentlyPlayerCell.height)
            }
            return .zero
        case .DOWNLOADED:
            if ShadhinCore.instance.isUserPro && !downloadList.isEmpty{
                return .init(width: width, height: DownloadsHomeCell.height)
            }
            return .zero
        case .TWO_ROW_SQR:
            return obj3.patch.title != "Playlist Mixes For You" ? .init(width: width, height: TwoRowSqr.height) : .zero
        case .PATCH_DESC_TOP_WITH_SQR_DESC_BELOW:
            return .init(width: width, height: PatchDescTopWithSqrDescBelow.height)
        case .SQR_PAGER_WITH_DESC_BELOW:
            return .init(width: width, height: SqrPagerWithDescBelow.height)
        case .TWO_ROW_SQR_WITH_DESC_BELOW:
            return .init(width: width, height: TwoRowSqrWithDescBelow.height)
        case .CIRCULAR_WITH_DESC_BELOW:
            return .init(width: width, height: CircularWithDescBelow.height)
        case .SINGLE_LINE_WITH_DESCRIPTION:
            return .init(width: width, height: SqrWithDescBelow.height)
        case .SQR_WITH_DESC_BELOW:
            return .init(width: width, height: SingleImageItemCell.height)
        case .REC_PAGER_WITH_DESC_INSIDE:
            return .init(width: width, height: RecPagerWithDescInside.height)
        case .TWO_ROW_REC_DESC_BELOW:
            return .init(width: width, height: TwoRowRecDescBelow.height)
        case .TEASER:
            return .init(width: width, height: Teaser.height)
        case .PATCH_DESC_TOP_WITH_REC_PORT_DESC_BELOW:
            let _ = dataSourceV3[index]
            return .init(width: width, height: PatchDescTopWithRecPortDescBelow.height)
        case .AD:
            return  NativeAdLargeCell.size
        case .SQR:
            return .zero
        case .WIN_AND_STREAM:
            guard let stream = streamNwinCampaignResponse else {
                return .zero
            }
            let subCellHeight : CGFloat = stream.title.count == 1 ? 80 : 144
            let h = width + subCellHeight + 32.0
            return .init(width: width, height: h)
        case .UNKNOWN:
            return .zero
        case .TICKET:
            return .zero
        case .REWIND:
            let h = (SCREEN_WIDTH - 32) * 184 / 328
            return .init(width: width, height: h)
        case .AI_PLAYLIST :
            if isCheckingAIPlaylistExists {
                return .zero
            }
            let aspectRatio = 328.0/220.0
            let h  = (SCREEN_WIDTH - 16)/aspectRatio + 10
            return .init(width: width, height: h)
        case .LATEST_AUDIO_BOOK:
            return BookHomeCell.size
        case .CONTINUE_LESTING:
            return ContinueListeningBookCell.size
        case .BOOK_CATAGORIES:
            return AudiobookCategoriesCell.size
        case .RECOMMENDED_BOOKS:
            return RecommendedBooksCell.size
        case .VAMX_AD:
            let tagId = obj3.patch.code
            if ShadhinGP.shared.isVmaxInitialized
                && !ShadhinCore.instance.isUserPro
                && VMAX_AD_ITEM_DATA.contains(where: { $0.adId == tagId }) {
                let height = adHeights[tagId] ?? 0
                return height > 1 ? CGSize(width: width, height: height) : .zero
            }
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        print("Sectionssss: \(section)")
        return UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 ||  scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height{
            return
        }
        let deltaY =  scrollView.contentOffset.y - lastContentOffset
        lastContentOffset = scrollView.contentOffset.y
        delegate?.onScroll(y: deltaY)
    }
}
