//
//  MockFailureYoutubeAPIClient.swift
//  HaishinList
//
//  Created by saki on 2024/11/07.
//

import Foundation

class MockFailureYoutubeAPIClient: YoutubeAPIClientProtocol {
    func fetchMovies() async throws -> [YoutubeMovie] {
        throw APIError.invalidURL
    }
}
