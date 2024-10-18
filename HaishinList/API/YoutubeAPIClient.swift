//
//  Youtube.swift
//  HaishinList
//
//  Created by saki on 2024/10/08.
//

import Foundation

//struct APIClient {
//    var fetchData: (String) -> Effect<YoutubeMovie, APIError>
//}
//
//extension APIClient {
//    static let live = APIClient(
//         users: { query in
//             var components = URLComponents()
//             components.scheme = "https"
//             components.host = "www.googleapis.com/youtube/v3"
//             components.path = "/search"
//             components.queryItems = [URLQueryItem(name: "q", value: query)]
//
//             return URLSession.shared.dataTaskPublisher(for: components.url!)
//                 .map { data, _ in data }
//                 .decode(type: YoutubeMovie.self, decoder: JSONDecoder())
//               
//         }
//     )
//}
