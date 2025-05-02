//
//  AuthCoordinator.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import UIKit

protocol AuthCoordinatorDelegate: AnyObject {
    func didFinishAuthentication()
}

class AuthCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var window: UIWindow
    weak var delegate: AuthCoordinatorDelegate?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let loginVC = LoginViewController()
        loginVC.coordinator = self
        let navigationController = UINavigationController(rootViewController: loginVC)
        window.rootViewController = navigationController
    }
    
    func showRegister() {
        print("Current rootViewController: \(String(describing: type(of: window.rootViewController)))")
        
        var navigationController: UINavigationController?
        
        if let navController = window.rootViewController as? UINavigationController {
            navigationController = navController
        } else if let tabController = window.rootViewController as? UITabBarController,
                  let selectedNav = tabController.selectedViewController as? UINavigationController {
            
            navigationController = selectedNav
        } else if let presentedNav = window.rootViewController?
            .presentedViewController as? UINavigationController {
            
            navigationController = presentedNav
        }
        
        if let navigationController = navigationController {
            let registerVC = RegisterViewController()
            registerVC.coordinator = self
            navigationController.pushViewController(registerVC, animated: true)
        } else {
            // If no navigation controller found, create and present one
            let registerVC = RegisterViewController()
            registerVC.coordinator = self
            let newNavController = UINavigationController(rootViewController: registerVC)
            window.rootViewController?.present(newNavController, animated: true)
        }
    }
    
    func didFinishLogin() {
        print("didFinishLogin called")
        delegate?.didFinishAuthentication()
    }
}
