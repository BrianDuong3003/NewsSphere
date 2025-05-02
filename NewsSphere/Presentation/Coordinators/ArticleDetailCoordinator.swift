//
//  ArticleDetailCoordinator.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 20/3/25.
//

import UIKit

protocol ArticleDetailCoordinatorProtocol: AnyObject {
    func navigateBack()
    func openWebView(urlString: String)
    func shareArticle(_ article: Article)
}

class ArticleDetailCoordinator: Coordinator, ArticleDetailCoordinatorProtocol {
    // MARK: - Properties
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let article: Article
    var selectedCategory: String?
    
    private let repository: ArticleRepositoryProtocol
    private let bookmarkRepository: BookmarkRepositoryProtocol
    
    // MARK: - Initialization
    init(navigationController: UINavigationController, article: Article,
         repository: ArticleRepositoryProtocol,
         bookmarkRepository: BookmarkRepositoryProtocol) {
        self.navigationController = navigationController
        self.article = article
        self.repository = repository
        self.bookmarkRepository = bookmarkRepository
    }
    
    // MARK: - Coordinator Methods
    func start() {
        showArticleDetail()
    }
    
    func showArticleDetail() {
        let detailViewModel = ArticleDetailViewModel(repository: repository,
                                                     bookmarkRepository: bookmarkRepository,
                                                     coordinator: self,
                                                     article: article)
        
        if let category = selectedCategory {
            detailViewModel.selectedCategory = category
        }
        
        let detailViewController = ArticleDetailViewController()
        detailViewController.viewModel = detailViewModel
        navigationController.pushViewController(detailViewController, animated: true)
    }
    
    // MARK: - ArticleDetailCoordinatorProtocol
    func navigateBack() {
        navigationController.popViewController(animated: true)
    }
    
    func openWebView(urlString: String) {
        guard let link = URL(string: urlString) else { return }
        UIApplication.shared.open(link)
    }
    
    func shareArticle(_ article: Article) {
        guard let topVC = navigationController.topViewController else { return }
        
        var shareItems: [Any] = []
        
        if let link = article.link, let urlObj = URL(string: link) {
            shareItems.append(urlObj)
        }
        
        let activityVC = UIActivityViewController(activityItems: shareItems,
                                                  applicationActivities: nil)
        topVC.present(activityVC, animated: true)
    }
}
