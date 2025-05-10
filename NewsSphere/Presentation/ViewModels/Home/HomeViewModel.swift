//  HomeViewModel.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import Foundation

protocol HomeViewModelDelegate: AnyObject {
    func didSelectArticle(_ article: Article, originalCategory: String?)
}

enum ArticleSection {
    case vertical
}

class HomeViewModel {
    private let articleRepository: ArticleRepositoryProtocol
    private var articles: [Article] = []
    private(set) var currentCategory: String = ""
    
    // Store the original category of each post
    private var articleOriginalCategories: [String: String] = [:]
    
    // Observables for UI updates
    var onArticlesUpdated: (() -> Void)?
    var onErrorOccurred: ((String) -> Void)?
    
    weak var delegate: HomeViewModelDelegate?
    
    private let favoriteCategoryRepository: FavoriteCategoryRepositoryProtocol
    
    init(articleRepository: ArticleRepositoryProtocol, 
         favoriteCategoryRepository: FavoriteCategoryRepositoryProtocol = FavoriteCategoryRepository()) {
        self.articleRepository = articleRepository
        self.favoriteCategoryRepository = favoriteCategoryRepository
    }
    
    func fetchArticles(category: String) {
        currentCategory = category
        
        if category == "yourNews" {
            fetchYourNewsArticles()
            return
        }
        
        articleRepository.fetchArticles(category: category, limit: nil) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                print("API response \(result?.count ?? 0) articles for category: \(category)")
                if let result = result {
                    self.articles = result
                    self.articleOriginalCategories.removeAll()
                    self.onArticlesUpdated?()
                } else {
                    self.onErrorOccurred?("Failed to fetch articles for \(category)")
                }
            }
        }
    }
    
    private func fetchYourNewsArticles() {
        let favoriteCategories = favoriteCategoryRepository.getAllFavoriteCategories()
        
        if favoriteCategories.isEmpty {
            print("DEBUG - HomeViewModel: No favorite categories found")
            self.articles = []
            self.articleOriginalCategories.removeAll()
            self.onArticlesUpdated?()
            return
        }
        
        let categoryCount = favoriteCategories.count
        
        // Create dispatch group to track API requests
        let dispatchGroup = DispatchGroup()
        
        // array to store results from requests
        var allArticles: [Article] = []
        // dictionary to save the root category of each article
        var categoryMap: [String: String] = [:]
        
        // Determine the number of posts to retrieve
        var articlesPerCategory: [NewsCategoryType: Int] = [:]
        
        switch categoryCount {
        case 1:
            articlesPerCategory[favoriteCategories[0]] = 10
        case 2:
            articlesPerCategory[favoriteCategories[0]] = 5
            articlesPerCategory[favoriteCategories[1]] = 5
        case 3:
            articlesPerCategory[favoriteCategories[0]] = 4
            articlesPerCategory[favoriteCategories[1]] = 3
            articlesPerCategory[favoriteCategories[2]] = 3
        default:
            break
        }
        
        // Call API for each category
        for (index, category) in favoriteCategories.enumerated() {
            let articlesToFetch = articlesPerCategory[category] ?? 0
            if articlesToFetch <= 0 { continue }
            
            dispatchGroup.enter()
            
            articleRepository.fetchArticles(category: category.apiValue, limit: articlesToFetch) { [weak self] result in
                defer {
                    dispatchGroup.leave()
                }
                
                guard let self = self else { return }
                
                if let fetchedArticles = result {
                    // Save the original category for each article
                    for article in fetchedArticles {
                        if let link = article.link {
                            categoryMap[link] = category.apiValue
                        }
                    }
                    
                    // Add to result array
                    allArticles.append(contentsOf: fetchedArticles)
                }
            }
        }
        
        // all request are complete
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            self.articles = allArticles
            self.articleOriginalCategories = categoryMap
            self.onArticlesUpdated?()
            
            print("DEBUG - HomeViewModel: Fetched \(allArticles.count) total articles for Your News")
        }
    }
    
    func getCurrentCategory() -> String {
        return currentCategory
    }
    
    func getOriginalCategory(for article: Article) -> String? {
        if currentCategory == "yourNews", let link = article.link {
            return articleOriginalCategories[link]
        }
        return currentCategory
    }
    
    var verticalArticles: [Article] {
        return articles
    }
    
    func numberOfVerticalArticles() -> Int {
        return verticalArticles.count
    }
    
    func verticalArticle(at index: Int) -> Article? {
        guard index >= 0 && index < verticalArticles.count else { return nil }
        return verticalArticles[index]
    }
    
    func hasFavoriteCategories() -> Bool {
        return !favoriteCategoryRepository.getAllFavoriteCategories().isEmpty
    }
    
    func selectArticle(from section: ArticleSection, at index: Int) {
        guard let article = verticalArticle(at: index) else { return }
        let originalCategory = getOriginalCategory(for: article)
        delegate?.didSelectArticle(article, originalCategory: originalCategory)
    }
}
