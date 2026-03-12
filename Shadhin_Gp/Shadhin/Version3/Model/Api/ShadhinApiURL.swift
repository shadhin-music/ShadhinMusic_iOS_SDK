//
//  ShadhinApiURL.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/26/21.
//  Copyright © 2021 Cloud 7 Limited. All rights reserved.
//

import Foundation


public class ShadhinApiURL: ShadhinApiContants {
    
//    static private let BASE_URL_DEV     = "https://salute.gakktech.com/api/v5"
//    static private let BASE_URL_DEV_V4  = "https://salute.gakktech.com/api/v4"
    
    //static let BASE_URL            = BASE_URL_PRODUCTION // "http://188.166.208.131/api/v5"
    static var BASE_URL : String = {
#if DEBUG
        return "https://coreapi.shadhinmusic.com/api/v5"
        //return "https://testservice.shadhin.co/api/v5"
#else
        return "https://coreapi.shadhinmusic.com/api/v5"
#endif
    }()
    static let BASE_URL_HOMEV3  = "https://connect.shadhinmusic.com/api"
    static let BASE_URL_SEARCH_V2 = "https://search.query.shadhin.co/api/v1"
    static let BASE_URL_SEARCH_V2_History = "https://search.cmd.shadhin.co/api/v1"
    static let BASE_URL_USER_SEARCH_TEXT = "https://search.cmd.shadhin.co/api/v1/NewSearch"
    static let BASE_URL_NEW_DIGITAL_PAY = "https://connect.shadhinmusic.com/api/v1"
    static let BASE_URL_V1 = "https://connect.shadhinmusic.com/api/v1"
    static let BASE_URL_PRODUCTION = "https://coreapi.shadhinmusic.com/api/v5"
    static var TEST_BASE           = "https://testservice.shadhin.co/api/v5"
    static let BASE_URL_V6         = "https://coreapi.shadhinmusic.com/api/v6"
    static let NEW_AUTH_BASE_URL       = "https://connect.shadhinmusic.com"
    
    static private let BASE_URL_0               = "https://apis.techapi24.com"
    static let BASE_URL_1                       = "http://27.131.15.18/6dbldcb/api"
    static private let BASE_URL_GP              = "https://telenordob.techapi24.com/api/Subscription"
    static private let BASE_url_GP_V2           = "http://103.110.59.90:89/api"
    static private let BASE_URL_COMMENT         = "https://comments.shadhinmusic.com/api/v5"
    static private let BASE_URL_RBT             = "https://rbt.shadhin.co/api/rbt/check-rbt-song"
    static public  let BASE_URL_SIGNALR         = "http://socket.shadhinmusic.com"
    static public let BASE_CAMPAIGN_HISTORY_URL = "https://campaign.shadhinmusic.com"
    static public let IMAGE_BASE_URL            = "http://188.166.208.131/userpic"
    static public let BASE_URL_STRIPE           = "https://stripe.payment-app.info/api"
    static public let BASE_URL_SSL              = "https://ssl.payment-app.info"
    static public let BASE_URL_PAYMENT          = "https://api.payment-app.info"
    static public let BASE_URL_UMOBILE          = "http://27.131.15.19/ShandhinCelcomPaymentAPI/ShadhinUMobile"
    static public let AI_BASE_URL               = "https://connect.shadhinmusic.com/api/v1"
    #if DEBUG
    let APPLE_VERIFY_RECEIPT_URL = "https://sandbox.itunes.apple.com/verifyReceipt"
    #else
    let APPLE_VERIFY_RECEIPT_URL = "https://buy.itunes.apple.com/verifyReceipt"
    #endif
    
