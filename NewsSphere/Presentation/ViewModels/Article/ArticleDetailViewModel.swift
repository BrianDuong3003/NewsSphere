//
//  ArticleDetailViewModel.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import Foundation

class Observable<T> {
    typealias Listener = (T) -> Void
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    private var listener: Listener?
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ listener: @escaping Listener) {
        self.listener = listener
        listener(value)
    }
}

class ArticleDetailViewModel {
    // MARK: - Properties
    private let repository: ArticleRepositoryProtocol
    private let bookmarkRepository: BookmarkRepositoryProtocol
    private let coordinator: ArticleDetailCoordinatorProtocol
    var selectedCategory: String?
    
    // MARK: - Observable Properties
    let article = Observable<Article?>(nil)
    let isLoading = Observable<Bool>(false)
    let error = Observable<String?>(nil)
    let isBookmarked = Observable<Bool>(false)
    let currentFontSize = Observable<CGFloat>(15.0)
    
    // MARK: - Initialization
    init(repository: ArticleRepositoryProtocol,
         bookmarkRepository: BookmarkRepositoryProtocol,
         coordinator: ArticleDetailCoordinatorProtocol,
         article: Article) {
        self.repository = repository
        self.bookmarkRepository = bookmarkRepository
        self.coordinator = coordinator
        self.article.value = article
        checkIfBookmarked()
    }

    func toggleBookmark() {
        guard let article = article.value, let link = article.link else { return }

        if isBookmarked.value {
            let result = bookmarkRepository.deleteArticle(link: link)
            if case .success = result {
                isBookmarked.value = false
            }
        } else {
            let result = bookmarkRepository.saveArticle(article)
            if case .success = result {
                isBookmarked.value = true
            }
        }
    }

    func checkIfBookmarked() {
        guard let link = article.value?.link else { return }
        isBookmarked.value = bookmarkRepository.isArticleSaved(link: link)
    }

    func changeFontSize(to size: CGFloat) {
        currentFontSize.value = size
    }

    func openWebView() {
        guard let urlString = article.value?.link else { return }
        coordinator.openWebView(urlString: urlString)
    }

    func shareArticle() {
        guard let article = article.value else { return }
        coordinator.shareArticle(article)
    }

    func navigateBack() {
        coordinator.navigateBack()
    }
}
