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
        guard let topViewController = navigationController.topViewController else { return }
        
        let alert = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to delete your account? This action cannot be undone and all your data will be lost.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.showPasswordConfirmation()
        })
        
        topViewController.present(alert, animated: true)
    }
    
    private func showPasswordConfirmation() {
        guard let topViewController = navigationController.topViewController,
              let currentUser = Auth.auth().currentUser,
              let email = currentUser.email else { return }
        
        let alert = UIAlertController(
            title: "Confirm Password",
            message: "Please enter your password to delete your account",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive) { [weak self, weak alert] _ in
            guard let self = self,
                  let password = alert?.textFields?.first?.text,
                  !password.isEmpty else { return }
            
            self.deleteUserAccount(email: email, password: password) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.showDeletionSuccessAlert()
                    case .failure(let error):
                        self.showErrorAlert(message: error.localizedDescription)
                    }
                }
            }
        })
        
        topViewController.present(alert, animated: true)
    }
    
    private func deleteUserAccount(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "com.newssphere", code: 1001, userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in"])))
            return
        }
        
        // Create credential for re-authentication
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        // Re-authenticate the user
        currentUser.reauthenticate(with: credential) { [weak self] _, error in
            guard let self = self else { return }
            
            if let error = error {
                print("DEBUG - ProfileCoordinator: Re-authentication failed: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            // Re-authentication successful, proceed with deletion
            self.performUserDeletion(completion: completion)
        }
    }
    
    private func performUserDeletion(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser,
              let userID = currentUser.uid as String? else {
            completion(.failure(NSError(domain: "com.newssphere", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Failed to get current user ID"])))
            return
        }
        
        // 1. Delete user data from Firestore
        FirestoreUserManager.shared.deleteUserData(uid: userID) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("DEBUG - ProfileCoordinator: Failed to delete Firestore data: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            // 2. Delete user account from Firebase Auth
            currentUser.delete { error in
                if let error = error {
                    print("DEBUG - ProfileCoordinator: Failed to delete Firebase Auth account: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                // 3. Clean up local Realm data
                UserSessionManager.shared.userDidLogout()
                
                // 4. Return success
                print("DEBUG - ProfileCoordinator: User account deleted successfully")
                completion(.success(()))
            }
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
}
