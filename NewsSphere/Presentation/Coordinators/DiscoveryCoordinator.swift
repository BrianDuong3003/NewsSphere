//
//  DiscoveryCoordinator.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import Foundation
import UIKit

class DiscoveryCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    let navigationController: UINavigationController
    var parentCoordinator: MainCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        
    }
    
    func showArticles(for category: String) {
        let categoryArticlesCoordinator = CategoryArticlesCoordinator(
            navigationController: navigationController,
            category: category
        )
        addChildCoordinator(categoryArticlesCoordinator)
        categoryArticlesCoordinator.start()
    }
    
    func didFinish() {
        parentCoordinator?.childDidFinish(self)
    }
}
