//
//  CommentVC.swift
//  Shadhin
//
//  Created by Rezwan on 6/11/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class CommentVC: UIViewController {
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var tableview: UITableView!
    
    var comment : CommentsObj.Comment?
    var indexOfComment : IndexPath?
    var podcastVC : PodcastVC?
    var podcastLive : PodcastYoutubeVC? = nil
    var podcastLive1 : VideoPodcastVC? = nil
    var podcastComment : PodcastCommentVC?
    var previousInsets : UIEdgeInsets?
    var replies : RepliesObj?
    var contentId = 0
    var podcastShowCode = "BC"
    var podcastType = "PD"
    
    var safeHeight = CGFloat.zero
    var shouldReloadComments = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.register(CommentCell.nib, forCellReuseIdentifier: CommentCell.identifier)
        tableview.dataSource = self
        tableview.delegate = self
        tableview.keyboardDismissMode = .onDrag
        
        setViewColor()
        LoadingIndicator.initLoadingIndicator(view: self.view)
        LoadingIndicator.stopAnimation()
        let height = UIScreen.main.bounds.height
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        safeHeight = height - topPadding - bottomPadding
        updateTableContentInset()
        if comment != nil && comment!.totalReply > 0{
            getReplies()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardDidHideNotification, object: nil)
       
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, keyboardSize.height > 0 {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom ?? 0
            updateTableContentInset(keyboardSize.height - bottomPadding)
            
        }
        
    }
    
    @objc func keyboardWillHide(){
        if let previousInsets = self.previousInsets{
            self.tableview.contentInset = previousInsets
        }
    }
    
    func setViewColor(){
        if #available(iOS 13.0, *), self.traitCollection.userInterfaceStyle == .dark {
            // User Interface is Dark
            backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        } else {
            // User Interface is Light
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        }
        tableview.reloadData()
    }
    
    @objc func updateTableContentInset(_ size : CGFloat = 0) {
        let numRows = self.tableview.numberOfRows(inSection: 0)
        var contentInsetTop = safeHeight
        //print("contentInsetTop before- \(contentInsetTop) ")
        for i in 0..<numRows {
            let rowRect = self.tableview.rectForRow(at: IndexPath(item: i, section: 0))
            contentInsetTop -= rowRect.size.height
            if contentInsetTop <= 0 {
                contentInsetTop = 0
            }
        }
        if size > 0{
            previousInsets = UIEdgeInsets(top: contentInsetTop,left: 0,bottom: 0,right: 0)
        }
        let top = contentInsetTop - size
        //print("contentInsetTop after- \(contentInsetTop) ")
        self.tableview.contentInset = UIEdgeInsets(top:  top > 0 ? top : 0,left: 0,bottom: 0,right: 0)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        setViewColor()
    }
    
    @objc func close(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        if shouldReloadComments {
            self.podcastVC?.reloadComments()
            self.podcastLive?.reloadComments()
            self.podcastLive1?.reloadComments()
            self.podcastComment?.reloadComments()
        }
    }
    
    func sendComment(msg : String){
        if comment == nil{
            self.addComment(msg)
        }else{
            self.addReply(msg)
        }
    }
    
}

