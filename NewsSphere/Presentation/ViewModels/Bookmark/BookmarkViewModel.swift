//
//  ArticleDetailViewModel.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//
import Foundation

class BookmarkViewModel {
    // MARK: - Observables
    let bookmarkedArticles = Observable<[Article]>([])

    // MARK: - Coordinator
    private let coordinator: BookmarkCoordinatorProtocol
    private let repository: BookmarkRepositoryProtocol

    init(coordinator: BookmarkCoordinatorProtocol, repository: BookmarkRepositoryProtocol) {
        self.coordinator = coordinator
        self.repository = repository
        loadBookmarks()
    }

    func loadBookmarks() {
        bookmarkedArticles.value = repository.getSavedArticles()
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
            return "\(days)d"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)h"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m"
        } else {
            return "Just now"
        }
    }

    func article(at index: Int) -> Article {
        return bookmarkedArticles.value[index]
    }

    func numberOfArticles() -> Int {
        return bookmarkedArticles.value.count
    }

    func navigateToArticleDetail(at index: Int) {
        let article = bookmarkedArticles.value[index]
        coordinator.openArticleDetail(article: article)
    }

    func navigateBack() {
        coordinator.navigateBack()
    }
}
