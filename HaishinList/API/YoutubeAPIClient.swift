//
//  Youtube.swift
//  HaishinList
//
//  Created by saki on 2024/10/08.
//
import Alamofire
import ComposableArchitecture
import Foundation

final class YoutubeAPIClient: YoutubeAPIClientProtocol {
    
    static let shared = YoutubeAPIClient()

      private init() {}
    
}

extension YoutubeAPIClient {
    func fetchMovies() async throws -> [YoutubeMovie] {
        
        let env = try! LoadEnv()
        var urlString = URLComponents()
        urlString.scheme = "https"
        urlString.host = "www.googleapis.com"
        urlString.path = "/youtube/v3/search"
        
        let channelIds = [
            "UCPkKpOHxEDcwmUAnRpIu-Ng", "UCfipDDn7wY-C-SoUChgxCQQ",
            "UCWQtYtq9EOB4-I5P-3fh8lA", "UCj4PjeVMnNTHIR5EeoNKPAw",
            "UChLfthKoUV502J7gU9STArg", "UCZlDXzGoo7d44bwdNObFacg",
        ]
        
        var allMovies: [YoutubeMovie] = []
        let group = DispatchGroup()
        
        return try await withCheckedThrowingContinuation { continuation in
            for channelId in channelIds {
                group.enter()
                
                urlString.queryItems = [
                    URLQueryItem(name: "part", value: "snippet"),
                    URLQueryItem(name: "channelId", value: channelId),
                    URLQueryItem(name: "eventType", value: "live"),
                    URLQueryItem(name: "type", value: "video"),
                    URLQueryItem(
                        name: "key",
                        value: "\(env.value("YOUTUBE_API_KEY")!)"),
                ]
                
                AF.request(urlString, method: .get)
                    .responseData { response in
                        defer { group.leave() }
                        
                        if let statusCode = response.response?.statusCode {
                            print("Youtube Status Code: \(statusCode)")
                        }
                        
                        switch response.result {
                        case .success(let data):
                            do {
                                let movies =
                                try YoutubeAPIClient.decodeResponseData(
                                    data: data)
                                allMovies.append(contentsOf: movies)
                                
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
            
            group.notify(queue: .main) {
                if allMovies.isEmpty {
                    continuation.resume(throwing: APIError.invalidData)
                } else {
                    continuation.resume(returning: allMovies)
                }
            }
        }
    }
    static func decodeResponseData(data: Data) throws -> [YoutubeMovie] {

        let decoder = JSONDecoder()
        let youtubeResponse = try decoder.decode(
            YoutubeResponse.self, from: data)
        let movies = youtubeResponse.items.map { streamData in
            YoutubeMovie(
                title: streamData.snippet.title,
                name: streamData.snippet.channelTitle,
                videoId: streamData.id.videoId,
                thumbnailUrl: streamData.snippet.thumbnails.high.url,
                publishedAt: streamData.snippet.publishedAt
            )
        }
        return movies
    }

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
