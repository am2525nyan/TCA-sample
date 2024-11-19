//
//  MockTwitchAPIClient.swift
//  HaishinList
//
//  Created by saki on 2024/10/31.
//

import Foundation
class MockTwitchAPIClient: TwitchAPIClientProtocol {
    func fetchMovies(page: Int) async throws -> [TwitchMovie] {
        return (0...10).map { _ in
            TwitchMovie(
                title: "テストタイトル",
                user_name: "テストさん",
                thumbnailUrl: "https://pbs.twimg.com/media/GbIVi6uaUAAnO_U?format=jpg&name=large",
                userLogin: "saki",
                publishedAt: "2024-10-23T01:46:59Z"
            )
        }

    }
}