    let RUNNING_CAMPAIGN               = "\(BASE_URL)/Ads/CampaignSchedule"
    let USER_STREAMING_POINTS          = "\(BASE_URL)/User/PlaylistShareStreamCount"
    let REFERAL_DATA                   = "\(BASE_URL)/ReferralCode/GetReferralCode"
    let INITIATE_TICKET_PAYMENT_SSL    = "\(BASE_URL)/MusicEvent/InitiateTicketPayment"
    let INITIATE_TICKET_PAYMENT_BKASH  = "\(BASE_URL)/MusicEvent/Bkash/InitiateTicketPayment"
    let CHECK_TICKET_PAYMENT_SSL       = "\(BASE_URL)/MusicEvent/ConfirmPurchase?purchaseCode="
    let CHECK_TICKET_PAYMENT_BKASH     = "\(BASE_URL)/MusicEvent/Bkash/ConfirmPurchase?purchaseCode="
    let GET_PURCHASED_TICKETS          = "\(BASE_URL)/MusicEvent/GetTickets"
    let GIVE_LOGIN_POINT               = "\(BASE_URL)/ReferralCode/LoginPoints"
    let USER_CASH_BACK_STATUS          = "\(BASE_URL)/CashBack/GetSubscribeCashBack"
    let CASH_BACK_NUMBER_SET           = "\(BASE_URL)/CashBack/SubscribeCashBack?accountNumber="
    let ADD_COUPON                     = "\(BASE_URL)/Ads/ShadhinCouponAdd?vendor=bkash&code="
    let CONCERT_TICKET_DETAILS         = "\(BASE_URL)/MusicEvent/GetEventData"
    let REFERAL_TRANSACTION_HISTORY    = "\(BASE_URL)/ReferralCode/PointsTransactionHistory"
    let REFERAL_POINT_HISTORY          = "\(BASE_URL)/ReferralCode/GetPointsHistory"
    let REDEEM_REFERAL_POINTS          = "\(BASE_URL)/ReferralCode/PointsRedeem"
    let STREAM_POINTS                  = "\(BASE_URL)/ads/campaigngettelcostreaming"
//    let REGISTRATION                   = "\(BASE_URL)/User/Registration"
//    let LOGIN                          = "\(BASE_URL)/User/LOGIN"
    let REMOVE_SOCIAL                  = "\(BASE_URL)/User/removesocialcredentials"
    let GET_GENRE                      = "\(BASE_URL)/Genre/GetGenre"
    let SET_GENRE                      = "\(BASE_URL)/Genre/ManageGenre"
    let TOKEN_UPDATE                   = "\(BASE_URL)/User/flogin"
    let GET_PLAY_URL                   = {(
        _ contentType      : String,
        _ podcastShowCode  : String,
        _ trackType        : String,
        _ urlKey           : String
        )->String in
        return "\(BASE_URL)/streaming/getpth?ptype=\(contentType)&type=\(podcastShowCode)&ttype=\(trackType)&name=\(urlKey)"
    }
    
    let GET_PLAY_URL_V2                   = {(
        _ trackType        : String,
        _ urlKey           : String
    ) -> String in
        return "\(BASE_URL)/streaming/getpth?ttype=\(trackType)&name=\(urlKey)"
    }
    
    let GET_DOWNLOAD_URL               = {(
        _ name             : String
        )->String in
        return "\(BASE_URL)/streaming/getdwnpth?name=\(name)"
    }
    let GET_PATCH_DETAILS_BY           = {(
        _ patchCode: String,
        _ contentType: String
    )->String in
        return "\(BASE_URL)/HomeContent/GetdatabyContentcodeandTypeV6?code=\(patchCode)&contenttype=\(contentType)"
    }
   
    let GET_PAGED_HOME_CONTENT         = {(
        _ page: String)->String in
        return "\(BASE_URL)/HomeContent/GetHomeContentV7?pageNumber=\(page)&isPaid=\(ShadhinCore.instance.isUserPro)"
    }
    let GET_PAGED_HOME_CONTENTV3         = {(
        _ page: String)->String in
        return "\(BASE_URL_HOMEV3)/v1/contents/home/patches?pageNumber=\(page)"
    }
    
    let SHADHIN_REWIND = {(
        _ userCode: String
    )->String in
        return "http://api.blcms.shadhin.co/api/ShadhinDashboard/UserWiseTop5Streamming?userCode=\(userCode)"
    }
    
    let GET_ARTIST_FEATURED_PLAYLIST   = {(
        _ artistId: String
    )->String in
        return "\(BASE_URL)/Artist/ArtistPlayList?id=\(artistId)"
    }
    let RELEASE_PLAY_LOCK              = "\(BASE_URL)/streaming/play/status"
    let RECEIPT_DATA                   = "\(BASE_URL)/Subscriber/digipay"
    let RECEIPT_DATA_NEW               = "\(BASE_URL_NEW_DIGITAL_PAY)/payment/digital-subscription"
    let PASSWORD_UPDATE                = "\(BASE_URL)/user/frogotpassword"
    let SEARCH_CONTENT                 = {(
        _ keyword          : String
        )->String in
        return "\(BASE_URL)/Search/SearchByKeywordV6?keyword=\(keyword)"
    }
    let ADD_SEARCH_HISTORY             = "\(BASE_URL)/useractivity/UserSearchHistory"
    let GET_SEARCH_HISTORY             = "\(BASE_URL)/useractivity/GetUserSearchhistory"

