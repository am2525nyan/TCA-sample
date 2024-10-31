//
//  MockTwitchAPIClient.swift
//  HaishinList
//
//  Created by saki on 2024/10/31.
//

import Foundation
final class MockTwitchAPIClient: TwitchAPIClientProtocol {
    static let shared = MockTwitchAPIClient()
    private init(){
        
    }
    
    func fetchMovies() async throws -> [TwitchMovie] {
        return [
            TwitchMovie(
                title: "テストタイトル", user_name: "テストさん",
                thumbnailUrl: "https://x.com/am2525nyan", userLogin: "saki",
                publishedAt: "2024-10-23T01:46:59Z")
        ]
    }
}
