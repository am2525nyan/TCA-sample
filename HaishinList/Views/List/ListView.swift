//
//  ListView.swift
//  HaishinList
//
//  Created by saki on 2024/10/20.
//
import ComposableArchitecture
import SwiftUI

struct ListView: View {
    var store: StoreOf<ListReducer>

    var body: some View {
        VStack {
            if store.movies != [] {
                List {
                    ForEach(store.movies) { movie in
                        ListItemView(movie: movie)
                            .onAppear(){
                                if store.movies.last == movie {
                                    store.send(.fetchMoreMovies, animation: .default)
                                }
                            }
                    }
                }
                .refreshable {
                    store.send(.fetchMovies, animation: .default)
                }
            } else {
                Text("データがありません")
                Button("取得する") {
                    store.send(.fetchMovies, animation: .default)
                }
            }

        }
        .onAppear {
            store.send(.fetchMovies, animation: .default)
        }

    }
}
//データ取得成功した場合
#Preview("成功の場合") {
    ListView(
        store: .init(
            initialState: ListReducer.State(),
            reducer: {
                ListReducer()
            }
        )
    )
}

//データ取得失敗した場合
#Preview("失敗の場合") {
    ListView(
        store: .init(
            initialState: ListReducer.State(),
            reducer: {
                ListReducer()
            }
        ) {
            withDependencies: do {
                $0.twitchAPIClient = MockFailureTwitchAPIClient()
                $0.youtubeAPIClient = MockFailureYoutubeAPIClient()
            }
        }
    )
}
