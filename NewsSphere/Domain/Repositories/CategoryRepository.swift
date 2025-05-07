//
//  CategoryRepository.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import Foundation

class CategoryRepository {
    func fetchArticles(for category: String, completion: @escaping (Result<[Article], NetworkError>) -> Void) {
        let endpoint = NewsEndpoints.GetLatestNews(
            category: category,
            country: nil,
            language: "en",
            query: nil,
            size: 10,
            page: nil
        )
        
        print("Debug - Category: \(category)")
        print("Debug - API URL: \(endpoint.fullUrl)")
        
        APIClient.shared.request(endpoint: endpoint, responseType: NewsResponse.self) { result in
            switch result {
            case .success(let response):
                print("Debug - API Success: \(response.results?.count ?? 0) articles returned")
                let articles = response.results ?? []
                completion(.success(articles))
            case .failure(let error):
                print("Debug - API Error: \(error)")
                
                if case .invalidStatusCode(let statusCode) = error {
                    if statusCode == 429 {
                        print("Debug - Rate limit reached. Please try again later.")
                        completion(.failure(.serverError))
                        return
                    }
                }
                
                completion(.failure(error))
            }
        }
    }
}
