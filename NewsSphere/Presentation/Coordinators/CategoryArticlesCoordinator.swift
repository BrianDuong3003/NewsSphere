//
//  Untitled.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 7/4/25.
//

import Foundation
import UIKit

// Tạo protocol cho CategoryArticlesCoordinator
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
    
    // Thêm phương thức điều hướng đến màn hình chi tiết bài viết
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
