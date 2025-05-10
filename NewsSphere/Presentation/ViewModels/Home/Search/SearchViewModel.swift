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
    private let realmManager: RealmManager?
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
        self.realmManager = realmManager
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
                    self?.articles.value = articles
                    self?.cacheResults(articles, for: query)
                    self?.saveSearchHistory(keyword: query)
                } else {
                    self?.error.value = "No articles found."
                }
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
            searchHistory.value = []
            return
        }
        searchHistory.value = realmManager.getSearchHistory()
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
    
    func formatTimeAgo(for article: Article) -> String {
        guard let pubDateString = article.pubDate else {
            return "Unknown"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.current
        
        guard let articleDate = dateFormatter.date(from: pubDateString) else {
            return "Unknown"
        }
        
        let now = Date()
        if articleDate > now {
            return "Just now"
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute], from: articleDate, to: now)
        if let days = components.day, days > 0 {
            return "\(days)d ago"
        }
        
        if let hours = components.hour, hours > 0 {
            return "\(hours)h ago"
        }
        
        if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m ago"
        }
        return "Just now"
        
    }
    
    private func saveSearchHistory(keyword: String) {
        guard let realmManager = realmManager else { return }
        realmManager.saveSearchHistory(keyword: keyword)
        loadSearchHistory()
    }
}
