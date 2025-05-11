//
//  MainCoordinator.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 5/3/25.
//

import UIKit

protocol MainCoordinatorDelegate: AnyObject {
    func showArticleDetail(_ article: Article)
}

class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var window: UIWindow
    var navigationController: UINavigationController
    private var isAuthenticated: Bool
    
    private var homeCoordinator: HomeCoordinator?
    private var discoveryCoordinator: DiscoveryCoordinator?
    private var profileCoordinator: ProfileCoordinator?
    private var mainViewController: MainViewController?
    
    init(window: UIWindow, isAuthenticated: Bool = true) {
        self.window = window
        self.isAuthenticated = isAuthenticated
        self.navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func start() {
        mainViewController = MainViewController()
        let viewControllers = createAndConfigureViewControllers()
        mainViewController?.setViewControllers(viewControllers)
        
        if let mainVC = mainViewController {
            navigationController.viewControllers = [mainVC]
        } else {
            navigationController.viewControllers = [UIViewController()]
        }
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    private func createAndConfigureViewControllers() -> [UIViewController] {
        // Create HomeViewController with coordinator and ViewModel
        let repository: ArticleRepositoryProtocol = ArticleRepository()
        let favoriteCategoryRepository: FavoriteCategoryRepositoryProtocol = FavoriteCategoryRepository()
        let homeViewModel = HomeViewModel(
            articleRepository: repository,
            favoriteCategoryRepository: favoriteCategoryRepository,
            isAuthenticated: isAuthenticated
        )
        let homeVC = HomeViewController(viewModel: homeViewModel)
        let homeCoordinator = HomeCoordinator(navigationController: navigationController)
        homeVC.coordinator = homeCoordinator
        homeCoordinator.parentCoordinator = self
        addChildCoordinator(homeCoordinator)
        self.homeCoordinator = homeCoordinator
        homeCoordinator.start()
        
        // Create DiscoveryViewController with coordinator and ViewModel
        let discoveryCoordinator = DiscoveryCoordinator(navigationController: navigationController)
        let discoveryViewModel = DiscoveryViewModel(coordinator: discoveryCoordinator)
        let discoveryVC = DiscoveryViewController(viewModel: discoveryViewModel)
        discoveryVC.coordinator = discoveryCoordinator
        discoveryCoordinator.parentCoordinator = self
        addChildCoordinator(discoveryCoordinator)
        self.discoveryCoordinator = discoveryCoordinator
        discoveryCoordinator.start()
        
        // Create ProfileViewController with coordinator and ViewModel
        let profileViewModel = ProfileViewModel(isAuthenticated: isAuthenticated)
        let profileVC = ProfileViewController(viewModel: profileViewModel)
        let profileCoordinator = ProfileCoordinator(navigationController: navigationController, isAuthenticated: isAuthenticated)
        profileVC.coordinator = profileCoordinator
        profileCoordinator.parentCoordinator = self
        addChildCoordinator(profileCoordinator)
        self.profileCoordinator = profileCoordinator
        profileCoordinator.start()
        
        return [homeVC, discoveryVC, profileVC]
    }
    
    func showArticleDetail(_ article: Article, category: String? = nil) {
        let bookmarkRepository = BookmarkRepository()
        let repository: ArticleRepositoryProtocol = ArticleRepository()
        let detailCoordinator = ArticleDetailCoordinator(navigationController: navigationController,
                                                         article: article,
                                                         repository: repository,
                                                         bookmarkRepository: bookmarkRepository)
        addChildCoordinator(detailCoordinator)
        
        if let category = category {
            detailCoordinator.selectedCategory = category
        }
        
        detailCoordinator.start()
    }
    
    func userDidLogout() {
        print("DEBUG - MainCoordinator: Handling user logout")
        
        // Clean up coordinators and resources
        childCoordinators.removeAll()
        
        // Create and show the auth flow by notifying AppCoordinator
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let appCoordinator = appDelegate.appCoordinator {
            appCoordinator.showAuthFlow()
        } else {
            // Fallback 
            let authCoordinator = AuthCoordinator(window: window)
            authCoordinator.start() 
        }
    }
    
    func restartAuthFlow() {
        print("DEBUG - MainCoordinator: Restarting auth flow after account deletion")
        userDidLogout()
    }
    
    func childDidFinish(_ child: Coordinator?) {
        if let child = child {
            removeChildCoordinator(child)
        }
    }
}
