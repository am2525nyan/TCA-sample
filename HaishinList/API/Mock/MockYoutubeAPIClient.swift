//
//  MockYoutubeAPIClient.swift
//  HaishinList
//
//  Created by saki on 2024/10/31.
//

import Foundation
class MockYoutubeAPIClient: YoutubeAPIClientProtocol {
    func fetchMovies(page: Int) async throws -> [YoutubeMovie] {
        let count = 10
        return  (0..<count).map { index in
            YoutubeMovie(
                title: "テストタイトル \(index + 1)",
                name: "テストさん",
                videoId: "zuo7RdUUcmE",
                thumbnailUrl: "https://pbs.twimg.com/media/GZmQiNIboAEfQHL?format=jpg&name=large",
                publishedAt: "2024-10-22T09:07:36Z"
            )
        }
    }
}