    let TOP_TEN_TRENDING               = {(
        _ type             : String
        )->String in
        return "\(BASE_URL)/Track/TopTrendingV6?type=\(type)"
    }
    
    
    let GET_ALL_VIDEO_CATEGORIES       = "\(BASE_URL)/HomeContent/videocategoryV6"
    
    let SEND_OTHER_BD_OTP              = "\(BASE_URL)/otp/otpreq"
    let CHECK_OTHER_BD_OTP             = "\(BASE_URL)/otp/otpcheck"
    let SEND_ROBI_OTP                  = "\(BASE_URL)/otp/OtpRobiReq"
    let CHECK_ROBI_OTP                 = "\(BASE_URL)/otp/lsotpcheck"
    let SEND_BL_OTP                    = "\(BASE_URL)/otp/OtpBLReq"
    let CHECK_BL_OTP                   = "\(BASE_URL)/otp/otpblcheck"
    let GET_TOP_ARTISTS                = {(
        _ artistId             : String
        )->String in
        return "\(BASE_URL)/Artist/ArtistData?artistId=\(artistId)"
    }
    let GET_SONGS_OF_ARTIST            = {(
        _ artistId             : String
        )->String in
        return "\(BASE_URL)/Artist/GetArtistContent?id=\(artistId)"
    }
    let GET_SONGS_OR_ALBUMS_OF_ARTIST  = {(
        _ artistId             : String,
        _ type                 : String
        )->String in
        return "\(BASE_URL)/Artist/ArtistAlbumsbyidtypeV6?id=\(artistId)&&type=\(type)"
    }
    let GET_POP_UP_DATA                = "\(BASE_URL)/ads/campaigndata"
    let RESET_RESTRICTION              = "\(BASE_URL)/streaming/devicerestore"
    let GET_FAVORITES_BY_TYPE          = {(
        _ type: String
        )->String in
        return"\(BASE_URL)/Favourite/GetFavourite?type=\(type)"
    }
    let GET_USER_PLAYLISTS             = "\(BASE_URL)/Playlist/Userplaylist"
    let DELETE_USER_PLAYLIST           = {(
        _ id: String
        )->String in
        return "\(BASE_URL)/Playlist/DeleteUserplayList?id=\(id)"
    }
    let GET_NEW_USER_PLAYLIST           = {(
        _ userCode: String
        )->String in
        return "\(AI_BASE_URL)/contents/userplaylist?Usercode=\(userCode)"
    }
    let ADD_TO_USER_PLAYLIST           = "\(BASE_URL)/Playlist/PostUserplayListContent"
    let DELETE_FROM_USER_PLAYLIST      = "\(BASE_URL)/Playlist/DeleteUserPlaylistContent"
    let DOWNLOAD_COMPLETE_HISTORY_POST = "\(BASE_URL)/DownloadHistory/DownloadHistoryPostV2"
    let DOWNLOAD_COMPLETE_HISTORY_GET  = "\(BASE_URL)/DownloadHistory/GetDownloadHistoryV2?contentType=s"
    let DOWNLOAD_HISTORY_DELETE        = "\(BASE_URL)/DownloadHistory/DeleteDownloadHistoryV2"
    let GET_ALBUM_PLAYLIST             = {(_ mediaType: SMContentType,_ contentID: String)->String in
        switch mediaType{
        case .album:
            return "\(BASE_URL)/Album/GetAlbumContentV6?id=\(contentID)"
        case .playlist:
            return "\(BASE_URL)/Playlist/GetPlaylistContentByIdV6?id=\(contentID)"
        case .song:
            return "\(BASE_URL)/Track/singletrack?id=\(contentID)"
        default:
            return ""
        }}
    let ADD_AND_DELETE_FAVORITES       = "\(BASE_URL)/Favourite"
    let ADD_FAVORITES_ARTIST           = "\(BASE_URL_V6)/Favourite/Add"
    let RECENTLY_PLAYED_POST           = "\(BASE_URL)/RecentPlay/RecentPlayPost"
    let RECENTLY_PLAYED_PODCAST_POST   = "\(BASE_URL)/PodcastRecentPlay/PodcastRecentPlayV3"
    let RECENTLY_PLAYED_GET_ALL        = {
        (_ page : Int)->String in return "\(BASE_URL)/RecentPlay/GetRecentPlayAllV2?pageNumber=\(page)"
    }
    let UPDATE_MSISDN                   = "\(BASE_URL)/account/msisdn"
    let REGISTRATION                   = "\(NEW_AUTH_BASE_URL)/api/v1/user/registration"
    let UPGRADE_V4_TOKEN_TO_V5         = "\(BASE_URL)/account/toklogin"
    //let LOGIN_V5                       = "\(BASE_URL)/account/login"
    //let LOGIN_V6                       = "\(BASE_URL)/account/loginV6"
    let ACC_LINK                       = "\(BASE_URL)/user/aclinking"
    let GET_USER_PROFILE               = "\(BASE_URL)/user/GetUserInfo"

