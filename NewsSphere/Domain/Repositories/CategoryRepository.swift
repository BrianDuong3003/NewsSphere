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
            size: 20,
            page: nil
        )
        
        APIClient.shared.request(endpoint: endpoint, responseType: NewsResponse.self) { result in
            switch result {
            case .success(let response):
                let articles = response.results ?? []
                completion(.success(articles))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
