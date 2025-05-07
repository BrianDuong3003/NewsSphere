//
//  HomeCoordinator.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import Foundation
import UIKit

class HomeCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    let navigationController: UINavigationController
    var parentCoordinator: MainCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        
    }
    
//    func showArticleDetail(_ article: Article, selectedCategory: String? = nil) {
//        print("DEBUG - HomeCoordinator: Showing article detail with category: \(selectedCategory ?? "none")")
//        
//        if let parent = parentCoordinator {
//            parent.showArticleDetail(article, category: selectedCategory)
//        } else {
//            // Fallback when parentCoordinator nil
//            let bookmarkRepository = BookmarkRepository()
//            let repository: ArticleRepositoryProtocol = ArticleRepository()
//            let detailCoordinator = ArticleDetailCoordinator(
//                navigationController: navigationController,
//                article: article,
//                repository: repository,
//                bookmarkRepository: bookmarkRepository)
//            
//            if let category = selectedCategory {
//                detailCoordinator.selectedCategory = category
//            }
//            
//            addChildCoordinator(detailCoordinator)
//            detailCoordinator.start()
//        }
//    }
    func showArticleDetail(_ article: Article, selectedCategory: String? = nil) {
        guard let parent = parentCoordinator else {
            print("ERROR - HomeCoordinator: parentCoordinator is nil. Cannot show article detail.")
            return
        }
        parent.showArticleDetail(article, category: selectedCategory)
    }
    
    func showLocationScreen() {
        navigationController.setNavigationBarHidden(false, animated: true)
        let locationViewController = LocationViewController()
        locationViewController.coordinator = self
        navigationController.pushViewController(locationViewController, animated: true)
    }
    
    func showReadOfflineScreen() {
        let viewModel = ReadOfflineViewModel()
        let readOfflineViewController = ReadOfflineViewController(viewModel: viewModel)
        readOfflineViewController.coordinator = self
        navigationController.pushViewController(readOfflineViewController, animated: true)
    }
    
    func didFinishReadOffline() {
        print("DEBUG - HomeCoordinator: Finishing ReadOffline screen")
        navigationController.popViewController(animated: true)
    }
    
    func didFinish() {
        parentCoordinator?.childDidFinish(self)
    }
}
