//
//  HeaderViewDownload.swift
//  CollapsableCollectionView
//
//  Created by Admin on 30/6/22.
//

import UIKit
struct DownloadChipModel{
    var title : String
    var type : DownloadChipType
}
enum DownloadChipType : String{
    case Album = "R"
    case Artist = "A"
    case Songs = "S"
    case Playlist = "P"
    case PodCast = "PD"
    case History = "H"
    case None = "None"
}

protocol JRHeaderDelegate : NSObjectProtocol{
    func onSearchText(text : String)
    func onSearchCancel()
}

class HeaderViewDownload: UIView {
    weak var delegate : JRHeaderDelegate?
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var selectAllButton: UIButton!
    @IBOutlet weak var gridListButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectMarkButton: UIButton!
    @IBOutlet weak var selectTitle: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var allDownloadSwitch: UISwitch!
    @IBOutlet weak var downloadView: UIView!
    @IBOutlet weak var selectAllView: UIStackView!
    
    private let allData : [DownloadChipModel] = [
        .init(title: ^String.Downloads.songs, type: .Songs),
        .init(title: ^String.Downloads.album, type: .Album),
        .init(title: ^String.Downloads.artist, type: .Artist),
        .init(title: ^String.Downloads.playlist, type: .Playlist),
        .init(title: ^String.Downloads.audioPodcast, type: .PodCast),
        .init(title: ^String.Downloads.history, type: .History),
    ]
    private var showingData : [DownloadChipModel] = []
    private var crossItem = DownloadChipModel(title: "X", type: .None)
    var axis : NSLayoutConstraint.Axis = .horizontal  {
        didSet{
            if #available(iOS 13, *){
                gridListButton.setImage(self.axis == .horizontal ? AppImage.grid.uiImage : AppImage.list.uiImage , for: .normal)
            }else{
                gridListButton.setImage(self.axis == .horizontal ? AppImage.grid12.uiImage : AppImage.list12.uiImage , for: .normal)
            }
        }
        
    }
    var isSelectMood : Bool = false {
        didSet{
            if self.isSelectMood{
                if #available(iOS 13 , *){
                    gridListButton.setImage(AppImage.trash.uiImage, for: .normal)
                }else{
                    gridListButton.setImage(AppImage.trash12.uiImage, for: .normal)
                }
                
            }else{
                if #available(iOS 13, *){
                    gridListButton.setImage(self.axis == .horizontal ? AppImage.grid.uiImage : AppImage.list.uiImage , for: .normal)
                }else{
                    gridListButton.setImage(self.axis == .horizontal ? AppImage.grid12.uiImage : AppImage.list12.uiImage , for: .normal)
                }
            }
        }
    }
    
    var onFilterPressed : (DownloadChipType)-> Void = {_ in}
    var  onDownloadAllPressed : (_ isOn : Bool)-> Void = {_ in}
   
    static var height : CGFloat{
        return 250
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    private func commonInit(){
        Bundle.ShadhinMusicSdk.loadNibNamed("HeaderViewDownload", owner: self, options: [:])
        contentView.frame = self.bounds
        contentView.autoresizingMask  = [.flexibleHeight,.flexibleWidth]
        addSubview(contentView)
        clipsToBounds =  true 
        initCollectionView()
        
        if #available(iOS 13, *){
            selectMarkButton.setImage(AppImage.checkSqure.uiImage(tintColor: .appTintColor), for: .selected)
            selectMarkButton.setImage(AppImage.uncheckSqure.uiImage, for: .normal)
        }else{
            selectMarkButton.setImage(AppImage.checkSqure12.uiImage, for: .selected)
            selectMarkButton.setImage(AppImage.uncheckSqure12.uiImage, for: .normal)
        }
        
        searchButton.setImage(AppImage.search.uiImage, for: .normal)
        
        allDownloadSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        subtitleLabel.textColor = UIColor.secondaryLabelColor()
    }
    
    private func initCollectionView(){
        showingData = allData
        collectionView.register(ChipCell.nib(), forCellWithReuseIdentifier: ChipCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 8
            layout.minimumInteritemSpacing = 8
        }
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        if #available(iOS 13.0, *){
            searchBar.searchTextField.backgroundColor = .systemBackground
        }else if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField{
            let backgroundView = UIView(frame: textFieldInsideSearchBar.bounds)
            backgroundView.backgroundColor = .white
            backgroundView.layer.cornerRadius = 10
            backgroundView.clipsToBounds = true
            textFieldInsideSearchBar.insertSubview(backgroundView, at: 1)
        }
        searchBar.delegate = self
        
    }
    
    func setData(with title : String, subtitle : String){
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
    }
    
    @IBAction func onGridButtonPressed(_ sender: Any) {
    }
    
    @IBAction func onSelectAllPressed(_ sender: Any) {
        
    }
    
    @IBAction func onSearchButtonPressed(_ sender: Any) {
        searchBar.isHidden  = !searchBar.isHidden
        if searchBar.isHidden{
            searchButton.setImage(AppImage.search12.uiImage, for: .normal)
            searchBar.text = nil
            guard let delegate = delegate else{return}
            delegate.onSearchText(text: "")
        }else{
            searchButton.setImage(AppImage.closeDownload.uiImage, for: .normal)
            searchBar.becomeFirstResponder()
        }
    }
    @IBAction func onDownloadAllSwitchChange(_ sender: Any) {
        onDownloadAllPressed(allDownloadSwitch.isOn)
    }
}

extension HeaderViewDownload : UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showingData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChipCell.identifier, for: indexPath) as? ChipCell else {
            fatalError("chip cell not load")
        }
        
        cell.setData(with: showingData[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let obj = showingData[indexPath.row]
        if obj.type == .None{
            return CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height)
        }
        
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.text = obj.title
        lbl.sizeToFit()
        
        let w = lbl.bounds.width + collectionView.bounds.height
        
        return  CGSize(width: w, height: collectionView.bounds.height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if showingData.count == 2{
            if indexPath.row == 0 {
                showingData = allData
                collectionView.reloadData()
                //fire reset data with all songs
                onFilterPressed(.None)
                
            }
            return
        }
        let obj = showingData[indexPath.row]
        setSetected(obj: obj)
    }
    
    func setSetected(obj: DownloadChipModel){
        showingData = showingData.filter({ ff in
            ff.type == obj.type
        })
        showingData.insert(crossItem, at: 0)
        collectionView.reloadData()
        collectionView.selectItem(at: IndexPath(row : 1,section : 0), animated: true, scrollPosition: .left)
        onFilterPressed(obj.type)
    }
}

extension HeaderViewDownload : UISearchBarDelegate{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard let delegate = delegate else{return}
        delegate.onSearchCancel()
    }
    @objc
    func searchBarFocus(){
        searchBar.becomeFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let delegate = delegate else{return}
        delegate.onSearchText(text: searchText)
        
    }
}

