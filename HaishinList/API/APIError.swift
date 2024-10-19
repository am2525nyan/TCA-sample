//
//  APIError.swift
//  HaishinList
//
//  Created by saki on 2024/10/09.
//

import Foundation

 enum APIError: Error, Equatable {
    case invalidURL
    case invalidResponse(Error)
    case decodingError(Error)
     case invalidData
    case unknown(Error)
    
}
extension APIError {
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.decodingError, .decodingError),
            (.invalidData, .invalidData),
             (.unknown, .unknown):
            return true
        default:
            return false
        }
    }
    
    var title: String {
        switch self {
        case .invalidResponse(let error): return "無効なレスポンスです。\(error)"
        case .invalidURL: return "無効なURLです。"
        case .decodingError(let error): return "デコード失敗しました\(error)"
        case .invalidData: return "無効なデータです。"
        case .unknown(let error): return "予期せぬエラーが発生しました。\(error)"
        }
    }
    
}
