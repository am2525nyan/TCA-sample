//
//  Twitch.swift
//  HaishinList
//
//  Created by saki on 2024/10/09.
//
import Alamofire
import Combine
import ComposableArchitecture
import Foundation

final class TwitchAPIClient: TwitchAPIClientProtocol {
    static let shared = TwitchAPIClient()
    private init() {
    }
}

extension TwitchAPIClient {

    func fetchMovies() async throws -> [TwitchMovie] {

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
                "805456112", "524474488", "25233449",
            ]
            var allMovies: [TwitchMovie] = []
            let group = DispatchGroup()

            for channelId in twitchUserIds {
                group.enter()

                url.queryItems = [
                    URLQueryItem(name: "user_id", value: channelId)
                ]

                AF.request(url, method: .get, headers: headers)
                    .responseData { [self] response in
                        defer { group.leave() }

                        if let statusCode = response.response?.statusCode {
                            print("Twitch Status Code: \(statusCode)")
                        }
                        switch response.result {
                        case .success(let data):
                            let decodeMovies =
                                decodeResponseData(data: data)

                            allMovies.append(contentsOf: decodeMovies)

                        case .failure(let error):
                            print("リクエスト失敗！", error.localizedDescription)
                        }
                    }
            }

            group.notify(queue: .main) {
                if allMovies.isEmpty {
                    print("誰も配信してません！")
                    continuation.resume(returning: [])
                } else {
                    continuation.resume(returning: allMovies)
                }
            }
        }
    }

    func decodeResponseData(data: Data) -> [TwitchMovie] {
        do {
            print("レスポンス:", String(data: data, encoding: .utf8) ?? "No data")
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
                    userLogin: streamData.user_login,
                    publishedAt: streamData.started_at
                )

            }
            return movies

        } catch {
            print("デコード失敗:", error.localizedDescription)
            return []
        }

    }

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
