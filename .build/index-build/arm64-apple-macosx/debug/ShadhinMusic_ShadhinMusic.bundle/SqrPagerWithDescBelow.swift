//
//  WeeklyTopCell.swift
//  Shadhin
//
//  Created by Joy on 23/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class SqrPagerWithDescBelow: UICollectionViewCell {

    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var height : CGFloat{
        let w = SCREEN_WIDTH - 32
        return w + 40 + 28 + 60 + 8
    }
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var playButton: UIButton!  {
        didSet {
            let image = ShadhinCore.instance.defaults.isLighTheam ? UIImage(named: "playBlack",in: Bundle.ShadhinMusicSdk,compatibleWith: nil) : UIImage(named: "playWhite",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            self.playButton.setImage(image, for: .normal)
        }
    }
    @IBOutlet weak var titleLabel: FadeLabel!
    @IBOutlet weak var subtitleLabel: FadeLabel!
    @IBOutlet weak var playCountLabel: FadeLabel!
    
    @IBOutlet weak var lastImageView: UIImageView!
    @IBOutlet weak var midImageView: UIImageView!
    @IBOutlet weak var imageIV: FadeImageView!
    
    @IBOutlet weak var itemNumberLabel: UILabel!
    @IBOutlet weak var top10Label: UILabel!
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var pagerView: FSPagerView!
    
    private var dataSource : [CommonContentProtocol] = []
    var onItemClick : (CommonContentProtocol)->Void = {_ in}
    var seeAllClick : ()-> Void = { }
    
    override func prepareForReuse() {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //leftButton.isEnabled = false
        titleLabel.textColor = .textColor
        subtitleLabel.textColor = .textColorSecoundery
        playCountLabel.textColor = .textColorSecoundery
        
        //self.addGestureRecognizer(tap)
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pagerView.scrollDirection = .horizontal
        pagerView.transformer = FSPagerViewTransformer(type: .crossFading)
        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.isInfinite = true
        pagerView.cornerRadius = 16
        
    }
    func bind(with data : [CommonContentProtocol]){
        self.dataSource = data
        if dataSource.isEmpty {
            return
        }
        updateCell(index: 0)
        pagerView.reloadData()
        if self.dataSource.count == 3{
            midImageView.kf.setImage(with: URL(string: dataSource[1].image?.image300 ?? ""))
            midImageView.kf.setImage(with: URL(string: dataSource[2].image?.image300 ?? ""))
        }
        
    }
    @IBAction func onSeeAllPreessed(_ sender: Any) {
        seeAllClick()
    }
    
    @IBAction func onPlayPressed(_ sender: Any) {
        let obj = dataSource[pagerView.currentIndex]
        onItemClick(obj)
    }
    @IBAction func onRightButtonPressed(_ sender: Any) {
        let currentIndex = pagerView.currentIndex + 1
        if currentIndex >= dataSource.count {
            return
        }
        pagerView.selectItem(at: currentIndex, animated: true)
        pagerView.scrollToItem(at: currentIndex, animated: true)
        updateCell(index: currentIndex)
    }
    @IBAction func onLeftButtonPressed(_ sender: Any) {
        let currentIndex = pagerView.currentIndex - 1
        if currentIndex < 0 {
            return
        }
        pagerView.selectItem(at: currentIndex, animated: true)
        pagerView.scrollToItem(at: currentIndex, animated: true)
        updateCell(index: currentIndex)
    }
}
extension SqrPagerWithDescBelow : FSPagerViewDataSource,FSPagerViewDelegate{
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return dataSource.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        let obj = dataSource[index]
        cell.imageView?.kf.setImage(with: URL(string: obj.image?.image300 ?? ""))
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 16
        
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        let obj = dataSource[index]
        onItemClick(obj)
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        updateCell(index: targetIndex)
    }
    
    func updateCell(index : Int){
        itemNumberLabel.text = "#\(index + 1)"
        rightButton.isEnabled = index == dataSource.count - 1 ? false : true
        leftButton.isEnabled = true
        let obj = dataSource[index]
        imageIV.kf.setImage(with: URL(string: obj.image?.image300 ?? ""))
        titleLabel.text = obj.title
        subtitleLabel.text = obj.artist
        playCountLabel.text = "\(obj.playCount ?? 0)"
        
        var mid = index + 1
        
        if mid == dataSource.count{
            mid = 0
        }
        var last = mid + 1
        if last == dataSource.count{
            last = 0
        }
        midImageView.kf.setImage(with: URL(string: dataSource[mid].image?.image300 ?? ""))
        lastImageView.kf.setImage(with: URL(string: dataSource[last].image?.image300 ?? ""))
        
    }
}
