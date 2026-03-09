//
//  HomeVCv3.swift
//  Shadhin
//
//  Created by Joy on 10/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class HomeVCv3: UIViewController, NIBVCProtocol{

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var profileButton : UIButton?
    @IBOutlet weak var searchButton : UIButton?
    @IBOutlet weak var collectionView : UICollectionView?
    @IBOutlet weak var appBarView: UIView!
    @IBOutlet weak var darkModeBtn: UIButton!
    
    private var refreshControll : UIRefreshControl?
    var adapter : HomeAdapter!
    var vm : HomeVM!
    var episodes = [AudioBookContent]()
    var appFirstOpen = true
    public var coordinator : HomeCoordinator?
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        // Then your other setup
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        searchButton?.addTarget(self, action: #selector(onSearchPressed), for: .touchUpInside)
        searchButton?.addTarget(self, action: #selector(onSearchPressed), for: .touchDown)
        vm = HomeVM(presenter: self)
        viewSetup()
        if let navVc = self.navigationController{
            coordinator = HomeCoordinator(navigationController: navVc, tabBar: self.tabBarController)
        }
        vm.loadRecomandedV3()
        NotificationCenter.default.addObserver(self, selector: #selector(performTaskAfterSubscriptionCheck), name: .didTapBackBkashPayment, object: nil)
        setupBottomLoadingIndicator()
        self.performTaskAfterSubscriptionCheck()
        GPSDKSubscription.getNewUserSubscriptionDetails { _ in
            self.moreButtonActionMenu()
            NotificationCenter.default.post(name: .newSubscriptionUpdate, object: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        ShadhinApi.getVmaxAdData()
        if collectionView?.contentOffset.y ?? 0 <= 10 {
            collectionView?.contentOffset = CGPoint(x: 0, y: -(SCREEN_SAFE_TOP + 56))
        }
        let proPicUrl = ShadhinCore.instance.defaults.userProPicUrl
        self.profileButton?.layer.cornerRadius = 14
        self.profileButton?.clipsToBounds = true
        if !proPicUrl.isEmpty, proPicUrl.contains("http"),let url = URL(string: proPicUrl.safeUrl()){
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result{
                case .success(let img):
                    self.profileButton?.setImage(img.image, for: .normal)
                case .failure(let error):
                    Log.error(error.localizedDescription)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 13.0, *) {
            self.setupInitialAppMode()
            let isLight = ShadhinCore.instance.defaults.isLighTheam
            overrideUserInterfaceStyle = isLight ? .light : .dark
        }
    }
    
    private func syncShadhinMusicViewIfNeeded() {
        guard let collectionView = collectionView else { return }
        for cell in collectionView.visibleCells {
            findAndSyncMusicView(in: cell)
        }

        findAndSyncMusicView(in: self.view)
    }

    private func findAndSyncMusicView(in view: UIView) {
        if let musicView = view as? ShadhinMusicView {
            musicView.syncAudioItemsOnReturn()
            return
        }
        for subview in view.subviews {
            findAndSyncMusicView(in: subview)
        }
    }

    private func setupBackButton() {
        backBtn.removeTarget(nil, action: nil, for: .allEvents)
        backBtn.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        backBtn.isUserInteractionEnabled = true
        view.bringSubviewToFront(backBtn)
    }
    
    @objc private func handleBackButton() {
        if let tabBar = self.tabBarController {
            if tabBar.presentingViewController != nil {
                tabBar.dismiss(animated: true)
            }
            else if let tabBarNav = tabBar.navigationController {
                tabBarNav.popViewController(animated: true)
            }
        }
        
        if #available(iOS 13.0, *) {
            UIApplication.shared.currentWindow?.overrideUserInterfaceStyle = .light
        }
    }
    
    @objc func performTaskAfterSubscriptionCheck(){
        guard let vc = MainTabBar.shared, appFirstOpen else {return}
        appFirstOpen = false
        PopUpUtil().handelePopUpTasks(vc, self)
    }
    
    func setupInitialAppMode() {
        if ShadhinCore.instance.defaults.isFirstTime {
            if #available(iOS 13.0, *) {
                // Default to light/white mode on first launch
                let window = UIApplication.shared.currentWindow
                ShadhinCore.instance.defaults.isLighTheam = true
                ShadhinCore.instance.defaults.appModeType = .light
                overrideUserInterfaceStyle = .light
                window?.overrideUserInterfaceStyle = .light
            }
            ShadhinCore.instance.defaults.isFirstTime = false
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }

    @objc
    private func onSearchPressed(){
        //      coordinator?.gotoSearch()
        let searchVC = SearchMainV3.instantiateNib()
        self.navigationController?.pushViewController(searchVC, animated: true)
    }

    private func aiPlaylistClearToCellReload() {
        if ShadhinCore.instance.isHomeLoaded {
            self.collectionView?.reloadItems(at: [IndexPath(item: 18, section: 0)])
            self.collectionView?.reloadData()
            ShadhinCore.instance.isHomeLoaded = false
        }
    }

    func setupBottomLoadingIndicator() {
        // Initialize the activity indicator
        activityIndicator = UIActivityIndicatorView()
        // Set the position at the bottom of the view controller
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        // Center the activity indicator horizontally
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        stopLoading()
    }

    private func createTheAttributeMenu(title: String,
                                        items: [ProfileMenu],
                                        handler: @escaping (ProfileMenu) -> Void) -> UIMenu {
        let actions = items.map { item in
            UIAction(title: item.title, image: item.icon) { _ in
                handler(item)
            }
        }
        return UIMenu(title: title, children: actions)
    }

    private func gotoProVC() {
        let proVC = SubscriptionVCv3.instantiateNib()
        let navController = UINavigationController(rootViewController: proVC)
        navController.modalPresentationStyle = .fullScreen
        navController.navigationItem.hidesBackButton = true
        navController.setNavigationBarHidden(true, animated: true)
        self.present(navController, animated: true, completion: nil)
    }

    private func goToSettingsVC() {
        self.navigationController?.pushViewController(SettingsV3VC.instantiateNib(), animated: true)
    }

    private func goToHelpVC() {
        let vc = SettingDetailsVC.instantiateNib()
        vc.settingType = .helpCenter
        self.navigationController?.pushViewController(vc, animated: true)
    }

    private func moreButtonActionMenu() {
        guard #available(iOS 14.0, *) else { return }
        self.profileButton?.showsMenuAsPrimaryAction = true
        let items = ProfileMenu.allCases
        self.profileButton?.menu = createTheAttributeMenu(title: "", items: items) { selected in
            switch selected {
            case .settings:
                self.goToSettingsVC()
            case .shadhinPro:
                self.gotoProVC()
            case .helpSupport:
                self.goToHelpVC()
            case .inviteFriends:
                self.shareAppLink()
            }
        }
    }

    // Function to start animating the activity indicator
    func startLoading() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }

    // Function to stop animating the activity indicator
    func stopLoading() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}

//MARK: view setup
extension HomeVCv3{
    func viewSetup(){
        adapter = HomeAdapter(delegate: self)
        collectionView?.register(Billboard.nib, forCellWithReuseIdentifier: Billboard.identifier)
        collectionView?.register(TwoRowSqrWithDescLeft.nib, forCellWithReuseIdentifier: TwoRowSqrWithDescLeft.identifier)
        collectionView?.register(SingleItemWithSeeAll.nib, forCellWithReuseIdentifier: SingleItemWithSeeAll.identifier)
        collectionView?.register(CircularWithFavBtn.nib, forCellWithReuseIdentifier: CircularWithFavBtn.identifier)
        collectionView?.register(CircularWithDescBelow.nib, forCellWithReuseIdentifier: CircularWithDescBelow.identifier)
        collectionView?.register(PopularPlaylistCell.nib, forCellWithReuseIdentifier: PopularPlaylistCell.identifier)
        collectionView?.register(TwoRowSqrWithDescBelow.nib, forCellWithReuseIdentifier: TwoRowSqrWithDescBelow.identifier)
        collectionView?.register(TwoRowSqr.nib, forCellWithReuseIdentifier: TwoRowSqr.identifier)
        collectionView?.register(PatchDescTopWithSqrDescBelow.nib, forCellWithReuseIdentifier: PatchDescTopWithSqrDescBelow.identifier)
        collectionView?.register(SqrPagerWithDescBelow.nib, forCellWithReuseIdentifier: SqrPagerWithDescBelow.identifier)
        collectionView?.register(SqrWithDescBelow.nib, forCellWithReuseIdentifier: SqrWithDescBelow.identifier)
        collectionView?.register(TrendyPopCell.nib, forCellWithReuseIdentifier: TrendyPopCell.identifier)
        collectionView?.register(RecPagerWithDescInside.nib, forCellWithReuseIdentifier: RecPagerWithDescInside.identifier)
        collectionView?.register(TwoRowRecDescBelow.nib, forCellWithReuseIdentifier: TwoRowRecDescBelow.identifier)
        collectionView?.register(RadioV3Cell.nib, forCellWithReuseIdentifier: RadioV3Cell.identifier)
        collectionView?.register(PodcastsCell.nib, forCellWithReuseIdentifier: PodcastsCell.identifier)
        collectionView?.register(Teaser.nib, forCellWithReuseIdentifier: Teaser.identifier)
        collectionView?.register(PatchDescTopWithRecPortDescBelow.nib, forCellWithReuseIdentifier: PatchDescTopWithRecPortDescBelow.identifier)
        collectionView?.register(TomakeChaiCell.nib, forCellWithReuseIdentifier: TomakeChaiCell.identifier)
        collectionView?.register(NativeAdLargeCell.nib, forCellWithReuseIdentifier: NativeAdLargeCell.identifier)
        //for recent played
        collectionView?.register(RecentlyPlayerCell.nib, forCellWithReuseIdentifier: RecentlyPlayerCell.identifier)
        //for Download
        collectionView?.register(DownloadsHomeCell.nib, forCellWithReuseIdentifier: DownloadsHomeCell.identifier)
        //for stream and win
        collectionView?.register(StreamNwinCollectionCell.nib, forCellWithReuseIdentifier: StreamNwinCollectionCell.identifier)
        //for rewind strory cell
        collectionView?.register(SquareImageCell.nib, forCellWithReuseIdentifier: SquareImageCell.identifier)
        collectionView?.register(SingleImageItemCell.nib, forCellWithReuseIdentifier: SingleImageItemCell.identifier)
        collectionView?.register(BookHomeCell.nib, forCellWithReuseIdentifier: BookHomeCell.identifier)
        collectionView? .register(ContinueListeningBookCell.nib, forCellWithReuseIdentifier: ContinueListeningBookCell.identifier)
        collectionView?.register(AudiobookCategoriesCell.nib, forCellWithReuseIdentifier: AudiobookCategoriesCell.identifier)
        collectionView?.register(RecommendedBooksCell.nib, forCellWithReuseIdentifier: RecommendedBooksCell.identifier)
        collectionView?.register(VmaxCommonAdCell.nib, forCellWithReuseIdentifier: VmaxCommonAdCell.identifier)
        collectionView?.register(UICollectionViewCell.self,forCellWithReuseIdentifier: "EmptyCell")
        // cell for AI playList
        collectionView?.register(AIPlayList.nib, forCellWithReuseIdentifier: AIPlayList.identifier)
        // cell for AI playList
        collectionView?.register(AIPlaylistItemCell.nib, forCellWithReuseIdentifier: AIPlaylistItemCell.identifier)
        collectionView?.dataSource = adapter
        collectionView?.delegate = adapter
        refreshControll = UIRefreshControl()
        refreshControll?.tintColor = .appTintColor
        refreshControll?.attributedTitle = NSAttributedString(string: "Refresh")
        refreshControll?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView?.alwaysBounceVertical = true
        collectionView?.refreshControl = refreshControll
        if #available(iOS 11.0, *) {
            collectionView?.contentInsetAdjustmentBehavior = .never
        }
        let topInset = SCREEN_SAFE_TOP + 56
        collectionView?.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        loadMorePatchs()
    }

    @objc private func refresh() {
        Log.info("Refresh triggered")
        adapter.isCheckingAIPlaylistExists = true
        adapter.reset()
        collectionView?.reloadData()
        vm.reset()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }

            self.refreshControll?.endRefreshing()
            let currentAppBarY = self.appBarView.frame.origin.y
            let currentTopOffset = SCREEN_SAFE_TOP + 56 + currentAppBarY
            let safeTopInset = max(0, currentTopOffset)
            self.collectionView?.contentInset.top = safeTopInset

            if #available(iOS 13.0, *) {
                self.collectionView?.verticalScrollIndicatorInsets.top = safeTopInset
            } else {
                self.collectionView?.scrollIndicatorInsets.top = safeTopInset
            }

            Log.info("Refresh completed & insets restored")
        }
    }

    func refreshHome(){
        adapter.isCheckingAIPlaylistExists = true
        Log.info("Refresh ")
        refreshControll?.beginRefreshing()
        self.adapter.reset()
        self.collectionView?.reloadData()
        self.vm.reset()
        self.refreshControll?.endRefreshing()
    }

}

