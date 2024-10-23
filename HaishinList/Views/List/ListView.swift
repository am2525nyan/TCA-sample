//
//  ListView.swift
//  HaishinList
//
//  Created by saki on 2024/10/20.
//
import ComposableArchitecture
import SwiftUI


struct ListView: View {
    let store: StoreOf<ListReducer>
    @Environment(\.openURL) private var openURL
    var body: some View {
        VStack {
            if store.movies != [] {
                List {
                    
                    ForEach(store.movies) { movie in
                        ListItemView(movie: movie, openURL: openURL)
                    }
                }
                .refreshable {
                    store.send(.fetchMovies, animation: .default)
                }
            } else {
                Text("データがありません")
            }
            Button("取得する") {
                store.send(.fetchMovies, animation: .default)
            }

        }
      
    }
}


