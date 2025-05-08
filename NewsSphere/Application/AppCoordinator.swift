//
//  AppCoordinator.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import UIKit
import FirebaseAuth

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var window: UIWindow
    var mainCoordinator: MainCoordinator?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        if isUserLoggedIn() {
            showMainFlow()
        } else {
            showAuthFlow()
        }
        
        window.makeKeyAndVisible()
    }
    
    private func isUserLoggedIn() -> Bool {
        // Check if user is logged in using Firebase Auth
        if let currentUser = Auth.auth().currentUser {
            // Initialize the UserSessionManager with the current user
            UserSessionManager.shared.userDidLogin(userID: currentUser.uid)
            return true
        }
        return false
    }
    
    func showAuthFlow() {
        // Clean up any existing coordinators
        childCoordinators.removeAll()
        mainCoordinator = nil
        
        let authCoordinator = AuthCoordinator(window: window)
        authCoordinator.delegate = self
        childCoordinators.append(authCoordinator)
        authCoordinator.start()
    }
    
    private func showMainFlow() {
        // Clean up any existing coordinators
        childCoordinators.removeAll()
        
        let coordinator = MainCoordinator(window: window)
        mainCoordinator = coordinator
        childCoordinators.append(coordinator)
        coordinator.start()
    }
}

extension AppCoordinator: AuthCoordinatorDelegate {
    func didFinishAuthentication() {
        // Get the current user ID from Firebase Auth
        guard let currentUser = Auth.auth().currentUser else {
            print("ERROR - AppCoordinator: User authenticated but Firebase user is nil")
            return
        }
        
        // Initialize UserSessionManager with the logged-in user
        UserSessionManager.shared.userDidLogin(userID: currentUser.uid)
        
        // Set user login state
        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        childCoordinators.removeAll { $0 is AuthCoordinator }
        showMainFlow()
    }
}
