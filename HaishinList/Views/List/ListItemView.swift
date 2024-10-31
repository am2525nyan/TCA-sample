//
//  ListView.swift
//  HaishinList
//
//  Created by saki on 2024/10/08.
//

import ComposableArchitecture
import SwiftUI

struct ListItemView: View {
    let movie: Movie
    @Environment(\.openURL) private var openURL
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: movie.thumbnailUrl)) {
                image in

                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .onTapGesture {
                        openURL(URL(string: movie.streamUrl)!)
                    }
            } placeholder: {
                ProgressView()
            }
            .padding(.bottom, 10)

            Text(movie.title)
                .padding(.bottom, 4)
            Text(movie.name)
                .padding(.bottom, 10)

        }
       
    }
}
