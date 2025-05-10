//
//  NewsEndpoints.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 10/3/25.
//

import Foundation

enum NewsEndpoints {
    // get latest news from different categories
    struct GetLatestNews: APIEndpoint {
        let path = "/latest"
        var params: [String: Any]
        
        init(category: String? = nil, country: String? = nil, language: String = "en", query: String? = nil, size: Int = 10, page: Int? = nil) {
            var parameters: [String: Any] = [
                "language": language,
                "apikey": AppConstants.API.accessToken
            ]
            
            if let category = category {
                parameters["category"] = category
            }
            
            if let country = country {
                parameters["country"] = country
            }
            
            if let query = query {
                parameters["q"] = query
            }
            
            parameters["size"] = String(size)
            
            if let page = page {
                parameters["page"] = String(page)
            }
            
            self.params = parameters
        }
    }
    struct GetSearchLatestNews: APIEndpoint {
        let path = "/latest"
        var params: [String: Any]
        
        init(query: String? = nil, language: String = "en", country: String = "us,gb", size: Int = 10) {
            var parameters: [String: Any] = [
                "apikey": AppConstants.API.accessToken,
                "language": language,
                "country": country,
                "size": size
            ]
            
            if let query = query {
                parameters["q"] = query
            }
            
            self.params = parameters
        }
    }
}
