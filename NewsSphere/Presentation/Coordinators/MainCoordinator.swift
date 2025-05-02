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
    
    private var homeCoordinator: HomeCoordinator?
    private var discoveryCoordinator: DiscoveryCoordinator?
    private var noticeCoordinator: NoticeCoordinator?
    private var profileCoordinator: ProfileCoordinator?
    private var mainViewController: MainViewController?
    
    init(window: UIWindow) {
        self.window = window
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
        // Create HomeViewController with coordinator
        let homeVC = HomeViewController()
        let homeCoordinator = HomeCoordinator(navigationController: navigationController)
        homeVC.coordinator = homeCoordinator
        homeCoordinator.parentCoordinator = self
        addChildCoordinator(homeCoordinator)
        self.homeCoordinator = homeCoordinator
        homeCoordinator.start()
        
        // Create DiscoveryViewController with coordinator
        let discoveryVC = DiscoveryViewController()
        let discoveryCoordinator = DiscoveryCoordinator(navigationController: navigationController)
        discoveryVC.coordinator = discoveryCoordinator
        discoveryCoordinator.parentCoordinator = self
        addChildCoordinator(discoveryCoordinator)
        self.discoveryCoordinator = discoveryCoordinator
        discoveryCoordinator.start()
        
        // Create NoticeViewController with coordinator
        let noticeVC = NoticeViewController()
        let noticeCoordinator = NoticeCoordinator(navigationController: navigationController)
        noticeVC.coordinator = noticeCoordinator
        noticeCoordinator.parentCoordinator = self
        addChildCoordinator(noticeCoordinator)
        self.noticeCoordinator = noticeCoordinator
        noticeCoordinator.start()
        
        // Create ProfileViewController with coordinator
        let profileVC = ProfileViewController()
        let profileCoordinator = ProfileCoordinator(navigationController: navigationController)
        profileVC.coordinator = profileCoordinator
        profileCoordinator.parentCoordinator = self
        addChildCoordinator(profileCoordinator)
        self.profileCoordinator = profileCoordinator
        profileCoordinator.start()
        
        return [homeVC, discoveryVC, noticeVC, profileVC]
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
    
    func childDidFinish(_ child: Coordinator?) {
        if let child = child {
            removeChildCoordinator(child)
        }
    }
}
