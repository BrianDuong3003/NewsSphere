//
//  HomeAPI.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 7/4/25.
//

struct HomeAPI: APIEndpoint {
    let category: String
    
    var path: String {
        return "latest"
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var params: [String: Any] {
        var params = [
            "category": category,
            "language": "en"
        ]
        params[AppConstants.API.Parameters.apiKey] = AppConstants.API.accessToken
        return params
    }
}
