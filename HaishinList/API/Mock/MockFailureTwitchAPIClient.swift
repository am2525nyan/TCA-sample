//
//  MockFailureTwitchAPIClient.swift
//  HaishinList
//
//  Created by saki on 2024/11/07.
//

import Foundation

class MockFailureTwitchAPIClient: TwitchAPIClientProtocol {
    func fetchMovies(page: Int) async throws -> [TwitchMovie] {
        throw APIError.invalidURL
    }
}
