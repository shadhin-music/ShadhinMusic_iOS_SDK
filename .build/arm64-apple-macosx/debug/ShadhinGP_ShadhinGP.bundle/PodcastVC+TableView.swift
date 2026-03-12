//
//  PodcastVC+TableView.swift
//  Shadhin_GP
//
//  Created by MD Murad Hossain on 20/02/2026.
//  Copyright © 2026 Shadhin Music Limited. All rights reserved.
//

import UIKit

extension PodcastVC {

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard gotData else { return 0 }
        return 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return headerAboutStr.isEmpty ? 0 : 1
        case 2: return tracksEpisode?.contents.count ?? 0
        case 3: return (podcastModel?.contents.count ?? 0) > 0 ? 1 : 0
        case 4: return 1
        case 5: return userComments?.data.count ?? 0
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {

        // MARK: - Section 0 — Header (tracksEpisode.parentContents[0])
        case 0:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PodcastHeaderOneViewCell.identifier,
                for: indexPath
            ) as! PodcastHeaderOneViewCell

            let parentEpisode = tracksEpisode?.parentContents.first
            cell.titleLabel.startLabelMarquee(text: headerTitle ?? "Episode")
            cell.subTitleLabel.startLabelMarquee(text: headerSubTitle ?? "")

            var imageVariant = "300"
            if podcastType == "VD" {
                cell.mainImgWidth.constant = 320
                imageVariant = "1280"
                cell.mainImg.cornerRadius = 8
                cell.playOverlayBtn.isHidden = false
                cell.playOverlayBtn.setClickListener {
                    guard let episode = self.tracksEpisode?.contents[safe: self.selectedEpisode] else {
                        return
                    }
                    
                    DispatchQueue.main.async() {
                        if episode.isPaid && !ShadhinCore.instance.isUserPro {
                            SubscriptionPopUpVC.show(self)
                            return
                        }
                    }
                    self.playMediaAtIndex(0)
                }
            } else {
                cell.playOverlayBtn.isHidden = true
                cell.mainImgWidth.constant = 180
                imageVariant = "300"
                cell.mainImg.cornerRadius = 16
            }

            let imgSource = parentEpisode?.imageUrl ?? headerImg ?? ""
            if !imgSource.isEmpty {
                let imgUrl = imgSource.replacingOccurrences(of: "<$size$>", with: imageVariant)
                cell.bgImg.kf.setImage(with: URL(string: imgUrl.safeUrl()))
                cell.mainImg.kf.indicatorType = .activity
                cell.mainImg.kf.setImage(
                    with: URL(string: imgUrl.safeUrl()),
                    placeholder: UIImage(named: "default_radio", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
                )
            }

            cell.shareBtn.setClickListener { self.share() }
            cell.backBtn.setClickListener { self.dismiss() }
            cell.shareBtnC.setClickListener { self.share() }

            self.playBtn = cell.playBtn
            self.favBtn = cell.favBtn
            
            if let selectedTrack = self.selectedTrack {
                cell.bind(content: selectedTrack)
            }

            cell.playBtn.setClickListener {
                guard let episode = self.tracksEpisode?.contents.first else { return }
                
                if episode.isPaid && !ShadhinCore.instance.isUserPro {
                    DispatchQueue.main.async() {
                        SubscriptionPopUpVC.show(self)
                        return
                    }
                } else {
                    
                    if self.shouldPlay {
                        if MusicPlayerV3.audioPlayer.state == .stopped || self.playBtn?.tag == 0 {
                            self.playBtn?.tag = 1
                            self.playMediaAtIndex(0)
                        } else {
                            MusicPlayerV3.audioPlayer.resume()
                            cell.playBtn.setImage(UIImage(named: "ic_Pause1", in: Bundle.ShadhinMusicSdk, compatibleWith: nil), for: .normal)
                        }
                        MusicPlayerV3.isAudioPlaying = false
                        self.shouldPlay = false
                    } else {
                        MusicPlayerV3.audioPlayer.pause()
                        cell.playBtn.setImage(UIImage(named: "ic_Play", in: Bundle.ShadhinMusicSdk, compatibleWith: nil),for: .normal)
                        MusicPlayerV3.isAudioPlaying = true
                        self.shouldPlay = true
                    }
                }
            }

            cell.favBtn.setClickListener { self.addDeleteFav() }
            return cell

        // MARK: Section 1 — About / Description
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PodcastHeaderTwoViewCell.identifier,
                for: indexPath
            ) as! PodcastHeaderTwoViewCell
            cell.aboutLabel.text = headerAboutStr
            cell.aboutLabel.delegate = self
            cell.aboutLabel.state = self.state
            return cell

