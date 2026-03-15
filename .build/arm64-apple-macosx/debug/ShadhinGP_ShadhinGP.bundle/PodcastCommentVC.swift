//
//  PodcastCommentVC.swift
//  Shadhin
//
//  Created by Rezwan on 16/9/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class PodcastCommentVC: UIViewController {
    
    @IBOutlet weak var handleAreaComment: UIView!
    @IBOutlet weak var stateImg: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
    var willHideAreaComment = false
    var headerHeightConstant : CGFloat = 42
    
    var episodeID = 0
    var contentType = "PD"
    var currentCommentPage = 0
    var userComments : CommentsObj? = nil
    var loadMoreComments : LoadMoreActivityIndicator?
    
    var pendingRequestWorkItem0: DispatchWorkItem?
    var pendingRequestWorkItem1: DispatchWorkItem?
    var pendingRequestWorkItem2: DispatchWorkItem?
    
    var cellHeightsDictionary: [IndexPath: CGFloat] = [:]
    
    
    var isFromPlayer = false
    var frame: CGRect = .zero
    var tapGestureRecognizer: UITapGestureRecognizer!
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PodcastHeaderCell.nib, forCellReuseIdentifier: PodcastHeaderCell.identifier)
        tableView.register(CommentCell.nib, forCellReuseIdentifier: CommentCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        if isFromPlayer{
            self.view.frame = frame
            self.view.clipsToBounds = true
            self.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            
            self.handleAreaComment.addGestureRecognizer(tapGestureRecognizer)
            self.view.addGestureRecognizer(panGestureRecognizer)
        }
        handleAreaComment.isHidden = willHideAreaComment
        headerHeightConstraint.constant = headerHeightConstant
        getComments()
    }
}


extension PodcastCommentVC : UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (userComments != nil ? (1 + userComments!.data.count) : 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: PodcastHeaderCell.identifier, for: indexPath) as! PodcastHeaderCell
            cell.totalCommentsLabel.text = "\(userComments?.totalData ?? 0)"
            cell.commentRefreshBtn.addTarget(self, action: #selector(reloadComments), for: .touchUpInside)
            cell.addCommentView.setClickListener {
                self.addComment()
            }
            return cell
        default:
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as! CommentCell
            if #available(iOS 13.0, *) {
                cell.contentView.backgroundColor = .systemBackground
            }else{
                cell.contentView.backgroundColor = .white
            }
            if let comment = userComments?.data[indexPath.row - 1]{
                cell.userImg.kf.indicatorType = .activity
                cell.userImg.kf.setImage(with: URL(string: comment.userPic.safeUrl()),placeholder: UIImage(named: "ic_user_1",in:Bundle.ShadhinMusicSdk,compatibleWith: nil))
                //cell.userName.text = comment.userName
                if comment.adminUserType.isEmpty{
                    if comment.isSubscriber ?? false{
                        let imageAttachment = NSTextAttachment()
                        imageAttachment.image  = UIImage(resource: ImageResource(name: "ic_verified_user", bundle:Bundle.ShadhinMusicSdk))
                        let imageOffsetY: CGFloat = -1.0
                        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
                        let attachmentString = NSAttributedString(attachment: imageAttachment)
                        let completeText = NSMutableAttributedString(string: "")
                        let textAfterIcon = NSAttributedString(string: "\(comment.userName) ")
                        completeText.append(textAfterIcon)
                        completeText.append(attachmentString)
                        cell.userName.attributedText = completeText
                    }else{
                        cell.userName.text = comment.userName
                    }
                }else{
                    let imageAttachment = NSTextAttachment()
                    imageAttachment.image = UIImage(named:"verified_2",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                    let imageOffsetY: CGFloat = -1.0
                    imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
                    let attachmentString = NSAttributedString(attachment: imageAttachment)
                    let completeText = NSMutableAttributedString(string: "")
                    let textAfterIcon = NSAttributedString(string: "\(comment.userName) ")
                    completeText.append(textAfterIcon)
                    completeText.append(attachmentString)
                    cell.userName.attributedText = completeText
                }
                cell.comment.text = comment.message
                cell.favCount.text = "\(comment.totalCommentFavorite)"
                if comment.totalReply > 0{
                    cell.replyCountBtn.isHidden = false
                    cell.replyCountBtn.setTitle("\(comment.totalReply) replies", for: .normal)
                    cell.replyCountBtn.setClickListener {
                        self.viewReply(comment, indexPath)
                    }
                }else{
                    cell.replyCountBtn.isHidden = true
                }
                cell.replyBtn.setClickListener {
                    self.viewReply(comment, indexPath)
                }
                if comment.commentFavorite{
                    cell.favImg.image = UIImage(named: "ic_mymusic_favorite",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                }else{
                    cell.favImg.image = UIImage(named: "ic_favorite_border",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                }
                if comment.commentLike{
                    cell.likeBtn.setTitle("You liked", for: .normal)
                    cell.likeBtn.setTitleColor(UIColor.red.withAlphaComponent(0.7), for: .normal)
                }else{
                    cell.likeBtn.setTitle("Like", for: .normal)
                    if #available(iOS 13.0, *) {
                        cell.likeBtn.setTitleColor(.secondaryLabel, for: .normal)
                    } else {
                        cell.likeBtn.setTitleColor(.gray, for: .normal)
                    }
                }
                
                let dateFormatter = DateFormatter()
                //dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                //dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                if let date =  dateFormatter.date(from: comment.createDate){
                    cell.timeAgo.text = timeAgoSince(date)
                }else{
                    cell.timeAgo.text = " "
                }
                
                cell.podcastComment = self
                cell.commentIndex = indexPath
                cell.initComment()
                
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0 :
            return CommentHeaderCell.height
        default :
            return CommentCell.height
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        loadMoreComments?.start {
            self.getComments({self.loadMoreComments?.stop()})
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cellHeightsDictionary[indexPath] = cell.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height =  self.cellHeightsDictionary[indexPath] {
            return height
        }
        return UITableView.automaticDimension
    }
    
    func viewReply(_ comment : CommentsObj.Comment, _ index : IndexPath){
        if ShadhinCore.instance.defaults.userName.isEmpty{
            AlertSlideUp.show(
               // image:#imageLiteral(resourceName: "user icon 1.pdf"),
                image:UIImage(resource: ImageResource(name: "user icon 1", bundle: Bundle.ShadhinMusicSdk)),
                tileString: "Name Required",
                msgString: "Your name seems to empty please update your name in profile to enable commenting feature",
                positiveString: nil,
                negativeString: "Close")
            return
        }
        
        let storyBoard = UIStoryboard(name: "PodCast", bundle:Bundle.ShadhinMusicSdk)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        vc.comment = comment
        vc.indexOfComment = index
        vc.podcastComment = self
        vc.podcastShowCode = String(contentType.suffix(contentType.count - 2))
        vc.podcastType = String(contentType.prefix(2))
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(vc, animated: true, completion: nil)
        }
    }
    
    func addComment(){
        
        let storyBoard = UIStoryboard(name: "PodCast", bundle:Bundle.ShadhinMusicSdk)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        vc.contentId = episodeID
        vc.podcastComment = self
        vc.podcastShowCode = String(contentType.suffix(contentType.count - 2))
        vc.podcastType = String(contentType.prefix(2))
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(vc, animated: true, completion: nil)
        }
        
    }
    
    
}


