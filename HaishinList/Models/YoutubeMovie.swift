//
//  YoutubeMovieModel.swift
//  HaishinList
//
//  Created by saki on 2024/10/08.
//

import Foundation
struct YoutubeMovie: Equatable,Decodable{
    let title: String
    let videoId: String
    let thumbnailUrl: String
    let videoUrl: String
}
