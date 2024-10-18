//
//  Youtube.swift
//  HaishinList
//
//  Created by saki on 2024/10/08.
//

import Alamofire
import ComposableArchitecture
import Foundation

struct YoutubeAPIClient {
    var fetchMovie: () async throws -> YoutubeMovie
}
extension YoutubeAPIClient {
    static let live = Self(
        fetchMovie: {
            let urlString =
                "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=UCu2Fxqf37DAZ0ZhIsd1FZwA&eventType=live&type=video&key=AIzaSyB1nlErMhG9T89Rr7HiPf5ZyUnNdDzCIwQ"

            return try await withCheckedThrowingContinuation { continuation in
                AF.request(urlString, method: .get)
                    .responseData { response in
                        if let statusCode = response.response?.statusCode {
                            print("Status Code: \(statusCode)")
                        }
                        print(response.result)
                        switch response.result {
                        case .success(let data):
                            do {

                                let decoder = JSONDecoder()
                                let youtubeResponse = try decoder.decode(
                                    YoutubeResponse.self, from: data)
                                print(youtubeResponse, "youtube")
                                let movies = youtubeResponse.items.map {
                                    streamData in
                                    YoutubeMovie(
                                        title: streamData.snippet.title,
                                        name: streamData.snippet.channelTitle, videoId: streamData.id.videoId,
                                        thumbnailUrl: streamData.snippet
                                            .thumbnails.high.url
                                    )

                                }
                                print("成功！", movies)
                                continuation.resume(returning: movies.first!)
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

        })
}

struct YoutubeResponse: Decodable {
    let items: [YouTubeItem]
}

struct YouTubeItem: Decodable {
    let id: ResourceId
    let snippet: YouTubeSnippet
}

struct YouTubeSnippet: Decodable {
    let publishedAt: String
    let channelId: String
    let title: String
    let description: String
    let thumbnails: Thumbnails
    let channelTitle: String
    let liveBroadcastContent: String
    let publishTime: String
}

struct Thumbnails: Decodable {
    let high: Thumbnail
}

struct Thumbnail: Decodable {
    let url: String
}

struct ResourceId: Decodable {
    let videoId: String
}
