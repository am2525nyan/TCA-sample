//
//  ListView.swift
//  HaishinList
//
//  Created by saki on 2024/10/08.
//

import SwiftUI
import ComposableArchitecture

struct ListView: View {
    let store: StoreOf<ListReducer>
    @Environment(\.openURL) private var openURL
    var body: some View {
        VStack{
            if store.movie != nil{
                AsyncImage(url: URL(string: store.movie?.thumbnailUrl ?? "https://pbs.twimg.com/media/GZmQiNIboAEfQHL?format=jpg&name=large")){ image in
                    
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            openURL(URL(string: store.movie?.streamUrl ?? "https://x.com/home")!)
                        }
                } placeholder: {
                    ProgressView()
                }
                .padding(.bottom,10)
         
            Text(store.movie?.title ?? "取得失敗しました")
                .padding(.bottom, 4)
            Text(store.movie?.user_name ?? "取得失敗しました")
                .padding(.bottom, 10)
            }
            Button("取得する"){
                store.send(.fetchMovies,animation: .default)
            }

       
        }
        .padding(.horizontal, 20)
    }
}


