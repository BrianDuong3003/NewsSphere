//
//  NewsEndpoints.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 10/3/25.
//

import Foundation

// Define specific endpoints
enum NewsEndpoints {
    // get latest news from different categories
    struct GetLatestNews: APIEndpoint {
        let path = "/latest"
        var params: [String: Any]
        
        init(category: String? = nil, country: String? = nil, language: String = "en", query: String? = nil, size: Int = 10, page: Int? = nil) {
            var parameters: [String: Any] = [
                "language": language,
                "apikey": AppConstants.API.accessToken // Đảm bảo truyền đúng API key với tham số apikey viết thường
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
            
            // Size = 10 đã được kiểm chứng hoạt động tốt với API
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
        
        init(apikey: String = "pub_78857713eed379fa6779f8d63afd050e5e046", query: String? = nil) {
            var parameters: [String: Any] = ["apikey": apikey]
            
            if let query = query {
                parameters["q"] = query
            }
            
            self.params = parameters
        }
    }
    // get news from specific city/region
    struct GetLocalNews: APIEndpoint {
        let path = "/latest"
        var params: [String: Any]
        
        init(cityName: String, country: String = "united states", language: String = "en", category: String? = nil, size: Int = 10, page: Int? = nil) {
            var parameters: [String: Any] = ["language": language]
            
            // Format city and country for region parameter
            let formattedCity = cityName.lowercased().replacingOccurrences(of: " ", with: "-")
            let formattedCountry = country.lowercased().replacingOccurrences(of: " ", with: "-")
            parameters["region"] = "\(formattedCity)-\(formattedCountry)"
            
            if let category = category {
                parameters["category"] = category
            }
            
            // Size = 10 đã được kiểm chứng hoạt động tốt với API
            parameters["size"] = size
            
            if let page = page {
                parameters["page"] = page
            }
            
            self.params = parameters
        }
    }
    
    // Historical news archive
    struct GetHistoricalNews: APIEndpoint {
        let path = "/archive"
        var params: [String: Any]
        
        init(query: String? = nil, fromDate: String? = nil, toDate: String? = nil, language: String = "en", country: String? = nil, category: String? = nil, size: Int = 10, page: Int? = nil) {
            var parameters: [String: Any] = ["language": language]
            
            if let query = query {
                parameters["q"] = query
            }
            
            if let fromDate = fromDate {
                parameters["from_date"] = fromDate
            }
            
            if let toDate = toDate {
                parameters["to_date"] = toDate
            }
            
            if let country = country {
                parameters["country"] = country
            }
            
            if let category = category {
                parameters["category"] = category
            }
            
            // Size = 10 đã được kiểm chứng hoạt động tốt với API
            parameters["size"] = size
            
            if let page = page {
                parameters["page"] = page
            }
            
            self.params = parameters
        }
    }
    
    // News from specific domains
    struct GetNewsByDomain: APIEndpoint {
        let path = "/latest"
        var params: [String: Any]
        
        init(domain: String, query: String? = nil, language: String = "en", size: Int = 10, page: Int? = nil) {
            var parameters: [String: Any] = ["language": language]
            
            parameters["domain"] = domain
            
            if let query = query {
                parameters["q"] = query
            }
            
            // Size = 10 đã được kiểm chứng hoạt động tốt với API
            parameters["size"] = size
            
            if let page = page {
                parameters["page"] = page
            }
            
            self.params = parameters
        }
    }
}
