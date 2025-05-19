//
//  ReadOfflineViewModel.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import Foundation

class ReadOfflineViewModel {
    // MARK: - Properties
    typealias CompletionHandler = (Result<String, Error>) -> Void
    
    private let repository: OfflineArticleRepositoryProtocol
    private(set) var articles: [Article] = []
    
    // MARK: - Observable properties
    var onArticlesUpdated: (() -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Initialization
    init(repository: OfflineArticleRepositoryProtocol = OfflineArticleRepository()) {
        self.repository = repository
        loadOfflineArticles()
    }
    
    // MARK: - Data methods
    func loadOfflineArticles() {
        print("DEBUG - ReadOfflineViewModel: Loading offline articles")
        
        // make sure execute on main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.loadOfflineArticles()
            }
            return
        }
        
        articles = repository.getAllOfflineArticles()
        print("DEBUG - ReadOfflineViewModel: Loaded \(articles.count) offline articles")
        onArticlesUpdated?()
    }
    
    func reloadLatestArticles(completion: CompletionHandler? = nil) {
        print("DEBUG - ReadOfflineViewModel: Reloading latest articles")
        
        // make sure execute on main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.reloadLatestArticles(completion: completion)
            }
            return
        }
        
        onLoadingStateChanged?(true)
        
        repository.fetchLatestArticles { [weak self] result in
            guard let self = self else { return }
            
            // make sure execute on main thread
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedArticles):
                    print("DEBUG - ReadOfflineViewModel: Fetched \(fetchedArticles.count) latest articles")
                    
                    self.repository.saveArticles(fetchedArticles) { saveResult in
                        _ = self.repository.cleanupUnusedArticles()
                        
                        self.onLoadingStateChanged?(false)
                        
                        switch saveResult {
                        case .success(let count):
                            print("DEBUG - ReadOfflineViewModel: Saved \(count) articles for offline reading")
                            self.loadOfflineArticles()
                            let message = "Downloaded \(count) articles for offline reading"
                            completion?(.success(message))
                            
                        case .failure(let error):
                            print("DEBUG - ReadOfflineViewModel: Error saving articles: \(error.localizedDescription)")
                            self.onError?(error.localizedDescription)
                            completion?(.failure(error))
                        }
                    }
                    
                case .failure(let error):
                    print("DEBUG - ReadOfflineViewModel: Error fetching latest articles: \(error.localizedDescription)")
                    self.onLoadingStateChanged?(false)
                    self.onError?(error.localizedDescription)
                    completion?(.failure(error))
                }
            }
        }
    }
    
    func deleteAllArticles(completion: CompletionHandler? = nil) {
        print("DEBUG - ReadOfflineViewModel: Deleting all offline articles")
        
        // make sure execute on main thread
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.deleteAllArticles(completion: completion)
            }
            return
        }
        
        onLoadingStateChanged?(true)
        
        let result = repository.deleteAllOfflineArticles()
        
        switch result {
        case .success:
            print("DEBUG - ReadOfflineViewModel: Successfully deleted all offline articles")
            _ = repository.cleanupUnusedArticles()
            
            self.onLoadingStateChanged?(false)
            self.articles.removeAll()
            self.onArticlesUpdated?()
            completion?(.success("All offline articles have been deleted"))
            
        case .failure(let error):
            print("DEBUG - ReadOfflineViewModel: Error deleting articles: \(error.localizedDescription)")
            self.onLoadingStateChanged?(false)
            self.onError?(error.localizedDescription)
            completion?(.failure(error))
        }
    }
    
    // MARK: - Helper methods
    func numberOfArticles() -> Int {
        return articles.count
    }
    
    func article(at index: Int) -> Article? {
        guard index >= 0 && index < articles.count else { return nil }
        return articles[index]
    }
    
    // MARK: - Get category for an article
    func getArticleCategory(at index: Int) -> String? {
        guard let article = article(at: index), let categories = article.category, !categories.isEmpty else {
            return nil
        }
        // Return the first category from the article's category array
        return categories.first
    }
    
    func formatTimeAgo(from dateString: String?) -> String {
        guard let dateString = dateString else { return "Unknown" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let date = dateFormatter.date(from: dateString) else { return dateString }
        
        let calendar = Calendar.current
        let now = Date()
        
        let components = calendar.dateComponents([.hour, .minute, .day], from: date, to: now)
        
        if let days = components.day, days > 0 {
            return "\(days)d ago"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)h ago"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "Just now"
        }
    }
} 
