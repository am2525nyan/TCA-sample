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
        var youtubeAPIClient: YoutubeAPIClient
        var mainQueue: AnySchedulerOf<DispatchQueue>

        static let live = Self(
            twitchAPIClient: .live,
            youtubeAPIClient: .live,
            mainQueue: .main
        )
    }

    @ObservableState
    struct State {
        var twitchMovies: [TwitchMovie]? = []
        var youtubeMovie: YoutubeMovie? = nil
        var isLoading: Bool = false
        var errorMessage: String? = nil
        var movies: [Movie] = []
    }

    enum Action {
        case fetchMovies
        case fetchTwitchMoviesResponse(TaskResult<[TwitchMovie]>)
        case fetchYoutubeMoviesResponse(TaskResult<YoutubeMovie>)
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
                    await send(
                        .fetchYoutubeMoviesResponse(
                            TaskResult {
                                try await self.youtubeAPIClient.fetchMovie()
                            }))
                }

            case let .fetchTwitchMoviesResponse(.success(movies)):
                state.isLoading = false
                state.twitchMovies = movies  // 複数の映画データを格納
                print(movies, "a")
                for twitchMovie in movies {
                    let movie = Movie(
                        title: twitchMovie.title,
                        name: twitchMovie.name,
                        thumbnailUrl: twitchMovie.thumbnailUrl,
                        streamUrl: twitchMovie.streamUrl
                    )

                    state.movies.append(movie)
                    print(movie)
                }

                return .none
            case let .fetchTwitchMoviesResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none

            case let .fetchYoutubeMoviesResponse(.success(movie)):
                state.isLoading = false
                state.youtubeMovie = movie
                let movie = Movie(
                    title: state.youtubeMovie?.title ?? "",
                    name: state.youtubeMovie?.name ?? "",
                    thumbnailUrl: state.youtubeMovie?.thumbnailUrl ?? "",
                    streamUrl: state.youtubeMovie?.streamUrl ?? "")
                state.movies.append(movie)
                return .none

            case let .fetchYoutubeMoviesResponse(.failure(error)):
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
