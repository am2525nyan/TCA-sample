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
                "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=UCu2Fxqf37DAZ0ZhIsd1FZwA&type=video"
            return try await withCheckedThrowingContinuation { continuation in
                AF.request(urlString, method: .get)
                    .responseData { response in
                        if let statusCode = response.response?.statusCode {
                            print("Status Code: \(statusCode)")
                        }
                        switch response.result {
                        case .success(let data):
                            do {

                                print(data)

                                let decoder = JSONDecoder()
                                let youtubeResponse = try decoder.decode(
                                    YoutubeResponse.self, from: data)
                                print(youtubeResponse)
                                let movies = youtubeResponse.items.map {
                                    streamData in
                                    YoutubeMovie(
                                        title: streamData.snippet.title,
                                        videoId: streamData.channnelTitle,
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

struct YoutubeStreamData: Decodable {
    let title: String
    let user_name: String
    let thumbnail_url: String

}

struct YoutubeResponse: Decodable {
    let items: [YouTubeItem]
}
struct YouTubeItem: Decodable {
    let snippet: YouTubeSnippet
    let id: ResourceId
    let channnelTitle: String
}
struct YouTubeSnippet: Decodable {
    let title: String
    let liveBroadcastContent: String
    let thumbnails: Thumbnails
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
