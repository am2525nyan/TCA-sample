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
    
    struct Environment {
        var twitchAPIClient: TwitchAPIClientProtocol
        var youtubeAPIClient: YoutubeAPIClientProtocol
        var mainQueue: AnySchedulerOf<DispatchQueue>
    }
    
    @ObservableState
    struct State {
        var twitchMovies: [TwitchMovie]? = []
        var youtubeMovie: [YoutubeMovie]? = []
        var isLoading: Bool = false
        var errorMessage: String? = nil
        var movies: [Movie] = []
        var page: Int = 0
        var lastPage: Bool = false
        
    }
    
    enum Action {
        case fetchMovies
        case fetchMoreMovies
        case fetchTwitchMoviesResponse(TaskResult<[TwitchMovie]>)
        case fetchYoutubeMoviesResponse(TaskResult<[YoutubeMovie]>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchMovies:
                state.isLoading = true
                state.errorMessage = ""
                state.movies = []
                state.youtubeMovie = []
                state.twitchMovies = []
                state.page = 1
                return .run { send in
                    do {
                        let (twitchReq, youtubeReq) = await (
                            try twitchAPIClient.fetchMovies(page: 1),
                            try youtubeAPIClient.fetchMovies(page: 1)
                        )
                        
                        await send(
                            .fetchTwitchMoviesResponse(.success(twitchReq)))
                        await send(
                            .fetchYoutubeMoviesResponse(.success(youtubeReq)))
                    } catch {
                        await send(.fetchTwitchMoviesResponse(.failure(error)))
                        await send(.fetchYoutubeMoviesResponse(.failure(error)))
                        print(error.localizedDescription)
                        
                    }
                }
            case .fetchMoreMovies:
                state.page += 1
                let nextPage = state.page
                if state.lastPage {
                    return .none
                }
                return .run { send in
                    do {
                        let (twitchReq, youtubeReq) = await (
                            try twitchAPIClient.fetchMovies(page: nextPage),
                            try youtubeAPIClient.fetchMovies(page: nextPage)
                        )
                        await send(
                            .fetchTwitchMoviesResponse(.success(twitchReq)))
                        await send(
                            .fetchYoutubeMoviesResponse(.success(youtubeReq)))
                    }catch {
                        await send(.fetchTwitchMoviesResponse(.failure(error)))
                        await send(.fetchYoutubeMoviesResponse(.failure(error)))
                        print(error.localizedDescription)
                        
                    }
                }
                
            case let .fetchTwitchMoviesResponse(.success(movies)):
                state.isLoading = false
                state.twitchMovies = movies
                for twitchMovie in movies {
                    let movie = Movie(
                        title: twitchMovie.title,
                        name: twitchMovie.name,
                        thumbnailUrl: twitchMovie.thumbnailUrl,
                        streamUrl: twitchMovie.streamUrl,
                        publishedAt: twitchMovie.publishedAt
                    )
                    
                    state.movies.append(movie)
                }
                
                return .none
            case let .fetchTwitchMoviesResponse(.failure(error)):
                state.isLoading = false
           state.lastPage = true
                state.errorMessage = error.localizedDescription
                return .none
                
            case let .fetchYoutubeMoviesResponse(.success(movies)):
                state.isLoading = false
                state.youtubeMovie = movies
                for youtubeMovie in movies {
                    let movie = Movie(
                        title: youtubeMovie.title,
                        name: youtubeMovie.name,
                        thumbnailUrl: youtubeMovie.thumbnailUrl,
                        streamUrl: youtubeMovie.streamUrl,
                        publishedAt: youtubeMovie.publishedAt)
                    state.movies.append(movie)
                }
                
                return .none
                
            case let .fetchYoutubeMoviesResponse(.failure(error)):
                state.isLoading = false
                state.lastPage = true
                state.errorMessage = error.localizedDescription
                return .none
            }
        }
    }
}

private enum TwitchAPIClientKey: DependencyKey {
    static let liveValue: TwitchAPIClientProtocol = TwitchAPIClient.shared
    static let previewValue: any TwitchAPIClientProtocol = MockTwitchAPIClient()
    
}
private enum YoutubeAPIClientKey: DependencyKey {
    static let liveValue: YoutubeAPIClientProtocol = YoutubeAPIClient.shared
    static let previewValue: any YoutubeAPIClientProtocol = MockYoutubeAPIClient()
}

extension DependencyValues {
    var twitchAPIClient: TwitchAPIClientProtocol {
        get { self[TwitchAPIClientKey.self] }
        set { self[TwitchAPIClientKey.self] = newValue }
    }
    var youtubeAPIClient: YoutubeAPIClientProtocol {
        get { self[YoutubeAPIClientKey.self] }
        set { self[YoutubeAPIClientKey.self] = newValue }
    }
}
