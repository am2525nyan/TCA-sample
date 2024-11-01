//
//  MockYoutubeAPIClient.swift
//  HaishinList
//
//  Created by saki on 2024/10/31.
//

import Foundation
class MockYoutubeAPIClient: YoutubeAPIClientProtocol {
    func fetchMovies() async throws -> [YoutubeMovie] {
        return [
            YoutubeMovie(
                title: "テスト", name: "テストさん", videoId: "zuo7RdUUcmE",
                thumbnailUrl: "https://pbs.twimg.com/media/GZmQiNIboAEfQHL?format=jpg&name=large",
                publishedAt: "2024-10-22T09:07:36Z"
            )
        ]
    }
}