    let NEW_LOGIN                      = "\(NEW_AUTH_BASE_URL)/api/v1/user/login"
    let GET_USER_INFO                  = "\(NEW_AUTH_BASE_URL)/api/v1/user/get-user-info"
    let LOGIN                          = "\(BASE_URL)/account/loginV7"
    let UPDATE_USER_PROFILE            = "\(BASE_URL)/user/UserProfileUpdate"
    let NEW_UPDATE_USER_PROFILE        = "\(NEW_AUTH_BASE_URL)/api/v1/user/update-user-profile"
    let UPDATE_FCM_TOKEN               = {(
        _ fcmToken: String
        )->String in
        return "\(BASE_URL)/user/UpdateDeviceId?fcmId=\(fcmToken)"
    }
    //MARK: 
    //subscription
    let GLOBAL_SUBSCRIPTION_CHECK      = "\(BASE_URL)/subscriptiondetails/get"
    let GET_NAGAD_SUB_URL              = "\(BASE_URL)/Nagad/NgPayInitiate"
    let BKASH_TOKEN_GENERATE           = "\(BASE_URL)/bkash/token"
    let BKASH_TOKEN_GENERATEV2         = "\(BASE_URL_PAYMENT)/bkash/checkout/create_checkout_session"
    let GET_BKASH_SUB_URL              = "\(BASE_URL)/bkash/bkpayinitiate"
    let CANCEL_BKASH_SUB               = "\(BASE_URL)/bkash/bkpaycancelsubs"
    let CANCEL_BKASH_SUBV2             = "\(BASE_URL_PAYMENT)/bkash/billing/cancel_subscription"
    let BKASH_SUB_HISTORY              = "\(BASE_URL)/bkash/bkpaymenthistoryuser"
    let GET_BKASH_SUB_INFO_BY_SUBID    = {(
        _ subreqid: String
        )->String in
        return "\(BASE_URL)/bkash/bksubsinforeqid?subreqid=\(subreqid)"
    }
    let GET_BKASH_PAY_INFO_BY_PAYID    = {(
        _ paymentid: String
        )->String in
        return "\(BASE_URL)/bkash/bkpaymentinfopid?payid=\(paymentid)"
    }
    let GET_UPAY_SUB_URL               = "\(BASE_URL)/upay/upayinitiate"
    let GET_SSL_SUB_URL                = "\(BASE_URL)/sslcomz/ssltransactionsession"
    let GET_GP_DOB_PLUS_SUB            = "\(BASE_URL)/GPDOBPlus/dobpayinitiate"
    let GP_DOB_PLUS_CANCEL             = "\(BASE_URL)/GPDOBPlus/dobcancelsubs"
    let GET_GP_DOB_SUB_OTP             = "\(BASE_URL)/GPDOB/dobpushotp"
    let CHECK_GP_DOB_SUB_OTP           = "\(BASE_URL)/GPDOB/dobchargeotp"
    static let GP_NEW_OTP_BASE_URL     = "https://api.payment-app.info/grameenphone/DOBBilling"
    let NEW_GP_SEND_OTP                = "\(GP_NEW_OTP_BASE_URL)/send_otp"
    let NEW_GP_VERIFY_OTP              = "\(GP_NEW_OTP_BASE_URL)/verify_otp"
    let GP_DOB_CANCEL                  = "\(BASE_URL)/GPDOB/dobcancelsubs"
    let GP_DPDP_CANCEL                 = {(
        _ serviceID: String,
        _ msisdn: String
        )->String in
        return "\(BASE_URL_0)/dpdpapi/UnSubsSDHN.aspx?serviceid=\(serviceID)&vMsisdn=\(msisdn)"
    }
    let GET_GP_DPDP_CHARGING_URL       = {(
        _ serviceID: String
        )->String in
        return "\(BASE_URL_0)/dpdpapi/SubsRequestSDHN.aspx?serviceid=\(serviceID)"
    }
    let GET_GP_CHARGING_URL            = "\(BASE_URL_GP)/PrepareConsent"
    let GET_GP_CHARGING_URL_V2         = "\(BASE_URL_PAYMENT)/grameenphone/checkout/create-checkout-session"
    let CANCEL_GP_SUB_V2               = "\(BASE_URL_PAYMENT)/grameenphone/billing/cancel-subscription"
    let CANCEL_GP_SUB                  = {(
        _ serviceID: String,
        _ msisdn: String
        )->String in
        return "\(BASE_URL_GP)/UnsubscribeLatest?msisdn=\(msisdn)&serviceId=\(serviceID)"
    }
    let GET_ROBI_SUB                   = {(
        _ msisdn: String,
        _ serviceId : String
        )->String in
        return "\(BASE_URL)/RobiDCB/ReqSubsRDCB?mid=\(msisdn)&subscriptionID=\(serviceId)&chargetype=\("SMS")&callbackurl=\("https://www.robicallback.com")"
    }
    let GET_ROBI_SUB_V2                = "\(BASE_URL_PAYMENT)/robi/checkout/create-checkout-session"
    /// Amin vai provide this api
    let CANCEL_ROBI_SUB                = {(
        _ msisdn: String,
        _ serviceId : String
        )->String in
        return "\(BASE_URL)/RobiDCB/CancelSubsRDCB?mid=\(msisdn)&subscriptionID=\(serviceId)"
    }
    /// PIAS provice this api
    let CANCEL_ROBI_V2 = "\(BASE_URL_PAYMENT)/robi/billing/cancel-subscription"
    
