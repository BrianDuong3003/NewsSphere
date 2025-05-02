//
//  ArticleDetailViewModel.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//
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
