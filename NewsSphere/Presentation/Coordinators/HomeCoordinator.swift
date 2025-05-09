//
//  HomeCoordinator.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import Foundation
import UIKit

class HomeCoordinator: Coordinator, ArticleNavigator {
    var childCoordinators: [any Coordinator] = []
    let navigationController: UINavigationController
    weak var parentCoordinator: MainCoordinator? // to prevent retain cycle
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        
    }
    
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
    
    func showSearchScreen() {
        let searchViewController = SearchViewController()
        searchViewController.coordinator = self
        navigationController.pushViewController(searchViewController, animated: true)
    }
    
    func didFinishReadOffline() {
        print("DEBUG - HomeCoordinator: Finishing ReadOffline screen")
        navigationController.popViewController(animated: true)
    }
    
    func didFinish() {
        parentCoordinator?.childDidFinish(self)
    }
}
