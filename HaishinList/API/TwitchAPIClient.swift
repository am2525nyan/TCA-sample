
//
//  Twitch.swift
//  HaishinList
//
//  Created by saki on 2024/10/09.
//
import Combine
import ComposableArchitecture
import Foundation
import Alamofire

struct TwitchAPIClient {
    let accessToken = "36f8wvix1lupsvy8q6wlab9w6dll5"
    let clientId = "k1p1y8bhkrjvps84wlodei5fe67696"
    let userId = "136255354"
    var fetchMovie: () async throws -> TwitchMovie

}

extension TwitchAPIClient {
    static let live = Self(
        fetchMovie: {
            let env = try! LoadEnv()
            var url = URLComponents()
            url.scheme = "https"
            url.host = "api.twitch.tv"
            url.path = "/helix/streams"
            url.queryItems = [
                URLQueryItem(name: "user_id", value:  "44525650"),]
         
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(env.value("TWITCH_ACCESS_TOKEN")!)",
                "Client-Id": "k1p1y8bhkrjvps84wlodei5fe67696",
            ]
            print(env.value("TWITCH_ACCESS_TOKEN")!)
            return try await withCheckedThrowingContinuation { continuation in
                AF.request(url, method: .get, headers: headers)
                    .responseData { response in
                        if let statusCode = response.response?.statusCode {
                            print("Status Code: \(statusCode)")
                        }
                        switch response.result {
                        case .success(let data):
                            do {
                                if let jsonString = String(data: data, encoding: .utf8) {
                                                   print("Received Error Response: \(jsonString)")
                                               }
                                let decoder = JSONDecoder()
                                let twitchResponse = try decoder.decode(
                                    TwitchResponse.self, from: data)
                                print(twitchResponse)
                                let movies = twitchResponse.data.map {
                                    streamData in
                                    TwitchMovie(
                                        title: streamData.title,
                                        user_name: streamData.user_name,
                                        thumbnailUrl: streamData.thumbnail_url
                                            .replacingOccurrences(
                                                of: "{width}x{height}",
                                                with: "1920x1080"),
                                        userLogin: streamData.user_login
                                    )

                                }
                                print("成功！", movies)
                                if movies.isEmpty{
                                    continuation.resume(
                                        throwing: APIError.invalidData
                                    )
                                }else{
                                    continuation.resume(returning: movies.first!)
                                }
                                
                            } catch {
                            
                                print("デコード失敗:", error.localizedDescription)
                                continuation.resume(
                                    throwing: APIError.decodingError(error))
                            }

                        case .failure(let error):
                            print("失敗！", error.localizedDescription)
                            continuation.resume(
                                throwing: APIError.invalidResponse(error))
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