extension HomeVCv3 : HomeAdapterProtocol {

    func gotoPurchaseVC() {
        SubscriptionPopUpVC.show(self)
    }

    func viewMackToastShow(message: String) {
        self.view.makeToast(message)
    }

    func gotoLeaderBoard(method: CampaignWrapper, campaignType: String) {
        self.coordinator?.gotoLeaderBoard(data: method, campaignType: campaignType)
    }

    var homeVM: HomeVM? {
        get {
            vm
        }
        set {

        }
    }

    var parentCollectionView: UICollectionView? {
        get {
            self.collectionView
        }
        set {

        }
    }

    var homeAdapter: HomeAdapter? {
        get {
            adapter
        }
        set {
            adapter = newValue
        }
    }

    func reloadView(indexPath: IndexPath) {
        collectionView?.reloadItems(at: [indexPath])
    }

    func onSubscription() {
        self.goSubscriptionTypeVC()
    }

    func onRewind(rewindData: [TopStreammingElementModel]) {
        coordinator?.gotoRewind(rewindData: rewindData)
    }

    func seeAllClick(patch: HomeV3Patch) {
        coordinator?.gotoSeeAll(patch: patch)
    }

    func onItemClicked(patch: HomeV3Patch, content: CommonContentProtocol) {
        coordinator?.routeToContent(content: content, patch)
    }

