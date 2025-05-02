//
//  NetworkError.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 5/3/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case invalidStatusCode(Int)
    case noData
    case decodingError(Error)
    case encodingError
    case unauthorized
    case notFound
    case serverError
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response"
        case .invalidStatusCode(let code):
            return "Invalid status code: \(code)"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .encodingError:
            return "Encoding error"
        case .unauthorized:
            return "Unauthorized access"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error"
        }
    }
}
