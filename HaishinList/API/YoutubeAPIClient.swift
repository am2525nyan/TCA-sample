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
            let env = try! LoadEnv()
            var urlString = URLComponents()
            urlString.scheme = "https"
            urlString.host = "www.googleapis.com"
            urlString.path = "/youtube/v3/search"
            urlString.queryItems = [
                URLQueryItem(name: "part", value: "snippet"),
                URLQueryItem(name: "channelId", value: "UCY_10f4ef0e1T2skAbHBQTg"),
                URLQueryItem(name: "eventType", value: "live"),
                URLQueryItem(name: "type", value: "video"),
                URLQueryItem(name: "key", value: "\(env.value("YOUTUBE_API_KEY")!)")]
         
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
                                if let jsonString = String(data: data, encoding: .utf8) {
                                                   print("Received Error Response: \(jsonString)")
                                               }
    
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
