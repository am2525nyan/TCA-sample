//
//  TwitchAPIClientProtocol.swift
//  HaishinList
//
//  Created by saki on 2024/10/31.
//

import Foundation

protocol TwitchAPIClientProtocol {
    func fetchMovies(page: Int) async throws -> [TwitchMovie]
}