    func navigateToAIGeneratedContent(content: AIPlaylistResponseModel?, imageUrl: String = "", playlistName: String = "", playlistId: String = "") {
        coordinator?.routeToAIPlayList(content: content, imageUrl: imageUrl, playlistName: playlistName, playlistId: playlistId)
    }

    func loadMorePatchs() {
        vm.loadHomeContent()
    }

    func getNavController() -> UINavigationController {
        self.navigationController!
    }

    func onScroll(y: Double) {
        if appBarView.frame.origin.y >= -(SCREEN_SAFE_TOP + 56),
           appBarView.frame.origin.y <= 0 {
            appBarView.frame.origin.y = appBarView.frame.origin.y - y
        }
        if appBarView.frame.origin.y < -(SCREEN_SAFE_TOP + 56){
            appBarView.frame.origin.y = -(SCREEN_SAFE_TOP + 56)
        }
        if  appBarView.frame.origin.y > 0{
            appBarView.frame.origin.y = 0
        }
    }
}

extension HomeVCv3 : HomeVMProtocol{
    func handleV3(patches: [HomeV3Patch]) {
        adapter.addPatchesV3(array: patches)
        self.collectionView?.reloadData()
    }

    func streamNwin(data: CampaignResponseNew) {
        adapter.addStreamNwin(stream: data)
    }

