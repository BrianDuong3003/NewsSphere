//
//  SearchViewModel.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//
import Foundation

class SearchViewModel {
    // MARK: - Properties
    private let repository: ArticleRepository
    private var realmManager: RealmManager?
    private var searchWorkItem: DispatchWorkItem?
    private var searchCache: [String: [Article]] = [:]
    private let cacheTimeout: TimeInterval = 300
    private var cacheTimestamps: [String: Date] = [:]
    
    // MARK: - Observable
    let articles = Observable<[Article]>([])
    let searchHistory = Observable<[SearchHistoryObject]>([])
    let isLoading = Observable<Bool>(false)
    let error = Observable<String?>(nil)
    
    // MARK: - Init
    init(repository: ArticleRepository = ArticleRepository(),
         realmManager: RealmManager? = UserSessionManager.shared.getCurrentRealmManager()) {
        self.repository = repository
        if let realmManager = realmManager {
            self.realmManager = realmManager
            print("DEBUG - SearchViewModel: RealmManager initialized successfully")
        } else if let anonymousRealmManager = RealmManager(userUID: "anonymous") {
            self.realmManager = anonymousRealmManager
            print("DEBUG - SearchViewModel: Initialized RealmManager with anonymous user")
        } else {
            self.realmManager = nil
            print("DEBUG - SearchViewModel: Failed to initialize RealmManager")
        }
        loadSearchHistory()
    }
    
    // MARK: - Functions
    func searchArticles(with query: String) {
        // Cancel any pending search
        searchWorkItem?.cancel()
        
        // Check cache first
        if let cachedResults = getCachedResults(for: query) {
            self.articles.value = cachedResults
            return
        }
        
        // Create new search work item
        let workItem = DispatchWorkItem { [weak self] in
            self?.performSearch(query: query)
        }
        
        // Store the work item
        searchWorkItem = workItem
        
        // Execute after 0.5 seconds delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    private func performSearch(query: String) {
        isLoading.value = true
        error.value = nil
        
        repository.searchArticle(query: query) { [weak self] articles in
            DispatchQueue.main.async {
                self?.isLoading.value = false
                if let articles = articles {
                    // First remove duplicates
                    let uniqueArticles = self?.removeDuplicateArticles(articles) ?? []
                    
                    // Then filter articles that contain the search query
                    let filteredArticles = self?.filterArticlesByQuery(uniqueArticles, query: query) ?? []
                    
                    self?.articles.value = filteredArticles
                    self?.cacheResults(filteredArticles, for: query)
                    self?.saveSearchHistory(keyword: query)
                } else {
                    self?.error.value = "No articles found."
                }
            }
        }
    }
    
    private func removeDuplicateArticles(_ articles: [Article]) -> [Article] {
        var seenArticles = Set<String>()
        var uniqueArticles: [Article] = []
        
        for article in articles {
            // Create a unique identifier for the article based on title and content
            let identifier = "\(article.title ?? "")_\(article.content ?? "")"
            
            if !seenArticles.contains(identifier) {
                seenArticles.insert(identifier)
                uniqueArticles.append(article)
            }
        }
        
        return uniqueArticles
    }
    
    private func filterArticlesByQuery(_ articles: [Article], query: String) -> [Article] {
        let searchTerms = query.lowercased().split(separator: " ")
        
        return articles.filter { article in
            let title = article.title?.lowercased() ?? ""
            let content = article.content?.lowercased() ?? ""
            
            // Check if all search terms are present in either title or content
            return searchTerms.allSatisfy { term in
                title.contains(term) || content.contains(term)
            }
        }
    }
    
    private func getCachedResults(for query: String) -> [Article]? {
        guard let timestamp = cacheTimestamps[query],
              Date().timeIntervalSince(timestamp) < cacheTimeout,
              let cachedResults = searchCache[query] else {
            return nil
        }
        return cachedResults
    }
    
    private func cacheResults(_ articles: [Article], for query: String) {
        searchCache[query] = articles
        cacheTimestamps[query] = Date()
    }
    
    func clearCache() {
        searchCache.removeAll()
        cacheTimestamps.removeAll()
    }
    
    func loadSearchHistory() {
        guard let realmManager = realmManager else {
            print("DEBUG - SearchViewModel: Cannot load search history - RealmManager is nil")
            searchHistory.value = []
            return
        }
        
        print("DEBUG - SearchViewModel: Loading search history")
        let history = realmManager.getSearchHistory()
        print("DEBUG - SearchViewModel: Loaded \(history.count) search history items")
        searchHistory.value = history
    }
    
    func deleteSearchKeyword(_ keyword: String) {
        guard let realmManager = realmManager else { return }
        realmManager.deleteSearchHistory(keyword: keyword)
        loadSearchHistory()
    }
    
    func clearSearchResults() {
        articles.value = []
    }
    
    func article(at index: Int) -> Article? {
        guard index >= 0, index < articles.value.count else { return nil }
        return articles.value[index]
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
    
    private func saveSearchHistory(keyword: String) {
        guard let realmManager = realmManager else {
            print("DEBUG - SearchViewModel: Cannot save search history - RealmManager is nil")
            return
        }
        
        print("DEBUG - SearchViewModel: Saving search history for keyword: \(keyword)")
        realmManager.saveSearchHistory(keyword: keyword)
        loadSearchHistory()
    }
}
