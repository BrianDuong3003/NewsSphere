//
//  Untitled.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 7/4/25.
//

import Foundation
import UIKit

class CategoryArticlesCoordinator: Coordinator {
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
}
