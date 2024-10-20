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
            if store.movies != nil{
                List{
                    
                    ForEach(store.movies){ movie in
                        AsyncImage(url: URL(string: movie.thumbnailUrl)){ image in
                            
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .onTapGesture {
                                    openURL(URL(string: movie.streamUrl)!)
                                }
                        } placeholder: {
                            ProgressView()
                        }
                        .padding(.bottom,10)
                        
                        Text(movie.title)
                            .padding(.bottom, 4)
                        Text(movie.name)
                            .padding(.bottom, 10)
                    }
                }
            }
            Button("取得する"){
                store.send(.fetchMovies,animation: .default)
            }

       
        }
        .padding(.horizontal, 20)
    }
}


