//
//  PodcastUpdateAPI.swift
//  Shadhin_Gp
//
//  Created by Maruf on 15/2/26.
//

import Foundation

extension ShadhinApi {

    func getPodcastPatchDetails(
        completion : @escaping (PodcastVersionTwoResponse?, Error?) -> Void)
    {
        AF.request(
            GET_PODCAST_NEW_PATCH,
            method: .get,
            encoding: JSONEncoding.default,
            headers: ShadhinApiContants().API_HEADER
        )
        .validate()
        .responseDecodable(of: PodcastVersionTwoResponse.self){ response in
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

    func getPodcastDetails(
        podcastType: String,
        contentType: String,
        episodeId: Int,
        completion: @escaping (Result<PodcastVersionTwoResponseNew, Error>) -> Void
    ) {
        let baseURL = "https://connect.shadhinmusic.com/api/v1/contents/podcasts/episodes"
        let parameters: Parameters = [
            "ContentType": contentType,
            "PodcastType": podcastType
        ]

        AF.request(baseURL, method: .get, parameters: parameters)
            .responseData { response in
                switch response.result {

                case .success(let data):
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("📦 Raw JSON Response:\n\(jsonString)")
                    }
                    do {
                        let decoded = try JSONDecoder().decode(PodcastVersionTwoResponseNew.self, from: data)
                        completion(.success(decoded))
                    } catch {
                        print("❌ Decoding Error: \(error)")
                        completion(.failure(error))
                    }

                case .failure(let error):
                    if let data = response.data,
                       let rawString = String(data: data, encoding: .utf8) {
                        print("⚠️ Network Error Response:\n\(rawString)")
                    }
                    print("❌ Network Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
    }

    
    func getPodcastTracksDetails(
        podcastType: String,
        contentType: String,
        episodeId: Int,
        completion: @escaping (Result<PodcastVersionTwoResponseNew, Error>) -> Void
    ) {
        let baseURL = "https://connect.shadhinmusic.com/api/v1/contents/podcasts/tracks"
        let parameters: Parameters = [
            "PodcastType": podcastType,
            "ContentType": contentType,
            "EpisodeId": episodeId
        ]
        
        AF.request(baseURL, method: .get, parameters: parameters)
            .responseData { response in
                switch response.result {

                case .success(let data):
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("📦 Raw JSON Response:\n\(jsonString)")
                    }
                    do {
                        let decoded = try JSONDecoder().decode(PodcastVersionTwoResponseNew.self, from: data)
                        completion(.success(decoded))
                    } catch {
                        print("❌ Decoding Error: \(error)")
                        completion(.failure(error))
                    }

                case .failure(let error):
                    if let data = response.data,
                       let rawString = String(data: data, encoding: .utf8) {
                        print("⚠️ Network Error Response:\n\(rawString)")
                    }
                    print("❌ Network Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
    }


    func getCommentBy(
        contentId: String,
        contentType: String,
        pageNumber: Int,
        completion: @escaping (Result<CommentResponse, Error>) -> Void
    ) {
        let url = "https://comments.shadhinmusic.com/api/v5/Comment/GetListV2/\(contentId)/\(contentType)/\(pageNumber)"

        AF.request(url, method: .get)
            .validate()
            .responseDecodable(of: CommentResponse.self) { response in
                switch response.result {
                case .success(let commentData):
                    completion(.success(commentData))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
