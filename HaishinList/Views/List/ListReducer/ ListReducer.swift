//
//   ListReducer.swift
//  HaishinList
//
//  Created by saki on 2024/10/08.
//

import ComposableArchitecture
import Foundation

@Reducer
struct ListReducer {
    @Dependency(\.twitchAPIClient) var twitchAPIClient
    @Dependency(\.youtubeAPIClient) var youtubeAPIClient
    @ObservableState
    struct Environment {
        var twitchAPIClient: TwitchAPIClient
        var mainQueue: AnySchedulerOf<DispatchQueue>

        static let live = Self(
            twitchAPIClient: .live,
            mainQueue: .main
        )
    }

    @ObservableState
    struct State {
        var movie: TwitchMovie? = nil
        var isLoading: Bool = false
        var errorMessage: String? = nil
    }

    enum Action {
        case fetchMovies
        case fetchTwitchMoviesResponse(TaskResult<TwitchMovie>)

    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchMovies:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    await send(
                        .fetchTwitchMoviesResponse(
                            TaskResult {
                                try await self.twitchAPIClient.fetchMovie()
                            }))
                }

            case let .fetchTwitchMoviesResponse(.success(movie)):
                state.isLoading = false
                state.movie = movie
                return .none

            case let .fetchTwitchMoviesResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
            }
        }
    }
}

private enum TwitchAPIClientKey: DependencyKey {
    static let liveValue = TwitchAPIClient.live

}
private enum YoutubeAPIClientKey: DependencyKey {
    static let liveValue = YoutubeAPIClient.live

}

extension DependencyValues {
    var twitchAPIClient: TwitchAPIClient {
        get { self[TwitchAPIClientKey.self] }
        set { self[TwitchAPIClientKey.self] = newValue }
    }
    var youtubeAPIClient: YoutubeAPIClient {
        get { self[YoutubeAPIClientKey.self] }
        set { self[YoutubeAPIClientKey.self] = newValue }
    }
}
