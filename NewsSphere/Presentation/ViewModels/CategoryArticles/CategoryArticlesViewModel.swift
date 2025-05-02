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
                print("Failed to fetch articles for category \(self?.category ?? ""): \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
}
