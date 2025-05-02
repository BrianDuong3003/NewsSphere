//
//  APIEndpoints.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 5/3/25.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol APIEndpoint {
    var baseUrl: String { get }
    var headers: [String: String] { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var params: [String: Any] { get }
}

extension APIEndpoint {
    var baseUrl: String {
        return AppConstants.API.baseUrl
    }
    
    var headers: [String: String] {
        return [:]
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var params: [String: Any] {
        return [AppConstants.API.Parameters.apiKey: AppConstants.API.accessToken]
    }
    
    var fullUrl: URL {
        guard let baseUrl = URL(string: baseUrl) else {
            fatalError("Base URL is invalid")
        }
        
        let url = baseUrl.appendingPathComponent(path)
        
        // If it's a GET request with params, add query parameters
        if method == .get && !params.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            components?.queryItems = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            return components?.url ?? url
        }
        
        return url
    }
}
