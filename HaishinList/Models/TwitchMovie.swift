//
//  TwitchMovie.swift
//  HaishinList
//
//  Created by saki on 2024/10/09.
//

import Foundation

struct TwitchMovie: Decodable,Equatable {
    let title: String
    let user_name: String
    let thumbnailUrl: String
    let streamUrl: String
    let userLogin: String
    
    init(title: String, user_name: String, thumbnailUrl: String,userLogin: String) {
        self.title = title
        self.user_name = user_name
        self.thumbnailUrl = thumbnailUrl
        self.userLogin = userLogin
        self.streamUrl = "https://www.twitch.tv/\(userLogin)"
        
    }
}
