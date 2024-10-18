//
//  ListView.swift
//  HaishinList
//
//  Created by saki on 2024/10/08.
//

import SwiftUI
import ComposableArchitecture

struct ListItemView: View {
    let store: StoreOf<ListReducer>
    @Environment(\.openURL) private var openURL
    var body: some View {
        VStack{
            if store.twitchMovie != nil{
                AsyncImage(url: URL(string: store.twitchMovie?.thumbnailUrl ?? "https://pbs.twimg.com/media/GZmQiNIboAEfQHL?format=jpg&name=large")){ image in
                    
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            openURL(URL(string: store.twitchMovie?.streamUrl ?? "https://x.com/home")!)
                        }
                } placeholder: {
                    ProgressView()
                }
                .padding(.bottom,10)
         
            Text(store.twitchMovie?.title ?? "取得失敗しました")
                .padding(.bottom, 4)
                Text(store.twitchMovie?.name ?? "取得失敗しました")
                .padding(.bottom, 10)
            }
            Button("取得する"){
                store.send(.fetchMovies,animation: .default)
            }

       
        }
        .padding(.horizontal, 20)
    }
}


