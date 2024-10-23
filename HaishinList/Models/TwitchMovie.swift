//
//  TwitchMovie.swift
//  HaishinList
//
//  Created by saki on 2024/10/09.
//

import Foundation

struct TwitchMovie: Codable,Equatable {
    let title: String
    let name: String
    let thumbnailUrl: String
    let streamUrl: String
    let userLogin: String
    let publishedAt: String
    
    init(title: String, user_name: String, thumbnailUrl: String,userLogin: String, publishedAt: String) {
        self.title = title
        self.name = user_name
        self.thumbnailUrl = thumbnailUrl
        self.userLogin = userLogin
        self.streamUrl = "https://www.twitch.tv/\(userLogin)"
        self.publishedAt = publishedAt
        
    }
    enum CodingKeys: String,CodingKey {
        case title = "title"
        case name = "user_name"
        case thumbnailUrl = "thumbnail_url"
        case streamUrl = "stream_url"
        case userLogin = "user_login"
        case publishedAt = "published_at"
    }
 
}