        // MARK: Section 2 — Track List
        case 2:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PodcastItemViewCell.identifier,
                for: indexPath
            ) as! PodcastItemViewCell

            guard let tracksContent = tracksEpisode?.contents[safe: indexPath.row] else { return cell }
            cell.trackTitle?.text = tracksContent.titleBn.isEmpty ? tracksContent.titleEn : tracksContent.titleBn
            let duration = tracksContent.track?.duration ?? tracksContent.podcast.duration
            cell.trackSubTitile.text = formatDuration(duration)

            // Image
            var imageVariant = 300
            if podcastType == "VD" {
                cell.shortStoryImageWidth.constant = 75
                cell.shortStoryImage.cornerRadius = 4
                imageVariant = 1280
            } else {
                cell.shortStoryImageWidth.constant = 42
                cell.shortStoryImage.cornerRadius = 11
                imageVariant = 300
            }
            let imgUrl = tracksContent.imageUrl.replacingOccurrences(of: "<$size$>", with: "\(imageVariant)")
            cell.shortStoryImage.kf.indicatorType = .activity
            cell.shortStoryImage.kf.setImage(
                with: URL(string: imgUrl.safeUrl()),
                placeholder: UIImage(named: "default_radio", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
            )

            // Track type badge (live / pro / normal)
            let trackType = tracksContent.track?.trackType ?? ""
            if trackType == "L" || trackType == "LM" {
                cell.menuButton.isHidden = true
                cell.proIc.isHidden = false
                cell.proIc.image = UIImage(named: "ic_live", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
            } else {
                cell.proIc.image = UIImage(named: "ic_get_pro", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
                if ShadhinCore.instance.isUserPro {
                    cell.proIc.isHidden = true
                    cell.menuButton.isHidden = false
                } else {
                    cell.proIc.isHidden = !tracksContent.isPaid
                    cell.menuButton.isHidden = tracksContent.isPaid
                }
                cell.checkPodcastIsDownloading(data: tracksContent.toCommonContent())
            }

            // Click to play
            let index = indexPath.row
            cell.setClickListener {
                if tracksContent.isPaid && !ShadhinCore.instance.isUserPro {
                    NavigationHelper.shared.navigateToSubscription(from: self)
                    return
                }
                self.selectedEpisode = index
                self.playMediaAtIndex(index)
                self.playBtn?.setImage(
                    UIImage(named: "ic_Pause1", in: Bundle.ShadhinMusicSdk, compatibleWith: nil),
                    for: .normal
                )
                self.playBtn?.tag = 1
                MusicPlayerV3.isAudioPlaying = false
                self.shouldPlay = false
                self.tableView.reloadSections(IndexSet(integer: 2), with: .none)
            }

            // Three dot menu
            cell.didThreeDotMenuTapped {
                let menu = MoreMenuVC()
                menu.delegate = self
                menu.data = tracksContent.toCommonContent()
                menu.openForm = .Podcast
                menu.menuType = self.podcastType == "PD" ? .Podcast : .PodCastVideo
                let height = self.podcastType == "PD"
                    ? MenuLoader.getHeightFor(vc: .Podcast, type: .Podcast, operators: [])
                    : MenuLoader.getHeightFor(vc: .Podcast, type: .PodCastVideo, operators: [])
                var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 0)
                attribute.entryBackground = .color(color: .clear)
                attribute.border = .none
                SwiftEntryKit.display(entry: menu, using: attribute)
            }

            // Download mark
            let contentId = String(tracksContent.contentId)
            if DatabaseContext.shared.isPodcastExist(where: contentId) {
                cell.downloadMark.image = AppImage.downloadIcon.uiImage
            } else {
                cell.downloadMark.image = AppImage.nonDownload12.uiImage
            }

            return cell

        // MARK: Section 3 — More Episodes Footer (podcastModel.contents)
        case 3:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PodcastFooterViewCell.identifier,
                for: indexPath
            ) as! PodcastFooterViewCell

            if cell.collectionView.dataSource == nil {
                cell.collectionView.dataSource = self
                cell.collectionView.delegate = self
            }
            cell.seeAllBtn.setClickListener { self.viewAllEpisodes() }
            cell.collectionView.reloadData()
            return cell

        // MARK: Section 4 — Comment Header
        case 4:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CommentHeaderCell.identifier,
                for: indexPath
            ) as! CommentHeaderCell

            cell.totalCommentsLabel.text = "\(userComments?.totalData ?? 0)"
            cell.commentRefreshBtn.addTarget(self, action: #selector(reloadComments), for: .touchUpInside)
            cell.addCommentView.setClickListener { self.addComment() }
            return cell

        // MARK: Section 5 — Comments
        case 5:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CommentCell.identifier,
                for: indexPath
            ) as! CommentCell

            if let comment = userComments?.data[safe: indexPath.row] {
                cell.userImg.kf.indicatorType = .activity
                if let encoded = comment.userPic.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    cell.userImg.kf.setImage(
                        with: URL(string: encoded),
                        placeholder: UIImage(named: "ic_user_1", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
                    )
                }

                let badgeName: String? = comment.adminUserType.isEmpty
                    ? (comment.isSubscriber == true ? "ic_verified_user" : nil)
                    : "verified_2"

                if let badge = badgeName,
                   let badgeImg = UIImage(named: badge, in: Bundle.ShadhinMusicSdk, compatibleWith: nil) {
                    let attachment = NSTextAttachment()
                    attachment.image = badgeImg
                    attachment.bounds = CGRect(x: 0, y: -1, width: badgeImg.size.width, height: badgeImg.size.height)
                    let text = NSMutableAttributedString(string: "\(comment.userName) ")
                    text.append(NSAttributedString(attachment: attachment))
                    cell.userName.attributedText = text
                } else {
                    cell.userName.text = comment.userName
                }

                cell.comment.text = comment.message
                cell.favCount.text = "\(comment.totalCommentFavorite)"

                if comment.totalReply > 0 {
                    cell.replyCountBtn.isHidden = false
                    cell.replyCountBtn.setTitle("\(comment.totalReply) replies", for: .normal)
                    cell.replyCountBtn.setClickListener { self.viewReply(comment, indexPath) }
                } else {
                    cell.replyCountBtn.isHidden = true
                }

                cell.replyBtn.setClickListener { self.viewReply(comment, indexPath) }

                cell.favImg.image = UIImage(
                    named: comment.commentFavorite ? "ic_mymusic_favorite" : "ic_favorite_border",
                    in: Bundle.ShadhinMusicSdk,
                    compatibleWith: nil
                )

                if comment.commentLike {
                    cell.likeBtn.setTitle("You liked", for: .normal)
                    cell.likeBtn.setTitleColor(UIColor.red.withAlphaComponent(0.7), for: .normal)
                } else {
                    cell.likeBtn.setTitle("Like", for: .normal)
                    if #available(iOS 13.0, *) {
                        cell.likeBtn.setTitleColor(.secondaryLabel, for: .normal)
                    } else {
                        cell.likeBtn.setTitleColor(.gray, for: .normal)
                    }
                }

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                cell.timeAgo.text = dateFormatter.date(from: comment.createDate).map { timeAgoSince($0) } ?? " "

                cell.podcastVC = self
                cell.commentIndex = indexPath
                cell.initComment()
            }

            return cell

        default:
            return UITableViewCell()
        }
    }

    // MARK: - Height For Row
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return PodcastHeaderOneViewCell.height
        case 1: return headerAboutStr.isEmpty ? .leastNonzeroMagnitude : UITableView.automaticDimension
        case 2: return tracksEpisode?.contents.count ?? 0 > 0 ? PodcastItemViewCell.height : .leastNonzeroMagnitude
        case 3: return (podcastModel?.contents.count ?? 0) > 0 ? PodcastFooterViewCell.height : .leastNonzeroMagnitude
        case 4: return CommentHeaderCell.height
        case 5: return userComments?.data.count ?? 0 > 0 ? CommentCell.height : .leastNonzeroMagnitude
        default: return .leastNonzeroMagnitude
        }
    }

    // MARK: - Will Display
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cellHeightsDictionary[indexPath] = cell.frame.size.height
    }

    // MARK: - Estimated Height
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeightsDictionary[indexPath] ?? UITableView.automaticDimension
    }

    // MARK: - Scroll (load more comments)
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        loadMoreComments?.start {
            self.getComments({ self.loadMoreComments?.stop() })
        }
    }
}