    func concertData(data: ConcertEventObj) {
        adapter.addTicket(ticket: data)
    }

    func loading(isLoading: Bool, page: Int) {
        if page != 1{
            if isLoading{
                startLoading()
            }else{
                stopLoading()
            }
        }
    }

    func handleAIPlaylists(aiPlaylists: [NewContent]?) {
        adapter.aiPlaylists = aiPlaylists
        adapter.isCheckingAIPlaylistExists = false
        let aiIndexPath = indexPathForSpecificCellType(cellType: AIPlaylistItemCell.self)
        if let aiIndexPath {
            if let cell = collectionView?.cellForItem(at: aiIndexPath) as? AIPlaylistItemCell {
                if let aiPlay = adapter.aiPlaylists, !aiPlay.isEmpty {
                    cell.aiPlaylists = aiPlay
                    cell.collectionView.reloadData()
                    //  cell.collectionView.scrollToItem(at: .init(index: 0), at: .left, animated: true)

                } else {
                    cell.collectionView.reloadData()
                }
            }
        } else {
            collectionView?.reloadData()
        }
    }

    func indexPathForSpecificCellType<T: UICollectionViewCell>(cellType: T.Type) -> IndexPath? {
        if let collectionView {
            for cell in collectionView.visibleCells {
                if let specificCell = cell as? T {
                    if let indexPath = collectionView.indexPath(for: specificCell) {
                        return indexPath
                    }
                }
            }
        }
        return nil
    }
}

