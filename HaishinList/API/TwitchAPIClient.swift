//
//  Twitch.swift
//  HaishinList
//
//  Created by saki on 2024/10/09.
//
import Combine
import Alamofire
import ComposableArchitecture
import Foundation


struct TwitchAPIClient {
    let accessToken = "36f8wvix1lupsvy8q6wlab9w6dll5"
    let clientId = "k1p1y8bhkrjvps84wlodei5fe67696"
    let userId = "726693099"
    var fetchMovie: () async throws -> TwitchMovie
    
}

extension TwitchAPIClient {
    static let live = Self(
        fetchMovie: {
            let urlString = "https://api.twitch.tv/helix/streams?user_id=205775893"
            let headers: HTTPHeaders = [
                "Authorization": "Bearer 2ebbs1l05ii5zbfq1i0g4pacvhxrdc",
                "Client-Id": "k1p1y8bhkrjvps84wlodei5fe67696"
            ]
            
            return try await withCheckedThrowingContinuation { continuation in
                AF.request(urlString, method: .get, headers: headers)
                    .responseData { response in
                        if let statusCode = response.response?.statusCode {
                            print("Status Code: \(statusCode)")
                        }
                        switch response.result {
                        case .success(let data):
                            do {
                                
                                print(data)
                                
                                let decoder = JSONDecoder()
                                let twitchResponse = try decoder.decode(TwitchResponse.self, from: data)
                                print(twitchResponse)
                                let movies = twitchResponse.data.map { streamData in
                                    TwitchMovie(
                                        title: streamData.title,
                                        user_name: streamData.user_name,
                                        thumbnailUrl: streamData.thumbnail_url.replacingOccurrences(of: "{width}x{height}", with: "1920x1080"),
                                        userLogin: streamData.user_login
                                    )
                                    
                                }
                                print("成功！", movies)
                                continuation.resume(returning: movies.first!)
                            } catch {
                                print("デコード失敗:", error.localizedDescription)
                                continuation.resume(throwing: APIError.decodingError(error))
                            }
                            
                        case .failure(let error):
                            print("失敗！", error.localizedDescription)
                            continuation.resume(throwing: APIError.invalidResponse(error))
                        }
                    }
            }
        }
    )
}


struct TwitchStreamData: Decodable {
    let title: String
    let user_name: String
    let thumbnail_url: String
    let user_login: String
}

struct TwitchResponse: Decodable {
    let data: [TwitchStreamData]
}
