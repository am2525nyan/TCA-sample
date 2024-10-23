//
//  YoutubeMovieModel.swift
//  HaishinList
//
//  Created by saki on 2024/10/08.
//

import Foundation

struct YoutubeMovie: Equatable, Decodable {
    let title: String
    let name: String
    let videoId: String
    let thumbnailUrl: String
    let streamUrl: String
    let publishedAt: String
    init(title: String, name: String, videoId: String, thumbnailUrl: String, publishedAt: String) {
        self.title = title
        self.name = name
        self.thumbnailUrl = thumbnailUrl
        self.videoId = videoId
        self.streamUrl = "https://www.youtube.com/watch?v=\(videoId)"
        self.publishedAt = publishedAt
    }
    enum CodingKeys: String,CodingKey {
        case title = "title"
        case name = "channelId"
        case videoId = "videoId"
        case thumbnailUrl = "thumbnail_url"
        case streamUrl = "videoURL"
        case publishedAt = "publishedAt"
     
    }
}