extension PodcastCommentVC{
    
    func getComments(_ completion: (() -> Void)? = nil) {
        pendingRequestWorkItem0?.cancel()
        let requestWorkItem = DispatchWorkItem(block: {self.getCommentsFromServer(completion)})
        pendingRequestWorkItem0 = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: requestWorkItem)
    }
    
    func getCommentsFromServer(_ completion : (() -> Void)? = nil){
        currentCommentPage += 1
        ShadhinCore.instance.api.getCommentsBy(
            String(contentType.prefix(2)),
            episodeID,
            currentCommentPage,
            String(contentType.suffix(contentType.count - 2))) {
                _data in
                guard let data = _data else {return}
                if data.data.count > 0{
                    self.updateComments(data: data)
                }else{
                    self.currentCommentPage -= 1
                }
                LoadingIndicator.stopAnimation()
                completion?()
            }
    }
    
    func updateComments(data : CommentsObj){
        if userComments == nil{
            userComments = data
            
            if loadMoreComments == nil{
                loadMoreComments = LoadMoreActivityIndicator(scrollView: tableView, spacingFromLastCell: -32, spacingFromLastCellWhenLoadMoreActionStart: 8)
            }
            loadMoreComments?.stop()
        }else{
            let comments = data.data
            userComments?.data.append(contentsOf: comments)
        }
        tableView.reloadData()
    }
    
    @objc func reloadComments(){
        currentCommentPage = 0
        userComments = nil
        pendingRequestWorkItem1?.cancel()
        pendingRequestWorkItem2?.cancel()
        tableView.reloadData()
        getComments()
        LoadingIndicator.startAnimation(true)
    }
    
    func updateFavouriteComment(_ index : IndexPath, _ completion : (() -> Void)? = nil){

        pendingRequestWorkItem1?.cancel()
        let requestWorkItem = DispatchWorkItem(block: {self.updateFavouriteCommentServer(index, completion)})
        pendingRequestWorkItem1 = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: requestWorkItem)
    }
    
    func updateLikeComment(_ index : IndexPath,  _ completion : (() -> Void)? = nil){
        pendingRequestWorkItem2?.cancel()
        let requestWorkItem = DispatchWorkItem(block: {self.updateLikeCommentServer(index, completion)})
        pendingRequestWorkItem2 = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: requestWorkItem)
    }
    
    private func updateFavouriteCommentServer(_ index : IndexPath, _ completion : (() -> Void)? = nil){
        guard let commentID = userComments?.data[index.row - 1].commentID,
              let commentBool = userComments?.data[index.row - 1].commentFavorite else{
            return
        }
        
        ShadhinCore.instance.api.toggleFavoriteComment(
            String(contentType.prefix(2)),
            commentID) { success in
                if success{
                    self.userComments?.data[index.row - 1].commentFavorite = !commentBool
                    if (self.userComments?.data[index.row - 1].commentFavorite)!{
                        self.userComments?.data[index.row - 1].totalCommentFavorite += 1
                    }else{
                        self.userComments?.data[index.row - 1].totalCommentFavorite -= 1
                    }
                    self.tableView.reloadRows(at: [index], with: .automatic)
                    completion?()
                }
            }
    }
    
    private func updateLikeCommentServer(_ index : IndexPath,  _ completion : (() -> Void)? = nil){
        guard let commentID = userComments?.data[index.row - 1].commentID,
              let likeBool = userComments?.data[index.row - 1].commentLike, !likeBool else{
            return
        }
        
        ShadhinCore.instance.api.likeComment(
            String(contentType.prefix(2)),
            commentID) { success in
                if success{
                    self.userComments?.data[index.row - 1].commentLike = !likeBool
                    self.tableView.reloadRows(at: [index], with: .automatic)
                    completion?()
                }
            }
    }
    
}
