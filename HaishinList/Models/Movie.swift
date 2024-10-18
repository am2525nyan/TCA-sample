//
//  Movie.swift
//  HaishinList
//
//  Created by saki on 2024/10/18.
//

import Foundation

struct Movie: Equatable, Codable{
    let title: String
    let name: String
    let thumbnailUrl: String
    let streamUrl: String
    enum CodingKeys: String,CodingKey {
        case title = "title"
        case name = "user_name"
        case thumbnailUrl = "thumbnail_url"
        case streamUrl = "stream_url"
    }
 
}