    let GET_BL_SUB_OTP                 = {(
        _ msisdn: String,
        _ serviceId : String
        )->String in
        return "\(BASE_URL)/BLDCB/otpr?MSISDN=\(msisdn)&SERVICEID=\(serviceId)"
    }
    let CHECK_BL_SUB_OTP               = {(
        _ msisdn: String,
        _ serviceId : String,
        _ otp: String
        )->String in
        return "\(BASE_URL)/BLDCB/otpc?MSISDN=\(msisdn)&SERVICEID=\(serviceId)&OTP=\(otp)"
    }
    let CANCEL_BL_SUB                  = {(
        _ msisdn: String,
        _ serviceId : String
        )->String in
        return "\(BASE_URL)/BLDCB/SubCancel?MSISDN=\(msisdn)&ServiceID=\(serviceId)&Dsource=App"
    }
    let CHECK_BL_DATA_BUNDLE           = {(
        _ msisdn: String
        )->String in
        return "\(BASE_URL)/BLDataBundle/BLDataBundleCheck?MSISDN=\(msisdn)"
    }
    //RBT
    let CHECK_SONGS_FOR_RBT            = "\(BASE_URL_RBT)/RbtTune/SongRBTCheck"
    let SET_RBT_GP                     = "\(BASE_URL_RBT)/RbtTune"
    let SET_RBT_BL                     = "\(BASE_URL_RBT)/BanglalinkRbt"
    let CREATE_USER_PLAYLIST           = "\(BASE_URL)/Playlist/PostUserplayList"
    let GET_USER_PLAYLIST_CONTENT      = {(
        _ id: String)
        ->String in
        return "\(BASE_URL)/Playlist/GetUserPlaylist?id=\(id)"
    }
    let GET_LYRICS                     = {(
        _ songID: String)
        ->String in return "\(BASE_URL)/Track/Lyrics?contentType=s&contentId=\(songID)"}
    let GET_MONTHLY_LISTENER_COUNT     = {(
        _ contentID: String,
        _ type: String)
        ->String in
        return "\(BASE_URL)/Track/MonthlyPlayCount?contentId=\(contentID)&contentType=\(type)"
    }
    let GET_FAV_COUNT                  = {(
        _ contentID: String,
        _ contentType: String)
        ->String in
        return "\(BASE_URL)/Track/TotalFav?contentId=\(contentID)&contentType=\(contentType)"
    }
    let GET_ARTISTS_IN_PLAYLIST        = {(
        _ playlistID: String)
        ->String in return "\(BASE_URL)/Artist/ArtistByPlayListV6?id=\(playlistID)"
    }
    let GET_ARTIST_BIO                 = {(
        _ name: String)
        ->String in
        return "http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=\(name)&api_key=55dd9a0fd0790ee3219022141a8cdf39&&format=json"
    }
    //podcast
    let POST_PODCAST_LIKE              = "\(BASE_URL)/Podcast/PodcastLikeV3"
    let GET_PODCAST_LIKED_COUNT        = {
        (_ podcastType: String,
         _ trackID: Int)
        ->String in
        return "\(BASE_URL)/Podcast/GetPodcastLikeV3?podType=\(podcastType)&contentId=\(trackID)"
    }
    let PODCAST_EXPLORE                = "\(BASE_URL)/Podcast/PodcastHomeDataV6"
    
