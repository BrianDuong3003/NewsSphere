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
    let navigationController = UINavigationController()
    private var isSplashScreenShown = false
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        window.rootViewController = navigationController
        showSplashScreen()
        window.makeKeyAndVisible()
    }
    
    private func showSplashScreen() {
        let splashScreenVC = SplashScreenViewController(coordinator: self)
        navigationController.setViewControllers([splashScreenVC], animated: false)
        navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func finishSplashScreen() {
        isSplashScreenShown = true
        // Continue to the appropriate flow based on user's login status
        if isUserLoggedIn() {
            // Check user chooses fav category or not
            if UserDefaults.standard.bool(forKey: "hasSelectedCategories") {
                showMainFlow()
            } else {
                showSelectCategories()
            }
        } else {
            // Show guest flow instead of auth flow for unauthenticated users
            showGuestFlow()
        }
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
    
    private func showMainFlow(isAuthenticated: Bool = true) {
        // Clean up any existing coordinators
        childCoordinators.removeAll()
        
        let coordinator = MainCoordinator(window: window, isAuthenticated: isAuthenticated)
        mainCoordinator = coordinator
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    private func showGuestFlow() {
        // Show main flow with guest mode (unauthenticated)
        showMainFlow(isAuthenticated: false)
    }
    
    private func showSelectCategories() {
        navigationController.setNavigationBarHidden(true, animated: false)
        
        let viewModel = SelectCategoriesViewModel()
        let selectCategoriesVC = SelectCategoriesViewController(viewModel: viewModel)
        selectCategoriesVC.delegate = self
        navigationController.setViewControllers([selectCategoriesVC], animated: true)
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
        
        // Check user chooses fav category or not
        if !UserDefaults.standard.bool(forKey: "hasSelectedCategories") {
            showSelectCategories()
        } else {
            showMainFlow()
        }
    }
}

extension AppCoordinator: SelectCategoriesViewControllerDelegate {
    func didFinishSelectingCategories(didSkip: Bool) {
        print("DEBUG - AppCoordinator: User did \(didSkip ? "skip" : "complete") category selection")
        showMainFlow()
    }
}
