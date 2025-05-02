//
//  AppCoordinator.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import UIKit

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var window: UIWindow
    var mainCoordinator: MainCoordinator?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        //        if isUserLoggedIn() {
        //            showMainFlow()
        //        } else {
        //            showAuthFlow()
        //        }
        // Test
        //        showAuthFlow()
        showMainFlow()
        
        window.makeKeyAndVisible()
    }
    
    private func isUserLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: "isUserLoggedIn")
    }
    
    private func showAuthFlow() {
        let authCoordinator = AuthCoordinator(window: window)
        authCoordinator.delegate = self
        childCoordinators.append(authCoordinator)
        authCoordinator.start()
    }
    
    private func showMainFlow() {
        let coordinator = MainCoordinator(window: window)
        mainCoordinator = coordinator
        childCoordinators.append(coordinator)
        coordinator.start()
    }
}

extension AppCoordinator: AuthCoordinatorDelegate {
    func didFinishAuthentication() {
        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        childCoordinators.removeAll { $0 is AuthCoordinator }
        showMainFlow()
    }
}
