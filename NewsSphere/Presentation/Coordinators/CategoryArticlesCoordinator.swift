//
//  CategoryArticlesCoordinator.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 7/4/25.
//

import Foundation
import UIKit

protocol CategoryArticlesCoordinatorProtocol: AnyObject {
    func navigateBack()
    func showArticleDetail(_ article: Article)
}

class CategoryArticlesCoordinator: Coordinator, CategoryArticlesCoordinatorProtocol {
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    let category: String
    
    init(navigationController: UINavigationController, category: String) {
        self.navigationController = navigationController
        self.category = category
    }
    
    func start() {
        let categoryArticlesVC = CategoryArticlesViewController(category: category)
        categoryArticlesVC.coordinator = self
        navigationController.pushViewController(categoryArticlesVC, animated: true)
    }
    
    func showArticleDetail(_ article: Article) {
        let bookmarkRepository = BookmarkRepository()
        let repository: ArticleRepositoryProtocol = ArticleRepository()
        
        let articleDetailCoordinator = ArticleDetailCoordinator(
            navigationController: navigationController,
            article: article,
            repository: repository,
            bookmarkRepository: bookmarkRepository
        )
        addChildCoordinator(articleDetailCoordinator)
        articleDetailCoordinator.start()
    }
    
    func navigateBack() {
        navigationController.popViewController(animated: true)
    }
}
