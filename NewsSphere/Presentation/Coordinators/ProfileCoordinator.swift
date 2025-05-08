//
//  ProfileCoordinator.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import Foundation
import UIKit

protocol ArticleNavigator: AnyObject {
    func showArticleDetail(_ article: Article, selectedCategory: String?)
    func didFinishReadOffline()
}

class ProfileCoordinator: Coordinator, ArticleNavigator {
    var childCoordinators: [any Coordinator] = []
    let navigationController: UINavigationController
    weak var parentCoordinator: MainCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {

    }
    
    func navigateToBookmarks() {
        let repository = ArticleRepository()
        let bookmarkRepository = BookmarkRepository()
        
        let bookmarkCoordinator = BookmarkCoordinator(
            navigationController: navigationController,
            repository: repository,
            bookmarkRepository: bookmarkRepository
        )
        
        childCoordinators.append(bookmarkCoordinator)
        bookmarkCoordinator.start()
    }
    
    func navigateToReadOffline() {
        let viewModel = ReadOfflineViewModel()
        let readOfflineViewController = ReadOfflineViewController(viewModel: viewModel)
        
        readOfflineViewController.coordinator = self
        
        navigationController.pushViewController(readOfflineViewController, animated: true)
    }
    
    func showArticleDetail(_ article: Article, selectedCategory: String?) {
        guard let parent = parentCoordinator else {
            print("ERROR - ProfileCoordinator: parentCoordinator is nil. Cannot show article detail.")
            return
        }
        parent.showArticleDetail(article, category: selectedCategory)
    }
    
    func didFinishReadOffline() {
        print("DEBUG - ProfileCoordinator: Finishing ReadOffline screen")
        navigationController.popViewController(animated: true)
    }
    
    func didLogout() {
        print("DEBUG - ProfileCoordinator: User logged out")
        // Clean up any resources if needed
        childCoordinators.removeAll()
        
        // Notify parent coordinator to handle the logout
        parentCoordinator?.userDidLogout()
    }
    
    func didFinish() {
        parentCoordinator?.childDidFinish(self)
    }
}
