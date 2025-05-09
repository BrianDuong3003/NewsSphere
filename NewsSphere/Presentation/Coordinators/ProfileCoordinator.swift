//
//  ProfileCoordinator.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol ArticleNavigator: AnyObject {
    func showArticleDetail(_ article: Article, selectedCategory: String?)
    func didFinishReadOffline()
}

class ProfileCoordinator: Coordinator, ArticleNavigator {
    var childCoordinators: [any Coordinator] = []
    let navigationController: UINavigationController
    weak var parentCoordinator: MainCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {

    }
    
    func navigateToBookmarks() {
        let repository = ArticleRepository()
        let bookmarkRepository = BookmarkRepository()
        
        let bookmarkCoordinator = BookmarkCoordinator(
            navigationController: navigationController,
            repository: repository,
            bookmarkRepository: bookmarkRepository
        )
        
        childCoordinators.append(bookmarkCoordinator)
        bookmarkCoordinator.start()
    }
    
    func navigateToReadOffline() {
        let viewModel = ReadOfflineViewModel()
        let readOfflineViewController = ReadOfflineViewController(viewModel: viewModel)
        
        readOfflineViewController.coordinator = self
        
        navigationController.pushViewController(readOfflineViewController, animated: true)
    }
    
    func showArticleDetail(_ article: Article, selectedCategory: String?) {
        guard let parent = parentCoordinator else {
            print("ERROR - ProfileCoordinator: parentCoordinator is nil. Cannot show article detail.")
            return
        }
        parent.showArticleDetail(article, category: selectedCategory)
    }
    
    func didFinishReadOffline() {
        print("DEBUG - ProfileCoordinator: Finishing ReadOffline screen")
        navigationController.popViewController(animated: true)
    }
    
    func showDeleteAccountConfirmation() {
        print("DEBUG_DELETE_ACCOUNT: showDeleteAccountConfirmation called")
        
        guard let profileViewController = findProfileViewController() else {
            print("DEBUG_DELETE_ACCOUNT: Could not find ProfileViewController, cannot show confirmation")
            return
        }
        
        print("DEBUG_DELETE_ACCOUNT: Creating initial confirmation alert")
        let alert = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to delete your account? This action cannot be undone and all your data will be lost.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            print("DEBUG_DELETE_ACCOUNT: User confirmed deletion, showing password prompt")
            self?.showPasswordConfirmation()
        })
        
        print("DEBUG_DELETE_ACCOUNT: Presenting confirmation alert")
        profileViewController.present(alert, animated: true)
    }
    
    private func showPasswordConfirmation() {
        print("DEBUG_DELETE_ACCOUNT: showPasswordConfirmation started")
        
        guard let profileViewController = findProfileViewController() else {
            print("DEBUG_DELETE_ACCOUNT: Could not find ProfileViewController, cannot show password confirmation")
            return
        }
        
        print("DEBUG_DELETE_ACCOUNT: Creating password confirmation alert")
        let alert = UIAlertController(
            title: "Confirm Password",
            message: "Please enter your password to delete your account",
            preferredStyle: .alert
        )
        
        print("DEBUG_DELETE_ACCOUNT: Adding text field to alert")
        alert.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        print("DEBUG_DELETE_ACCOUNT: Adding actions to alert")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive) { [weak self, weak alert] _ in
            print("DEBUG_DELETE_ACCOUNT: Confirm button pressed")
            
            guard let password = alert?.textFields?.first?.text else {
                print("DEBUG_DELETE_ACCOUNT: Password from alert is nil")
                return
            }
            
            print("DEBUG_DELETE_ACCOUNT: Password entered: '\(password)'")
            
            guard !password.isEmpty else {
                print("DEBUG_DELETE_ACCOUNT: Password is empty, returning without deletion")
                return
            }
            
            print("DEBUG_DELETE_ACCOUNT: About to call viewModel.deleteAccount with password")
            profileViewController.viewModel.deleteAccount(password: password)
            print("DEBUG_DELETE_ACCOUNT: Called viewModel.deleteAccount")
        })
        
        print("DEBUG_DELETE_ACCOUNT: About to present password confirmation alert")
        profileViewController.present(alert, animated: true) {
            print("DEBUG_DELETE_ACCOUNT: Password confirmation alert presented")
        }
    }
    
    private func showDeletionSuccessAlert() {
        guard let topViewController = navigationController.topViewController else { return }
        
        let alert = UIAlertController(
            title: "Account Deleted",
            message: "Your account has been successfully deleted",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.didLogout()
        })
        
        topViewController.present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        guard let topViewController = navigationController.topViewController else { return }
        
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        topViewController.present(alert, animated: true)
    }
    
    func didLogout() {
        print("DEBUG - ProfileCoordinator: User logged out")
        // Clean up any resources if needed
        childCoordinators.removeAll()
        
        // Notify parent coordinator to handle the logout
        parentCoordinator?.userDidLogout()
    }
    
    func didFinish() {
        parentCoordinator?.childDidFinish(self)
    }
    
    private func findProfileViewController() -> ProfileViewController? {
        print("DEBUG_DELETE_ACCOUNT: Finding ProfileViewController")
        
        if let topViewController = navigationController.topViewController {
            print("DEBUG_DELETE_ACCOUNT: Top view controller is: \(type(of: topViewController))")
            
            // Check if it's directly a ProfileViewController
            if let profileVC = topViewController as? ProfileViewController {
                print("DEBUG_DELETE_ACCOUNT: Top view controller is ProfileViewController")
                return profileVC
            }
            
            // Check if it's MainViewController
            if let mainVC = topViewController as? MainViewController {
                print("DEBUG_DELETE_ACCOUNT: Top view controller is MainViewController")
                
                // Most reliable approach: Check all child view controllers
                for (index, childVC) in mainVC.children.enumerated() {
                    print("DEBUG_DELETE_ACCOUNT: Checking child[\(index)]: \(type(of: childVC))")
                    if let profileVC = childVC as? ProfileViewController {
                        print("DEBUG_DELETE_ACCOUNT: Found ProfileViewController as direct child at index \(index)")
                        return profileVC
                    }
                }
            }
        }
        
        print("DEBUG_DELETE_ACCOUNT: ERROR - Could not find ProfileViewController")
        return nil
    }
}
