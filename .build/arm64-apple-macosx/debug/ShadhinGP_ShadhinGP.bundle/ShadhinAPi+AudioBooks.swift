//
//  ShadhinAPi+AudioBooks.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 11/6/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi {
    
    func getAudioBookReviews(userCode: String, episodeId: String,
                             _ completion : @escaping (_ responseModel: Result<AudioBookReviewsResponse,AFError> )->()){
        AF.request(
            GET_AUDIO_BOOK_REVIEWS(episodeId, userCode),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: AudioBookReviewsResponse.self) { response in
            completion(response.result)
        }
    }
    func getAudioBookReplies(userCode: String, reviewId: String,
                             _ completion : @escaping (_ responseModel: Result<AudioBookReplyResponse,AFError> )->()){
        AF.request(
            GET_AUDIO_BOOK_REPLIES(reviewId, userCode),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: AudioBookReplyResponse.self) { response in
            completion(response.result)
        }
    }
    
    
    func getAudioBookData(episodeId: String,
                          _ completion : @escaping (_ responseModel: Result<AudiobBookResponseModel,AFError> )->()){
        print(GET_AUDIO_BOOK_DATA(episodeId))
        
        AF.request(
            GET_AUDIO_BOOK_DATA(episodeId),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: AudiobBookResponseModel.self) { response in
            completion(response.result)
        }
    }
    
    func getYouMightLikeAudioBooks(episodeId: String,
                                   _ completion : @escaping (_ responseModel: Result<SimilerBooksResponseModel,AFError> )->()){
        
        AF.request(
            GET_YOU_MIGHT_LIKE_BOOKS(episodeId),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: SimilerBooksResponseModel.self) { response in
            completion(response.result)
        }
    }
    
    func getAuthorDetails(artistId: String,
                          _ completion : @escaping (_ responseModel: Result<AuthorDetailsRootResponse,AFError> )->()){
        AF.request(
            GET_AUTHOR_DETAILS(artistId),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: AuthorDetailsRootResponse.self) { response in
            completion(response.result)
        }
    }
    
    func getAudioPatchDetails(
        completion : @escaping (AudioPatchHomeModel?, Error?) -> Void)
    {
        AF.request(
            GET_AUDIO_PATCH_DETAILS,
            method: .get,
            encoding: JSONEncoding.default,
            headers: ShadhinApiContants().API_HEADER
        )
        .validate()
        .responseDecodable(of: AudioPatchHomeModel.self){ response in
            switch response.result{
            case let .success(data):
                completion(data,nil)
            case .failure(_):
                let error = NSError(domain: "", code: 500, userInfo: [ NSLocalizedDescriptionKey: "experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                completion(nil,error)
                print(response.error?.localizedDescription as Any)
                
            }
        }
    }
    
    func getAudioBooksCatagories(catagoryId: String,
                                 _ completion : @escaping (_ responseModel: Result<AudioBookCatagoriesResponseModel,AFError> )->()){
        AF.request(
            GET_AUDIO_BOOK_CATAGORIES_BY_ID(catagoryId),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: AudioBookCatagoriesResponseModel.self) { response in
            completion(response.result)
        }
    }
    
    func getStreamingHistory(_ completion : @escaping (_ responseModel: Result<StreamingHistoryResponse,AFError> )->()){
        AF.request(
            GET_STREAMING_HISTORY,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: StreamingHistoryResponse.self) { response in
            if let statusCode = response.response?.statusCode, !(200...299).contains(statusCode) {
                print("HTTP Status Code Error: \(statusCode)")
            }
            completion(response.result)
        }
    }
    
    func getTrackComplrtionHistory(episodeId: String,
                                   _ completion : @escaping (_ responseModel: Result<AudioBookProgressResponse,AFError> )->()){
        
        AF.request(
            GET_TRACKS_COMPLETION_HISTORY(episodeId),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: AudioBookProgressResponse.self) { response in
            completion(response.result)
        }
    }
    
    func addReview(
        _ review: AudioBookReviews,
        completion: @escaping (_ response: AudioBookReviewResponse?, _ errorMsg: String?) -> Void
    ) {
        guard let body = review.toDictionary() else {
            completion(nil, "Failed to encode review data.")
            return
        }
        
        let url = POST_ADD_REVIEWS  // Replace with your actual endpoint
        
        AF.request(
            url,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: AudioBookReviewResponse.self) { response in
            switch response.result {
            case .success(let reviewResponse):
                // Check success flag in the response
                if reviewResponse.success {
                    completion(reviewResponse, nil)
                } else {
                    // Handle error message if success is false
                    let errorMsg = reviewResponse.error?.message ?? "An error occurred. Please try again."
                    completion(nil, errorMsg)
                }
                
            case .failure(let error):
                completion(nil, "Network request failed: \(error.localizedDescription)")
            }
        }
    }
    
    func addReplies(
        _ review: AudioBookReviewReplyRequest,
        completion: @escaping (_ response: AudioBookReviewReplyResponse?, _ errorMsg: String?) -> Void
    ) {
        guard let body = review.toDictionary() else {
            completion(nil, "Failed to encode review data.")
            return
        }
        
        let url = POST_ADD_REPLIES  // Replace with your actual endpoint
        
        AF.request(
            url,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: AudioBookReviewReplyResponse.self) { response in
            switch response.result {
            case .success(let reviewResponse):
                // Check success flag in the response
                if reviewResponse.success {
                    completion(reviewResponse, nil)
                } else {
                    // Handle error message if success is false
                    let errorMsg = reviewResponse.error?.message ?? "An error occurred. Please try again."
                    completion(nil, errorMsg)
                }
                
            case .failure(let error):
                completion(nil, "Network request failed: \(error.localizedDescription)")
            }
        }
    }
    
    func addReaction(_ reviewId: String,_ tobeDeleted:Bool,
                     _ completion: @escaping (_ response: AudioBookReactionResponse?, _ errorMsg: String?) -> Void
    ) {
        let body: [String: Any] = [
            "reviewId": reviewId,
            "usercode": ShadhinCore.instance.defaults.userMsisdn,
            "toBeDeleted": tobeDeleted
        ]
        
        let url = POST_ADD_REACTION  // Replace with your actual endpoint
        AF.request(
            url,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: AudioBookReactionResponse.self) { response in
            switch response.result {
            case .success(let reviewResponse):
                // Check success flag in the response
                if reviewResponse.success {
                    completion(reviewResponse, nil)
                } else {
                    // Handle error message if success is false
                    let errorMsg = reviewResponse.error?.message ?? "An error occurred. Please try again."
                    completion(nil, errorMsg)
                }
                
            case .failure(let error):
                completion(nil, "Network request failed: \(error.localizedDescription)")
            }
        }
    }
    
    func addFollow(
        _ content: AuthorDetailsParentContent,
        _ completion: @escaping (_ response: FollowResponse?, _ errorMsg: String?) -> Void
    ) {
        // Endpoint URL
        let url = ADD_FOLLOW
        
        // Map `content` to a dictionary
        let body: [String: Any] = [
            "artists": content.audioBook.authors.map { [
                "id": $0.id,
                "image": $0.image,
                "name": $0.name
            ] },
            "audioBook": [
                "authorDisplayName":"",
                "authors": content.audioBook.authors.map { [
                    "booksCount": $0.booksCount,
                    "id": $0.id,
                    "image": $0.image,
                    "name": $0.name,
                    "role": $0.role
                ] },
                "categories": content.audioBook.categories,
                "completionPercentage":0,
                "contentSubType": content.audioBook.contentSubType,
                "currentDurationCursor":0,
                "duration": content.audioBook.duration,
                "isCommentPaid": content.audioBook.isCommentPaid,
                "narrators":[],
                "rating": content.audioBook.rating,
                "reviewsCount": content.audioBook.reviewsCount,
                "voiceArtists": content.audioBook.voiceArtists
            ],
            "contentId": content.contentId,
            "contentType": content.contentType,
            "details": content.details,
            "genres": content.genres,
            "imageUrl": content.imageUrl,
            "imageWebUrl": content.imageWebUrl,
            "isPaid": content.isPaid,
            "likeCount": content.likeCount,
            "moods": content.moods,
            "sort": content.sort,
            "streamingCount": content.streamingCount,
            "titleBn": content.titleBn,
            "titleEn": content.titleEn
        ]
        
        // Create request
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [body])
        request.headers = API_HEADER
        
        // Send request using Alamofire
        AF.request(request).responseDecodable(of: FollowResponse.self) { response in
            switch response.result {
            case .success(let followResponse):
                // Check success flag in the response
                if followResponse.success {
                    completion(followResponse, nil)
                } else {
                    // Handle error message if success is false
                    let errorMsg = followResponse.error ?? "An error occurred. Please try again."
                    completion(nil, errorMsg)
                }
            case .failure(let error):
                completion(nil, "Network request failed: \(error)")
            }
        }
    }
    
    
    func addUnfollow(_ contentId: String,
                     _ completion: @escaping (_ response: UnfollowResponse?, _ errorMsg: String?) -> Void
    ) {

        let body: [String: Any] = [
            "contentId": contentId,
            "contentType":"BK"
        ]
        
        let url = ADD_UNFOLLOW  // Replace with your actual endpoint
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [body])
        request.headers = API_HEADER
        AF.request(request).responseDecodable(of: UnfollowResponse.self) { response in
            switch response.result {
            case .success(let reviewResponse):
                // Check success flag in the response
                if reviewResponse.success {
                    completion(reviewResponse, nil)
                } else {
                    // Handle error message if success is false
                    let errorMsg = reviewResponse.error ?? "An error occurred. Please try again."
                    completion(nil, errorMsg)
                }
                
            case .failure(let error):
                completion(nil, "Network request failed: \(error)")
            }
        }
    }
    
    func trackUserHistoryAudioBook(
        _ modelFromHistory : AudioBookModelHistory,
        _ modelFromTrack: AudioBookTrack,
        completion: @escaping (_ response: HistoryTrackAPIResponse?, _ errorMsg: String?) -> Void
    ) {
        // Convert both models to dictionaries
        guard
            let historyDict = modelFromHistory.toDictionary(),
            let trackDict = modelFromTrack.toDictionary()
        else {
            completion(nil, "Failed to encode data.")
            return
        }
        
        // Merge the two dictionaries
        var body = historyDict
        for (key, value) in trackDict {
            body[key] = value
        }
        
        let url = POST_USER_HISTORY_AUDIO_BOOk  // Replace with your actual endpoint
        
        AF.request(
            url,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: HistoryTrackAPIResponse.self) { response in
            switch response.result {
            case .success(let reviewResponse):
                // Check success flag in the response
                if reviewResponse.success {
                    completion(reviewResponse, nil)
                } else {
                    // Handle error message if success is false
                    let errorMsg = reviewResponse.error ?? "An error occurred. Please try again."
                    completion(nil, errorMsg)
                }
            case .failure(let error):
                completion(nil, "Network request failed: \(error.localizedDescription)")
            }
        }
    }
}