    let GET_PODCAST_DETAILS            = "\(BASE_URL)/Podcast/Podcast"
    let GET_PODCAST_SHOWS              = "\(BASE_URL)/Podcast/PodcastShowDataV6"
    //comment
    let ADD_COMMENT                    = {(
        _ podcastType             : String
        )->String in
        return "\(BASE_URL_COMMENT)/\((podcastType == "PD") ? "Comment/CreateV2": "VideoComment/CreateV3")"
    }
    let ADD_REPLY                      = {(
        _ podcastType             : String
        )->String in
        return "\(BASE_URL_COMMENT)/\((podcastType == "PD") ? "Reply/CreateV3": "VideoReply/CreateV3")"
    }
    let GET_COMMENTS                   = {(
        _ podcastType : String,
        _ conentID: Int,
        _ page : Int,
        _ podcastCode : String
    )->String in
        return "\(BASE_URL_COMMENT)\((podcastType == "PD") ? "/Comment/GetListV2" : "/VideoComment/GetListV3")/\(conentID)/\(podcastCode)/\(page)"}
    let GET_REPLIES_IN_COMMENT         = {(
        _ podcastType : String,
        _ commentID : Int
    )->String in
        return  "\(BASE_URL_COMMENT)/\((podcastType == "PD") ? "Reply/GetList" : "VideoReply/GetListV3")/\(commentID)"
    }
    let UPDATE_COMMENT_FAV             = {(
        _ podcastType : String,
        _ commentID: Int)
        ->String in
        return "\(BASE_URL_COMMENT)\((podcastType == "PD") ? "/CommentFavorite/Create" : "/VideoCommentFavorite/CreateV3")/\(commentID)"}
    let UPDATE_COMMENT_LIKE            = {(
        _ podcastType : String,
        _ conentID: Int)
        ->String in
        return "\(BASE_URL_COMMENT)\((podcastType == "PD") ? "/CommentLike/Create" : "/VideoCommentLike/CreateV3")/\(conentID)"
    }
    let UPDATE_REPLY_FAV               = {(
        _ podcastType : String,
        _ commentID :Int,
        _ replyID: Int)
        ->String in
        return "\(BASE_URL_COMMENT)/\((podcastType == "PD") ? "ReplyFavorite/Create" : "VideoReplyFavorite/CreateV3")/\(commentID)/\(replyID)"
    }
    let GET_ALL_ARTIST_PAGED           = {(
        _ page: Int)
        ->String in
        return "\(BASE_URL)/Artist/ArtistAllV6?pageNumber=\(page)"
    }
    let ARTIST_SEARCH                  = {(
        _ searchText: String)
        ->String in
        return "\(BASE_URL)/Artist/ArtistSearchv6?artistName=\(searchText)"}
    
    let POST_USER_HISTORY              = "\(BASE_URL)/useractivity/UserHistory"
    let POST_USER_PODCAST_HISTORY      = "\(BASE_URL)/Podcast/PodcastUserHistoryV3"
    
    let POST_USER_HISTORY_V6              = "\(BASE_CAMPAIGN_HISTORY_URL)/useractivity/UserHistoryV6"
    let POST_USER_PODCAST_HISTORY_V6      = "\(BASE_CAMPAIGN_HISTORY_URL)/Podcast/PodcastUserHistoryV6"
    let STREAMING_PLAY_HISTORY      = "https://connect.shadhinmusic.com/api/v1/useractivities/play-history"

