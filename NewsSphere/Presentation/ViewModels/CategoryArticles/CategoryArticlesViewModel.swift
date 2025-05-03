//
//  ArticleDetailViewModel.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import Foundation

class CategoryArticlesViewModel {
    private let categoryRepository = CategoryRepository()
    private var articles: [Article] = []
    let category: String
    
    init(category: String) {
        self.category = category
    }
        
    func fetchArticles(completion: @escaping ([Article]) -> Void) {
        categoryRepository.fetchArticles(for: category) { [weak self] result in
            switch result {
            case .success(let articles):
                self?.articles = articles
                DispatchQueue.main.async {
                    completion(articles)
                }
            case .failure(let error):
                let errorMessage = self?.errorMessage(for: error) ?? "Unknown error"
                print("Failed to fetch articles for category \(self?.category ?? ""): \(error)")
                
                // Still call completion with empty array
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    private func errorMessage(for error: NetworkError) -> String {
        switch error {
        case .invalidStatusCode(let code):
            if code == 429 {
                return "API rate limit reached. Please try again later."
            } else if code == 422 {
                return "Invalid request parameters for this category."
            } else {
                return "Server error (code: \(code))"
            }
        case .serverError:
            return "Server error or rate limit reached."
        case .requestFailed:
            return "Network connection error"
        case .invalidResponse, .decodingError, .encodingError, .noData:
            return "Failed to process server response"
        case .invalidURL:
            return "Invalid URL configuration"
        case .unauthorized:
            return "Unauthorized access"
        case .notFound:
            return "Resource not found"
        }
    }
}
