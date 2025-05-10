//
//  ArticleRepository.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import Foundation

protocol ArticleRepositoryProtocol {
    func fetchArticles(category: String, limit: Int?, completion: @escaping ([Article]?) -> Void)
    func searchArticle(query: String, completion: @escaping ([Article]?) -> Void)
}

class ArticleRepository: ArticleRepositoryProtocol {
    func fetchArticles(category: String, limit: Int? = nil, completion: @escaping ([Article]?) -> Void) {
        APIClient.shared.request(endpoint: HomeAPI(category: category),
                                 responseType: NewsResponse.self) { result in
            switch result {
            case .success(let response):
                let articles = response.results ?? []
                if let limit = limit, !articles.isEmpty {
                    let limitedResults = Array(articles.prefix(limit))
                    completion(limitedResults)
                } else {
                    completion(articles)
                }
            case .failure(let error):
                debugPrint("Error: \(error)")
                completion(nil)
            }
        }
    }
    
    func searchArticle(query: String, completion: @escaping ([Article]?) -> Void) {
        APIClient.shared.request(endpoint: NewsEndpoints.GetSearchLatestNews(query: query),
                                 responseType: NewsResponse.self) { result in
            switch result {
            case .success(let data):
                completion(data.results)
            case .failure(let error):
                debugPrint("Error: \(error)")
                completion(nil)
            }
        }
    }
}
