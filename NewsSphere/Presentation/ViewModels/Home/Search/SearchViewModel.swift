//
//  ArticleDetailViewModel.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//
import Foundation

class SearchViewModel {
    // MARK: - Properties
    private let repository: ArticleRepository
    private let realmManager = RealmManager.shared

    // MARK: - Observable
    let articles = Observable<[Article]>([])
    let searchHistory = Observable<[SearchHistoryObject]>([])
    let isLoading = Observable<Bool>(false)
    let error = Observable<String?>(nil)

    // MARK: - Init
    init(repository: ArticleRepository = ArticleRepository()) {
        self.repository = repository
        loadSearchHistory()
    }

    // MARK: - Functions
    func searchArticles(with query: String) {
        isLoading.value = true
        error.value = nil

        repository.searchArticle(query: query) { [weak self] articles in
            DispatchQueue.main.async {
                self?.isLoading.value = false
                if let articles = articles {
                    self?.articles.value = articles
                    self?.saveSearchHistory(keyword: query)
                } else {
                    self?.error.value = "No articles found."
                }
            }
        }
    }

    func loadSearchHistory() {
        searchHistory.value = realmManager.getSearchHistory()
    }

    func deleteSearchKeyword(_ keyword: String) {
        realmManager.deleteSearchHistory(keyword: keyword)
        loadSearchHistory()
    }

    private func saveSearchHistory(keyword: String) {
        realmManager.saveSearchHistory(keyword: keyword)
        loadSearchHistory()
    }
}