extension CommentVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if comment == nil{
            return 2
        }
        return 1 + 1 + 1 + (replies?.data.count ?? 0 )
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentVCHeaderCell.identifier, for: indexPath) as! CommentVCHeaderCell
            let path = UIBezierPath(roundedRect:cell.bounds,
                                    byRoundingCorners:[.topRight, .topLeft],
                                    cornerRadii: CGSize(width: 12, height:  12))
            
            let maskLayer = CAShapeLayer()
            
            maskLayer.path = path.cgPath
            cell.layer.mask = maskLayer
            if comment != nil{
                cell._title.text = "Add a reply"
            }
            cell.closeBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
            return cell
        }else if (indexPath.row == 1 && comment == nil) || (indexPath.row == 2 && comment != nil) {
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentVCAddCell.identifier, for: indexPath) as! CommentVCAddCell
            cell.commentVC = self
            if comment == nil {
                cell.commentTF.becomeFirstResponder()
                cell.commentTF.text = ""
                cell.commentTF.placeholder = "Add a comment"
            } else {
                cell.commentTF.text = ""
                cell.commentTF.placeholder = "Add a reply"
            }
            return cell
        }else if indexPath.row == 1 && comment != nil{
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as! CommentCell
            if let comment = self.comment{
                if let userPicUrlEncoded = comment.userPic.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed){
                    cell.userImg.kf.setImage(with: URL(string:userPicUrlEncoded ),placeholder: UIImage(named: "ic_user_1",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
                }
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
                    imageAttachment.image = UIImage(named: "verified_2", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
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
                cell.replyCountBtn.isHidden = true
                cell.replyBtn.isHidden = true
                
                if comment.commentFavorite{
                    cell.favImg.image = UIImage(named: "ic_mymusic_favorite")
                }else{
                    cell.favImg.image = UIImage(named: "ic_favorite_border")
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
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                if let date =  dateFormatter.date(from: comment.createDate){
                    cell.timeAgo.text = timeAgoSince(date)
                }else{
                    cell.timeAgo.text = " "
                }
                cell.favView.setClickListener {
                    self.updateCommentFav()
                }
                cell.likeBtn.setClickListener {
                    self.updateCommentLike()
                }
                //cell.podcastVC = self
                //cell.commentIndex = indexPath
                
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as! CommentCell
        let index = indexPath.row - 1 - 1 - (comment != nil ? 1 : 0)
        
        if let reply = replies?.data[index]{
            cell.userImg.kf.indicatorType = .activity
            cell.userImg.kf.setImage(with: URL(string: reply.userPic.safeUrl()),placeholder: UIImage(named: "ic_user_1"))
            //cell.userName.text = reply.userName
            if reply.adminUserType.isEmpty{
                if reply.isSubscriber ?? false{
                    let imageAttachment = NSTextAttachment()
                    imageAttachment.image = #imageLiteral(resourceName: "ic_verified_user.pdf")
                    let imageOffsetY: CGFloat = -1.0
                    imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
                    let attachmentString = NSAttributedString(attachment: imageAttachment)
                    let completeText = NSMutableAttributedString(string: "")
                    let textAfterIcon = NSAttributedString(string: "\(reply.userName) ")
                    completeText.append(textAfterIcon)
                    completeText.append(attachmentString)
                    cell.userName.attributedText = completeText
                }else{
                    cell.userName.text = reply.userName
                }
            }else{
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = UIImage(named:"verified_2")
                let imageOffsetY: CGFloat = -1.0
                imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
                let attachmentString = NSAttributedString(attachment: imageAttachment)
                let completeText = NSMutableAttributedString(string: "")
                let textAfterIcon = NSAttributedString(string: "\(reply.userName) ")
                completeText.append(textAfterIcon)
                completeText.append(attachmentString)
                cell.userName.attributedText = completeText
            }
            cell.comment.text = reply.message
            cell.replyCountBtn.isHidden = true
            cell.replyBtn.isHidden = true
            
            cell.favCount.text = "\(reply.totalReplyFavorite)"
            if reply.replyFavorite{
                cell.favImg.image = UIImage(named: "ic_mymusic_favorite",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            }else{
                cell.favImg.image = UIImage(named: "ic_favorite_border",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            }
            if reply.replyLike{
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
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date =  dateFormatter.date(from: reply.createDate){
                cell.timeAgo.text = timeAgoSince(date)
            }else{
                cell.timeAgo.text = " "
            }
            cell.favView.setClickListener {
                self.updateReplyFav(indexPath)
            }
            cell.likeBtn.setClickListener {
                self.updateReplyLike(indexPath)
            }
            //cell.podcastVC = self
            //cell.commentIndex = indexPath
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return CommentVCHeaderCell.height
        }else if (indexPath.row == 1 && comment == nil) || (indexPath.row == 2 && comment != nil){
            return CommentVCAddCell.height
        }
        return CommentCell.height
    }
    
    
    
    
}

extension CommentVC{
    
//    func addComment(_ msg : String){
//
//        LoadingIndicator.startAnimation()
//        var body:[String : Any] = [
//            "ContentId" : "\(contentId)",
//            "ContentType" : podcastShowCode,
//            "Message" : msg
//        ]
//
//        //let url = "http://comments.shadhin.co/api/\((podcastType == "PD") ? "Comment/Create": "VideoComment/CreateV3")"
//
//        let url = "\(BASE_URL_COMMENT_SM)/\((podcastType == "PD") ? "Comment/CreateV2": "VideoComment/CreateV3")"
//
//        if podcastType == "PD"{
//            body["IsPaid"] = SubscriptionService.instance.subscriptionStatus
//        }
//
//        print(url)
//        print(body)
//
//        Alamofire.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: API_HEADER).responseJSON { (response) in
//            LoadingIndicator.stopAnimation()
//            guard response.result.error == nil else {
//                self.view.makeToast("Error occurd")
//                return
//            }
//            self.podcastVC?.reloadComments()
//            self.podcastLive?.reloadComments()
//            self.podcastComment?.reloadComments()
//            self.dismiss(animated: true, completion: nil)
//
//        }
//    }
    
    func addComment(_ msg : String){
        
        LoadingIndicator.startAnimation()
        ShadhinCore.instance.api.addComment(
            "\(contentId)",
            podcastShowCode,
            msg,
            podcastType) { success, errorMsg, is402 in
                LoadingIndicator.startAnimation()
                if success{
                    self.podcastVC?.reloadComments()
                    self.podcastLive?.reloadComments()
                    self.podcastLive1?.reloadComments()
                    self.podcastComment?.reloadComments()
                    self.dismiss(animated: true, completion: nil)
                }else{
                    //print("msg: \(errorMsg) is402:\(is402)")
                    //var goProStr : String?
                    if is402{
                        //goProStr = "Go Pro"
                        self.dismiss(animated: true) {
                            SubscriptionPopUpVC.show(self.podcastVC)
                        }
                    }else{
                        self.dismiss(animated: true) {
                            AlertSlideUp.show(
                                image: UIImage(named: "ic_failed_newsub", in: Bundle.ShadhinMusicSdk,compatibleWith: nil) ?? UIImage(),
                                tileString: "Sorry!",
                                msgString: errorMsg ?? "Error occured",
                                positiveString: nil,
                                negativeString: "Close",
                                buttonDelegate: self.podcastVC)
                        }
                    }
                }
                
            }
    }
    
//    func addReply(_ msg : String){
//
//        guard let _comment = self.comment else {
//            return
//        }
//
//        LoadingIndicator.startAnimation()
//
//        var body:[String : Any] = [
//            "CommentId" : _comment.commentID,
//            "Message" : msg
//        ]
//
//        //let url = "http://comments.shadhin.co/api/\((podcastType == "PD") ? "Reply/Create": "VideoReply/CreateV3")"
//
//        let url = "\(BASE_URL_COMMENT_SM)/\((podcastType == "PD") ? "Reply/CreateV3": "VideoReply/CreateV3")"
//
//        if podcastType == "PD"{
//            body["IsPaid"] = SubscriptionService.instance.subscriptionStatus
//        }
//
//        print(url)
//        print(body)
//
//        Alamofire.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: API_HEADER).responseJSON { (response) in
//            LoadingIndicator.stopAnimation()
//            guard response.result.error == nil else {
//                self.view.makeToast("Error occurd")
//                return
//            }
//            self.getReplies()
//            self.shouldReloadComments =  true
//            //self.podcastVC?.reloadComments()
//            //self.podcastLive?.reloadComments()
//        }
//    }
    
    func addReply(_ msg : String){
        
        guard let _comment = self.comment else {
            return
        }
        
        LoadingIndicator.startAnimation()
        
        ShadhinCore.instance.api.addReply(
            _comment.commentID,
            msg,
            podcastType) { success, errorMsg, is402 in
                LoadingIndicator.startAnimation()
                if success{
                    self.getReplies()
                    self.shouldReloadComments =  true
                }else{
                    if is402{
                        //goProStr = "Go Pro"
                        self.dismiss(animated: true) {
                            SubscriptionPopUpVC.show(self.podcastVC)
                        }
                    }
                    
                    self.dismiss(animated: true) {
                        AlertSlideUp.show(
                            image: UIImage(named: "ic_failed_newsub", in: Bundle.ShadhinMusicSdk,compatibleWith: nil) ?? UIImage(),
                            tileString: "Sorry!",
                            msgString: errorMsg ?? "Error occured",
                            positiveString: nil,
                            negativeString: "Close",
                            buttonDelegate: self.podcastVC)
                    }
                }
            }
    }
    
    func getReplies(){
        guard let comment = self.comment else{
            return
        }
        LoadingIndicator.startAnimation()
        ShadhinCore.instance.api.getRepliesInComment(
            podcastType,
            comment.commentID) {
                data, errMsg in
                guard let replies = data else {
                    LoadingIndicator.stopAnimation()
                    self.view.makeToast(errMsg ?? "Error occurd")
                    return
                }
                self.replies = replies
                self.tableview.reloadData()
                self.updateTableContentInset()
                LoadingIndicator.stopAnimation()
            }
    }
    
    func updateCommentFav(){
        guard let index = self.indexOfComment, let _comment = self.comment else{
            return
        }
        podcastVC?.updateFavouriteComment(index, {
            self.comment?.commentFavorite = !_comment.commentFavorite
            if !_comment.commentFavorite{
                self.comment?.totalCommentFavorite += 1
            }else{
                self.comment?.totalCommentFavorite -= 1
            }
            self.tableview.reloadRows(at: [IndexPath.init(row: 1, section: 0)], with: .automatic)
        })
        
        podcastLive?.updateFavouriteComment(index, {
            self.comment?.commentFavorite = !_comment.commentFavorite
            if !_comment.commentFavorite{
                self.comment?.totalCommentFavorite += 1
            }else{
                self.comment?.totalCommentFavorite -= 1
            }
            self.tableview.reloadRows(at: [IndexPath.init(row: 1, section: 0)], with: .automatic)
        })
        podcastLive1?.updateFavouriteComment(index, {
            self.comment?.commentFavorite = !_comment.commentFavorite
            if !_comment.commentFavorite{
                self.comment?.totalCommentFavorite += 1
            }else{
                self.comment?.totalCommentFavorite -= 1
            }
            self.tableview.reloadRows(at: [IndexPath.init(row: 1, section: 0)], with: .automatic)
        })
        podcastComment?.updateFavouriteComment(index, {
            self.comment?.commentFavorite = !_comment.commentFavorite
            if !_comment.commentFavorite{
                self.comment?.totalCommentFavorite += 1
            }else{
                self.comment?.totalCommentFavorite -= 1
            }
            self.tableview.reloadRows(at: [IndexPath.init(row: 1, section: 0)], with: .automatic)
        })
    }
    
    func updateCommentLike(){
        guard let index = self.indexOfComment, let _comment = self.comment, !_comment.commentLike else{
            return
        }
        podcastVC?.updateLikeComment(index, {
            self.comment?.commentLike = true
            self.tableview.reloadRows(at: [IndexPath.init(row: 1, section: 0)], with: .automatic)
        })
        podcastLive?.updateLikeComment(index, {
            self.comment?.commentLike = true
            self.tableview.reloadRows(at: [IndexPath.init(row: 1, section: 0)], with: .automatic)
        })
        podcastLive1?.updateLikeComment(index, {
            self.comment?.commentLike = true
            self.tableview.reloadRows(at: [IndexPath.init(row: 1, section: 0)], with: .automatic)
        })
        podcastComment?.updateLikeComment(index, {
            self.comment?.commentLike = true
            self.tableview.reloadRows(at: [IndexPath.init(row: 1, section: 0)], with: .automatic)
        })
        
    }
    
    func updateReplyFav(_ index: IndexPath){
        guard let reply = replies?.data[index.row - 3] else {
            return
        }
        ShadhinCore.instance.api.toggleReplyFav(podcastType, reply.commentID, reply.replyID) {
            success, errMsg in
            LoadingIndicator.stopAnimation()
            if success{
                self.replies?.data[index.row - 3].replyFavorite = !reply.replyFavorite
                if !reply.replyFavorite{
                    self.replies?.data[index.row - 3].totalReplyFavorite += 1
                }else{
                    self.replies?.data[index.row - 3].totalReplyFavorite -= 1
                }
                self.tableview.reloadRows(at: [index], with: .automatic)
            }else{
                self.view.makeToast(errMsg ?? "Error occurd")
            }
        }
    }
    
    func updateReplyLike(_ index : IndexPath){
        guard let reply = replies?.data[index.row - 3], !reply.replyLike else {
            return
        }
        ShadhinCore.instance.api.likeReply(
            podcastType,
            reply.commentID,
            reply.replyID) {
            success, errMsg in
            LoadingIndicator.stopAnimation()
            if success{
                self.replies?.data[index.row - 3].replyLike = !reply.replyLike
                self.tableview.reloadRows(at: [index], with: .automatic)
            }else{
                self.view.makeToast(errMsg ?? "Error occurd")
            }
            
        }
    }
    
}