    //MARK: - huda campaing
    let CAMPAIGN_RUNNING = "\(BASE_URL)/Ads/GetStreamAndWinCampaignDetails"
    let CAMPAIGN_ACTIVE = "\(BASE_URL_HOMEV3)/v1/campaigns/active"
    let CAMPAIGN_DETAILS = "\(BASE_URL_HOMEV3)/v1/campaigns/settings?id="
    let CAMPAIGN_DAILY = "\(BASE_URL_HOMEV3)/v1/campaigns/leaderboard?id="
    let CAMPAIGN_MONTHLY = "\(BASE_URL_HOMEV3)/v1/campaigns/leaderboard?id="
    
    static let NEWSUBSCRIPTION_BASE_URL = "https://connect.shadhinmusic.com/api/v1"
    
    let NEWSUBSCRIPTION_GET_PRODUCTS                 = {(
        _ msisdn: String,
        _ userCountryCode: String
        )->String in
        return "\(NEWSUBSCRIPTION_BASE_URL)/payment/products?Msisdn=\(msisdn)&LocationCode=\(userCountryCode)"
    }
    
    let NEWSUBSCRIPTION_GET_PAYMENT_OPTIONS                 = {(
        _ planName: String,
        _ userCountryCode: String
        )->String in
        return "\(NEWSUBSCRIPTION_BASE_URL)/payment/payment-methods?planName=\(planName)&locationCode=\(userCountryCode)"
    }
    
    let NEWSUBSCRIPTION_DETAILS = "\(NEWSUBSCRIPTION_BASE_URL)/payment/subscription-details"
    
    let GET_PLAN_DETAILS                = {(
        _ planId: String
    )->String in
        return "\(NEWSUBSCRIPTION_BASE_URL)/payment/payment-methods?planId=\(planId)"
    }
    
    static let GET_AI_MOOD_LIST = "\(AI_BASE_URL)/contents/moods"
    
    static let GET_AI_GENERATED_PLAY_LIST = {(
        _ MoodId: String, _ userCode: String)
        ->String in
        return "\(AI_BASE_URL)/contents/playlist/mood?MoodId=\(MoodId)&Usercode=\(userCode)"
    }
    
    let NEW_SEARCH_GET_TO_PLAYLIST = "\(BASE_URL_SEARCH_V2)/SearchLookup/GetTopPlayList?pageSize=20"
    let SEARCH_ALL_V2               = {(
        _ searchText: String, _ contentType: String)
        ->String in
        return "\(BASE_URL_SEARCH_V2)/SearchLookup/GetAllContentsByText?searchText=\(searchText)&contentType=\(contentType)"
    }
    
    let SEARCH_SPECIFIC_CONTENT_V2  = {(
        _ searchText: String, _ contentType: String)
        ->String in
        return "\(BASE_URL_SEARCH_V2)/SearchLookup/GetContentsByCategoryTypeAsync?searchText=\(searchText)&contentType=\(contentType)"
    }
    
    let GET_RESULT_FROM_DATABASE = {(
        _ searchText: String)
        ->String in
        return "\(BASE_URL_SEARCH_V2)/SearchLookup/GetSuggestionByText?searchText=\(searchText)"
    }
    
    let GET_RESULT_FROM_HISTORY = {(
        _ searchText: String, _ userCode:String)
        ->String in
        return "\(BASE_URL_SEARCH_V2)/SearchLookup/GetSuggestionByTextFromHistory?searchText=\(searchText)&userCode=\(userCode)"
    }
    
    let GET_UPDATED_SEARCH_RESULT_V2 = {(
        _ searchText: String, _ limit:String)
        ->String in
        return "\(BASE_URL_SEARCH_V2)/SearchLookup/GetSuggestionsBySearchKey?SearchText=\(searchText)&limit=\(limit)"
    }
    
    let GET_SEARCH_HISTORIES_V2 = {(
        _ userCode:String)
        ->String in
        return "\(BASE_URL_SEARCH_V2)/SearchLookup/GetSearchHistories?userCode=\(userCode)"
    }
    let POST_SEARCH_HISTORIES_V2 = {()
        -> String in
        return "\(BASE_URL_USER_SEARCH_TEXT)"
    }
    
    let CREATE_SEARCH_HISTORIES_V2 = {()
        -> String in
        return "\(BASE_URL_SEARCH_V2_History)/NewSearchHistory"
    }
    
    let DELETE_SEARCH_HISTORY_V2 = {(
        _ id: String, _ userCode:String)
        ->String in
        return "\(BASE_URL_SEARCH_V2_History)/DeleteSearchHistory?id=\(id)&userCode=\(userCode)"
    }
    
