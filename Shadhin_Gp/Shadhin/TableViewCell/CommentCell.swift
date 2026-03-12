//
//  CommentCell.swift
//  Shadhin
//
//  Created by Rezwan on 6/10/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var height: CGFloat {
        return UITableView.automaticDimension
    }
    
    
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var timeAgo: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var favView: UIView!
    @IBOutlet weak var favImg: UIImageView!
    @IBOutlet weak var favCount: UILabel!
    @IBOutlet weak var replyCountBtn: UIButton!
    
    var commentIndex : IndexPath? = nil
    
    var podcastVC : PodcastVC? = nil
    var podcastLive : PodcastYoutubeVC? = nil
    var podcastLive1 : VideoPodcastVC? = nil
    var podcastComment : PodcastCommentVC? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initComment(){
        favView.setClickListener {
            self.updateFavorite()
        }
        likeBtn.addTarget(self, action: #selector(updateLike), for: .touchUpInside)
    }
    
    @objc func updateFavorite(){
        if let podcastVC = self.podcastVC, let commentIndex = self.commentIndex{
            podcastVC.updateFavouriteComment(commentIndex)
        }
        if let podcastLive = self.podcastLive, let commentIndex = self.commentIndex{
            podcastLive.updateFavouriteComment(commentIndex)
        }
        if let podcastLive = self.podcastLive1, let commentIndex = self.commentIndex{
            podcastLive.updateFavouriteComment(commentIndex)
        }
        if let podcastComment = self.podcastComment, let commentIndex = self.commentIndex{
            podcastComment.updateFavouriteComment(commentIndex)
        }
        
    }
    
    @objc func updateLike(){
        if let podcastVC = self.podcastVC, let commentIndex = self.commentIndex{
            podcastVC.updateLikeComment(commentIndex)
        }
        if let podcastLive = self.podcastLive, let commentIndex = self.commentIndex{
            podcastLive.updateLikeComment(commentIndex)
        }
        if let podcastLive = self.podcastLive1, let commentIndex = self.commentIndex{
            podcastLive.updateLikeComment(commentIndex)
        }
        if let podcastComment = self.podcastComment, let commentIndex = self.commentIndex{
            podcastComment.updateLikeComment(commentIndex)
        }
    }
    
    
}
