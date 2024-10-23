import Alamofire
//
//  Twitch.swift
//  HaishinList
//
//  Created by saki on 2024/10/09.
//
import Combine
import ComposableArchitecture
import Foundation

struct TwitchAPIClient {
    var fetchMovie: () async throws -> [TwitchMovie]

}

extension TwitchAPIClient {
    static let live = Self(
        fetchMovie: {
            let env = try! LoadEnv()
            var url = URLComponents()
            url.scheme = "https"
            url.host = "api.twitch.tv"
            url.path = "/helix/streams"

            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(env.value("TWITCH_ACCESS_TOKEN")!)",
                "Client-Id": "k1p1y8bhkrjvps84wlodei5fe67696",
            ]

            return try await withCheckedThrowingContinuation { continuation in
                let twitchUserIds = [
                    "44525650", "598495509", "161835870", "113028874",
                ]
                var allMovies: [TwitchMovie] = []
                let group = DispatchGroup()

                for channelId in twitchUserIds {
                    group.enter()

                    url.queryItems = [
                        URLQueryItem(name: "user_id", value: channelId)
                    ]

                    AF.request(url, method: .get, headers: headers)
                        .responseData { response in
                            defer { group.leave() }

                            if let statusCode = response.response?.statusCode {
                                print("Status Code: \(statusCode)")
                            }
                            switch response.result {
                            case .success(let data):
                                do {
                                    if let jsonString = String(
                                        data: data, encoding: .utf8)
                                    {
                                        print(
                                            "Received Response: \(jsonString)")
                                    }
                                    let decoder = JSONDecoder()
                                    let twitchResponse = try decoder.decode(
                                        TwitchResponse.self, from: data)
                                    let movies = twitchResponse.data.map {
                                        streamData in
                                        TwitchMovie(
                                            title: streamData.title,
                                            user_name: streamData.user_name,
                                            thumbnailUrl: streamData
                                                .thumbnail_url
                                                .replacingOccurrences(
                                                    of: "{width}x{height}",
                                                    with: "1920x1080"),
                                            userLogin: streamData.user_login, publishedAt: streamData.started_at
                                        )
                                    }

                                    allMovies.append(contentsOf: movies)
                                } catch {
                                    print("デコード失敗:", error.localizedDescription)
                                }
                            case .failure(let error):
                                print("リクエスト失敗！", error.localizedDescription)
                            }
                        }
                }

                group.notify(queue: .main) {
                    if allMovies.isEmpty {
                        continuation.resume(throwing: APIError.invalidData)
                    } else {
                        continuation.resume(returning: allMovies)
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
    let started_at: String
}

struct TwitchResponse: Decodable {
    let data: [TwitchStreamData]
}