    let DELETE_ALL_SEARCH_HISTORY_V2 = {(
        _ userCode:String)
        ->String in
        return "\(BASE_URL_SEARCH_V2_History)/DeleteAllSearchHistory?userCode=\(userCode)"
    }
    
    
    // MARK: - AUDIO BOOKS
    static public let BASE_URL_AUDIO_BOOKS  =  "https://connect.shadhinmusic.com/api/v1"
    
    let GET_AUDIO_BOOK_REVIEWS = {(
        _ episodeId:String,
        _ userCode:String
    )
        ->String in
        return "\(BASE_URL_AUDIO_BOOKS)/contents/books/reviews?EpisodeId=\(episodeId)&Usercode=\(userCode)"
    }
    
    let GET_AUDIO_BOOK_REPLIES = {(
        _ reviewId:String,
        _ userCode:String
    )
        ->String in
        return "\(BASE_URL_AUDIO_BOOKS)/contents/books/replies?ReviewId=\(reviewId)&Usercode=\(userCode)"
    }

    let GET_RBT_PRODUCTS_GP_SDK = {( operatorName:String) -> String in
        return "\(BASE_URL_V1)/rbt/onmobile/products?operatorName=\(operatorName)"
    }

    let PURCHASE_RBT_COMBO = "\(BASE_URL_V1)/rbt/onmobile/purchase-combo"
    let GET_AUDIO_BOOK_DATA = {(
        _ bookId:String
    )
        ->String in
        return "\(BASE_URL_AUDIO_BOOKS)/contents/books/tracks?EpisodeId=\(bookId)"
    }
    
    let GET_AUTHOR_DETAILS = {(
        _ id:String
    )
        ->String in
        return "\(BASE_URL_AUDIO_BOOKS)/contents/books/artists?id=\(id)"
    }
    
    let GET_YOU_MIGHT_LIKE_BOOKS = {(
        _ EpisodeId:String
    )
        ->String in
        return "\(BASE_URL_AUDIO_BOOKS)/contents/books/episodes?artistId=\(EpisodeId)"
    }
    let GET_AUDIO_BOOK_CATAGORIES_BY_ID = {(
        _ CategoryId: String
    )
        -> String in
        return "\(BASE_URL_AUDIO_BOOKS)/contents/books/episodes?categoryId=\(CategoryId)"
    }
    let GET_AUDIO_PATCH_DETAILS = "\(BASE_URL_AUDIO_BOOKS)/contents/books/patches"
    let GET_PODCAST_NEW_PATCH = "https://connect.shadhinmusic.com/api/v1/contents/podcasts"
    let GET_STREAMING_HISTORY = "\(BASE_URL_AUDIO_BOOKS)/useractivities/books/streaming-history"
    let GET_TRACKS_COMPLETION_HISTORY = {(_ EpisodeId: String ) -> String in
        return "\(BASE_URL_AUDIO_BOOKS)/useractivities/books/tracks-completion?episodeId=\(EpisodeId)"
    }
    let POST_ADD_REVIEWS = "\(BASE_URL_AUDIO_BOOKS)/contents/books/reviews"

    let POST_ADD_REPLIES = "\(BASE_URL_AUDIO_BOOKS)/contents/books/replies"
  
    let POST_ADD_REACTION = "\(BASE_URL_AUDIO_BOOKS)/contents/books/reactions"
   
    let ADD_FOLLOW = "\(BASE_URL_AUDIO_BOOKS)/favorites"
   
    let ADD_UNFOLLOW = "\(BASE_URL_AUDIO_BOOKS)/favorites"
    
    let POST_USER_HISTORY_AUDIO_BOOk = "\(BASE_URL_AUDIO_BOOKS)/useractivities/play-history"
    
    let GP_EXPLORE_MUSICS       = "https://connect.shadhinmusic.com/api/v1/contents/home/gp-init-patches/"
    
  static let GET_RECOMANDED = "https://coreapi.shadhinmusic.com/api/v6/Recommendation/Patches"
    static let GET_RECOMANDED_V3 = {(_ days: String) -> String in
        return "https://connect.shadhinmusic.com/api/v1/personalization/based-on-recent-listenings?usercode=GB25018083&days=\(days)"
    }
    static let GET_PAGED_HOME = {(
         _ page: String)->String in
         return ShadhinApiURL().GET_PAGED_HOME_CONTENT(page)
     }
   static let GET_PAGED_HOMEV3 = {(
        _ page: String)->String in
       return ShadhinApiURL().GET_PAGED_HOME_CONTENTV3(page)
    }
}