extension HomeVCv3{
    func particapetClick(payment : PaymentMethod){
        if ShadhinCore.instance.isUserPro{
            if let telco = PaymentGetwayType(rawValue: payment.name.uppercased()){
                if telco == .ROBI{
                    ShadhinCore.instance.api.showAlert(title: "Stream and Win", msg: "This campaign only for Robi and Airtel subscribed users")
                }else{
                    ShadhinCore.instance.api.showAlert(title: "Stream and Win", msg: "This campaign only for \(telco.rawValue) subscribed users")
                }

            }

        } else if ShadhinDefaults().userMsisdn.count > 0 {
            if let telco = PaymentGetwayType(rawValue: payment.name.uppercased()){
                if telco == .ROBI && ShadhinCore.instance.isRobi() || telco == .GP && ShadhinCore.instance.isGP() || telco == .BL && ShadhinCore.instance.isBanglalink(){
                    //subscription pop up show for telco
                    if telco == .ROBI{
                        self.goSubscriptionTypeVC(false,"robi_airtel")
                    }else if telco == .GP{
                        self.goSubscriptionTypeVC(false,"gp")
                    }else if telco == .BL{
                        self.goSubscriptionTypeVC(false,"banglalink")
                    }

                }else if telco == .Bkash{
                    //subscription pop up show bkash
                    self.goSubscriptionTypeVC(false,"bkash")
                }else if telco == .SSL{
                    //subscription pop up ssl
                    self.goSubscriptionTypeVC(false,"ssl")
                }else if telco == .Nagad{
                    //subscription pop up show nagad
                    //self.goSubscriptionTypeVC(false,"gp")
                }else{
                    ShadhinCore.instance.api.showAlert(title: "Stream and Win", msg: "This campaign only for \(telco.rawValue) subscribed users")
                }
            }
        } else if ShadhinDefaults().userMsisdn.count == 0 {
            //number input pop up show
            if let telco = PaymentGetwayType(rawValue: payment.name.uppercased()){
                if telco == .ROBI || telco == .GP  || telco == .BL {
                    //show number input field
                    //                    LinkMsisdnVC.show("Phone number is required to proceed with BD subscriptions...")
                }
            }
        }
    }
}


