//  HomeViewModel.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import Foundation

protocol HomeViewModelDelegate: AnyObject {
    func didSelectArticle(_ article: Article)
}

enum ArticleSection {
    case vertical, horizontal
}

class HomeViewModel {
    private let articleRepository: ArticleRepositoryProtocol
    private var articles: [Article] = []
    private(set) var currentCategory: String = ""
    
    // Observables for UI updates
    var onArticlesUpdated: (() -> Void)?
    var onErrorOccurred: ((String) -> Void)? // Closure to notify about errors
    
    weak var delegate: HomeViewModelDelegate?
    
    init(articleRepository: ArticleRepositoryProtocol) {
        self.articleRepository = articleRepository
    }
    
    func fetchArticles(category: String) {
        currentCategory = category
        articleRepository.fetchArticles(category: category) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                print("API response \(result?.count ?? 0) articles for category: \(category)")
                if let result = result {
                    self.articles = result
                    self.onArticlesUpdated?()
                }
            }
        }
    }
    
    func getCurrentCategory() -> String {
        return currentCategory
    }
    
    var verticalArticles: [Article] {
        return Array(articles.prefix(7))
    }
    
    var horizontalArticles: [Article] {
        return Array(articles.dropFirst(3))
    }
    
    func numberOfHorizontalArticles() -> Int {
        return horizontalArticles.count
    }
    
    func numberOfVerticalArticles() -> Int {
        return verticalArticles.count
    }
    
    func verticalArticle(at index: Int) -> Article? {
        guard index >= 0 && index < verticalArticles.count else { return nil }
        return verticalArticles[index]
    }
    
    func horizontalArticle(at index: Int) -> Article? {
        guard index >= 0 && index < horizontalArticles.count else { return nil }
        return horizontalArticles[index]
    }
    
    func selectArticle(from section: ArticleSection, at index: Int) {
        let article: Article?
        
        switch section {
        case .vertical:
            article = verticalArticle(at: index)
        case .horizontal:
            article = horizontalArticle(at: index)
        }
        
        if let article = article {
            delegate?.didSelectArticle(article)
        }
    }
}