// MARK: - ReadMoreLessViewDelegate
extension PodcastVC: ReadMoreLessViewDelegate {
    func didClickButton(_ readMoreLessView: ReadMoreLessView) {
        self.state = readMoreLessView.state == .collapsed ? .expanded : .collapsed
        if tableView.numberOfSections > 1 && tableView.numberOfRows(inSection: 1) > 0 {
            let index = IndexPath(row: 0, section: 1)
            self.tableView.reloadRows(at: [index], with: .automatic)
        }
    }

    func didChangeState(_ readMoreLessView: ReadMoreLessView) {}
}



/*
 
/// Old Code


import UIKit

extension PodcastVC {

    // MARK: - Number of Sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return podcastModel == nil ? 1 : 2
    }

    // MARK: - Number of Rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return userComments != nil ? (1 + userComments!.data.count) : 1
        }

        guard let contents = podcastModel?.contents, !contents.isEmpty else {
            return 0
        }

        let episode = (tracksEpisode?.contents ?? podcastModel?.contents ?? [])[selectedEpisode]
        var count = episode.track != nil ? 1 : 0

        return 2 + Int(Double(count)) + (shouldShowEpisodes ? 1 : 0)
    }

    // MARK: - Cell For Row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 1 {
            return tableViewComments(tableView, indexPath)
        }

        let totalCount = shouldShowEpisodes ? self.tableView(tableView, numberOfRowsInSection: 0) : -1

        switch indexPath.row {

        // MARK: Row 0 - Header One (Image, Title, Play, Fav)
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: PodcastHeaderOneViewCell.identifier, for: indexPath) as! PodcastHeaderOneViewCell
            cell.titleLabel.text = headerTitle
            cell.subTitleLabel.text = headerSubTitle

            var imageVariant = "300"
            if podcastType == "VD" {
                cell.mainImgWidth.constant = 320
                imageVariant = "1280"
                cell.mainImg.cornerRadius = 8
                cell.playOverlayBtn.isHidden = false
                cell.playOverlayBtn.setClickListener {
                    guard let episode = self.podcastModel?.contents[self.selectedEpisode] else { return }
                    if episode.isPaid && !ShadhinCore.instance.isUserPro {
                        SubscriptionPopUpVC.show(self)
                        return
                    }
                    self.playMediaAtIndex(0)
                }
            } else {
                cell.playOverlayBtn.isHidden = true
                cell.mainImgWidth.constant = 180
                imageVariant = "300"
                cell.mainImg.cornerRadius = 16
            }

            if let headerImg = headerImg {
                let imgUrl = headerImg.replacingOccurrences(of: "<$size$>", with: imageVariant)
                cell.bgImg.kf.setImage(with: URL(string: imgUrl.safeUrl()))
                cell.mainImg.kf.indicatorType = .activity
                cell.mainImg.kf.setImage(
                    with: URL(string: imgUrl.safeUrl()),
                    placeholder: UIImage(named: "default_radio", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
                )
            }

            cell.shareBtn.setClickListener { self.share() }
            cell.backBtn.setClickListener { self.dismiss() }
            cell.shareBtnC.setClickListener { self.share() }

            self.playBtn = cell.playBtn
            self.favBtn = cell.favBtn

            if let selectedTrack = self.selectedTrack {
                cell.bind(content: selectedTrack)
            }

            cell.playBtn.setClickListener {
                guard let episode = self.podcastModel?.contents[self.selectedEpisode] else { return }

                if episode.isPaid && !ShadhinCore.instance.isUserPro {
                    SubscriptionPopUpVC.show(self)
                    return
                }

                if self.shouldPlay {
                    if MusicPlayerV3.audioPlayer.state == .stopped || self.playBtn?.tag == 0 {
                        self.playBtn?.tag = 1
                        self.playMediaAtIndex(0)
                    } else {
                        MusicPlayerV3.audioPlayer.resume()
                        cell.playBtn.setImage(
                            UIImage(named: "ic_Pause1", in: Bundle.ShadhinMusicSdk, compatibleWith: nil),
                            for: .normal
                        )
                    }
                    MusicPlayerV3.isAudioPlaying = false
                    self.shouldPlay = false
                } else {
                    MusicPlayerV3.audioPlayer.pause()
                    cell.playBtn.setImage(
                        UIImage(named: "ic_Play", in: Bundle.ShadhinMusicSdk, compatibleWith: nil),
                        for: .normal
                    )
                    MusicPlayerV3.isAudioPlaying = true
                    self.shouldPlay = true
                }
            }

            cell.favBtn.setClickListener { self.addDeleteFav() }
            return cell

        // MARK: Row 1 - Header Two (About/Description)
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: PodcastHeaderTwoViewCell.identifier, for: indexPath) as! PodcastHeaderTwoViewCell
            cell.aboutLabel.text = headerAboutStr
            cell.aboutLabel.delegate = self
            cell.aboutLabel.state = self.state
            return cell

        // MARK: Last Row - Footer (Episode Collection)
        case totalCount - 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: PodcastFooterViewCell.identifier, for: indexPath) as! PodcastFooterViewCell
            if cell.collectionView.dataSource == nil {
                cell.collectionView.dataSource = self
                cell.collectionView.delegate = self
            }
            cell.seeAllBtn.setClickListener { self.seeAllEpisodes() }
            cell.collectionView.reloadData()
            return cell

        // MARK: Default - Track/Episode Item Rows
        default:

            let index = indexPath.row - 2
            let cell = tableView.dequeueReusableCell(withIdentifier: PodcastItemViewCell.identifier, for: indexPath) as! PodcastItemViewCell
            guard let contents = tracksEpisode?.contents ?? podcastModel?.contents,
                  index >= 0, index < contents.count else { return cell }
            let episode = contents[index]

            cell.trackTitle.text = episode.titleEn

            // Date from epoch
            let date = Date(timeIntervalSince1970: TimeInterval(episode.createdAtEpoch))
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMM dd yy"
            var str = dateFormatterPrint.string(from: date)

            // Duration
            let duration = episode.podcast.duration
            if duration > 0 {
                str += " • \(duration)s"
            }

            // Stream count
            if episode.streamingCount > 0 {
                str += " • \(episode.streamingCount.roundedWithAbbreviations) plays"
            }
            cell.trackSubTitile.text = str

            // Image
            var imageVariant = 300
            if podcastType == "VD" {
                cell.shortStoryImageWidth.constant = 75
                cell.shortStoryImage.cornerRadius = 4
                imageVariant = 1280
            } else {
                cell.shortStoryImageWidth.constant = 42
                cell.shortStoryImage.cornerRadius = 11
                imageVariant = 300
            }
            let imgUrl = episode.imageUrl.replacingOccurrences(of: "<$size$>", with: "\(imageVariant)")
            cell.shortStoryImage.kf.indicatorType = .activity
            cell.shortStoryImage.kf.setImage(
                with: URL(string: imgUrl.safeUrl()),
                placeholder: UIImage(named: "default_radio", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
            )

            // Track type — live vs normal
            let trackType = episode.track?.trackType ?? ""
            if trackType == "L" || trackType == "LM" {
                cell.menuButton.isHidden = true
                cell.proIc.isHidden = false
                cell.proIc.image = UIImage(named: "ic_live", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
            } else {
                cell.proIc.image = UIImage(named: "ic_get_pro", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
                if ShadhinCore.instance.isUserPro {
                    cell.proIc.isHidden = true
                    cell.menuButton.isHidden = false
                } else {
                    cell.proIc.isHidden = !episode.isPaid
                    cell.menuButton.isHidden = episode.isPaid
                }
//                cell.checkPodcastIsDownloading(data: episode as! CommonContentProtocol)
            }

            // Click to play
            cell.setClickListener {
                if episode.isPaid && !ShadhinCore.instance.isUserPro {
                    NavigationHelper.shared.navigateToSubscription(from: self)
                    return
                }
                self.playMediaAtIndex(index)
                self.playBtn?.setImage(
                    UIImage(named: "ic_Pause1", in: Bundle.ShadhinMusicSdk, compatibleWith: nil),
                    for: .normal
                )
                self.playBtn?.tag = 1
                MusicPlayerV3.isAudioPlaying = false
                self.shouldPlay = false
            }

            // Three dot menu
            cell.didThreeDotMenuTapped {
                let menu = MoreMenuVC()
                menu.delegate = self
                menu.openForm = .Podcast
                menu.menuType = self.podcastType == "PD" ? .Podcast : .PodCastVideo
                let height = self.podcastType == "PD"
                    ? MenuLoader.getHeightFor(vc: .Podcast, type: .Podcast, operators: [])
                    : MenuLoader.getHeightFor(vc: .Podcast, type: .PodCastVideo, operators: [])
                var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 0)
                attribute.entryBackground = .color(color: .clear)
                attribute.border = .none
                SwiftEntryKit.display(entry: menu, using: attribute)
            }

            // Download mark
            let contentId = String(episode.contentId)
            if DatabaseContext.shared.isPodcastExist(where: contentId) {
                cell.downloadMark.image = AppImage.downloadIcon.uiImage
            } else {
                cell.downloadMark.image = AppImage.nonDownload12.uiImage
            }

            return cell
        }
    }

    // MARK: - Comments Section
    func tableViewComments(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentHeaderCell.identifier, for: indexPath) as! CommentHeaderCell
            cell.totalCommentsLabel.text = "\(userComments?.totalData ?? 0)"
            cell.commentRefreshBtn.addTarget(self, action: #selector(reloadComments), for: .touchUpInside)
            cell.addCommentView.setClickListener { self.addComment() }
            return cell

        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as! CommentCell
            if let comment = userComments?.data[indexPath.row - 1] {
                cell.userImg.kf.indicatorType = .activity
                if let userPicUrlEncoded = comment.userPic.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    cell.userImg.kf.setImage(
                        with: URL(string: userPicUrlEncoded),
                        placeholder: UIImage(named: "ic_user_1", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
                    )
                }

                if comment.adminUserType.isEmpty {
                    if comment.isSubscriber ?? false {
                        let imageAttachment = NSTextAttachment()
                        imageAttachment.image = UIImage(named: "ic_verified_user", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
                        imageAttachment.bounds = CGRect(x: 0, y: -1.0, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
                        let completeText = NSMutableAttributedString(string: "")
                        completeText.append(NSAttributedString(string: "\(comment.userName) "))
                        completeText.append(NSAttributedString(attachment: imageAttachment))
                        cell.userName.attributedText = completeText
                    } else {
                        cell.userName.text = comment.userName
                    }
                } else {
                    let imageAttachment = NSTextAttachment()
                    imageAttachment.image = UIImage(named: "verified_2", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
                    imageAttachment.bounds = CGRect(x: 0, y: -1.0, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
                    let completeText = NSMutableAttributedString(string: "")
                    completeText.append(NSAttributedString(string: "\(comment.userName) "))
                    completeText.append(NSAttributedString(attachment: imageAttachment))
                    cell.userName.attributedText = completeText
                }

                cell.comment.text = comment.message
                cell.favCount.text = "\(comment.totalCommentFavorite)"

                if comment.totalReply > 0 {
                    cell.replyCountBtn.isHidden = false
                    cell.replyCountBtn.setTitle("\(comment.totalReply) replies", for: .normal)
                    cell.replyCountBtn.setClickListener { self.viewReply(comment, indexPath) }
                } else {
                    cell.replyCountBtn.isHidden = true
                }

                cell.replyBtn.setClickListener { self.viewReply(comment, indexPath) }

                if comment.commentFavorite {
                    cell.favImg.image = UIImage(named: "ic_mymusic_favorite", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
                } else {
                    cell.favImg.image = UIImage(named: "ic_favorite_border", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
                }

                if comment.commentLike {
                    cell.likeBtn.setTitle("You liked", for: .normal)
                    cell.likeBtn.setTitleColor(UIColor.red.withAlphaComponent(0.7), for: .normal)
                } else {
                    cell.likeBtn.setTitle("Like", for: .normal)
                    if #available(iOS 13.0, *) {
                        cell.likeBtn.setTitleColor(.secondaryLabel, for: .normal)
                    } else {
                        cell.likeBtn.setTitleColor(.gray, for: .normal)
                    }
                }

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                if let date = dateFormatter.date(from: comment.createDate) {
                    cell.timeAgo.text = timeAgoSince(date)
                } else {
                    cell.timeAgo.text = " "
                }

                cell.podcastVC = self
                cell.commentIndex = indexPath
                cell.initComment()
            }
            return cell
        }
    }

    // MARK: - Height For Row
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return indexPath.row == 0 ? CommentHeaderCell.height : CommentCell.height
        }

        let totalCount = shouldShowEpisodes ? self.tableView(tableView, numberOfRowsInSection: 0) : -1

        switch indexPath.row {
        case 0:
            return PodcastHeaderOneViewCell.height
        case 1:
            return UITableView.automaticDimension
        case totalCount - 1:
            return (podcastModel?.contents.count ?? 0) > 1 ? PodcastFooterViewCell.height : .leastNonzeroMagnitude
        default:
            return PodcastItemViewCell.height
        }
    }

    // MARK: - Will Display
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cellHeightsDictionary[indexPath] = cell.frame.size.height
    }

    // MARK: - Estimated Height
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = self.cellHeightsDictionary[indexPath] {
            return height
        }
        return UITableView.automaticDimension
    }

    // MARK: - Scroll
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        loadMoreComments?.start {
            self.getComments({ self.loadMoreComments?.stop() })
        }
    }
}

// MARK: - ReadMoreLessViewDelegate
extension PodcastVC: ReadMoreLessViewDelegate {
    func didClickButton(_ readMoreLessView: ReadMoreLessView) {
        self.state = readMoreLessView.state == .collapsed ? .expanded : .collapsed
        if tableView.numberOfSections > 0 && tableView.numberOfRows(inSection: 0) > 1 {
            let index = IndexPath(row: 1, section: 0)
            self.tableView.reloadRows(at: [index], with: .automatic)
        }
    }

    func didChangeState(_ readMoreLessView: ReadMoreLessView) {}
}



*/
