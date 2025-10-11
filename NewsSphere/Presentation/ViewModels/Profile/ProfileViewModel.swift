//
//  ProfileViewModel.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import Foundation
import FirebaseAuth

class ProfileViewModel {
    // MARK: - Properties
    private let userRepository: UserRepositoryProtocol
    
    // Data properties
    private(set) var firstName: String = ""
    private(set) var lastName: String = ""
    private(set) var email: String = ""
    private(set) var isLoggedIn: Bool = false
    private(set) var isAuthenticated: Bool = true
    
    // MARK: - Binding Callbacks
    var onProfileDataLoaded: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLogoutSuccess: (() -> Void)?
    var onAccountDeleted: (() -> Void)?
    
    // MARK: - Initialization
    init(userRepository: UserRepositoryProtocol = UserRepository(), isAuthenticated: Bool = true) {
        self.userRepository = userRepository
        self.isAuthenticated = isAuthenticated
        checkLoginStatus()
    }
    
    // MARK: - Public Methods
    
    func loadUserProfile() {
        guard isAuthenticated, isLoggedIn else {
            onProfileDataLoaded?() // callback to update UI for guest mode
            return
        }
        
        userRepository.getCurrentUserProfile { [weak self] userData, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    print("DEBUG - ProfileViewModel: Error fetching profile: \(error.localizedDescription)")
                    self.onError?("Failed to load profile: \(error.localizedDescription)")
                }
                return
            }
            
            if let userData = userData {
                DispatchQueue.main.async {
                    self.updateUserData(userData)
                    self.onProfileDataLoaded?()
                }
            } else {
                DispatchQueue.main.async {
                    print("DEBUG - ProfileViewModel: No user profile data found")
                    self.onError?("Profile data not found")
                }
            }
        }
    }
    
    func logout() {
        do {
            try userRepository.logout()
            isLoggedIn = false
            onLogoutSuccess?()
        } catch {
            print("DEBUG - ProfileViewModel: Error logging out: \(error.localizedDescription)")
            onError?("Failed to logout: \(error.localizedDescription)")
        }
    }
    
    func deleteAccount(password: String) {
        print("DEBUG_DELETE_ACCOUNT: ProfileViewModel.deleteAccount called with password length: \(password.count)")
        
        guard isLoggedIn, !email.isEmpty else {
            print("DEBUG_DELETE_ACCOUNT: Not logged in or email is empty. isLoggedIn: \(isLoggedIn), email: \(email)")
            onError?("Not logged in or email is empty")
            return
        }
        
        print("DEBUG_DELETE_ACCOUNT: Calling userRepository.deleteUserAccount with email: \(email)")
        userRepository.deleteUserAccount(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("DEBUG_DELETE_ACCOUNT: Account deletion successful")
                    self.isLoggedIn = false
                    self.onAccountDeleted?()
                case .failure(let error):
                    print("DEBUG_DELETE_ACCOUNT: Failed to delete account: \(error.localizedDescription)")
                    self.onError?("Failed to delete account: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    // Format user name for display
    func getFormattedFullName() -> String {
        if !isAuthenticated {
            return "Guest User"
        }
        
        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
        return fullName.isEmpty ? "Profile Incomplete" : fullName
    }
    
    // Get display email
    func getDisplayEmail() -> String {
        if !isAuthenticated {
            return "Please login to access all features"
        }
        return email
    }
    
    // Check if user can see favorite categories
    func canAccessFavoriteCategories() -> Bool {
        return isAuthenticated && isLoggedIn
    }
    
    // Check if user can access theme toggle - available to all users
    func canAccessThemeToggle() -> Bool {
        return true
    }
    
    // Check if user can see bookmarks
    func canAccessBookmarks() -> Bool {
        return isAuthenticated && isLoggedIn
    }
    
    // Check if user can see read offline
    func canAccessReadOffline() -> Bool {
        return isAuthenticated && isLoggedIn
    }
    
    // Check if logout should be shown
    func shouldShowLogout() -> Bool {
        return isAuthenticated && isLoggedIn
    }
    
    // Check if delete account should be shown
    func shouldShowDeleteAccount() -> Bool {
        return isAuthenticated && isLoggedIn
    }
    
    // Get login button text
    func getAuthButtonText() -> String {
        return isAuthenticated && isLoggedIn ? "Logout" : "Login"
    }
    
    // MARK: - Private Methods
    
    private func checkLoginStatus() {
        isLoggedIn = Auth.auth().currentUser != nil
        if isLoggedIn, let userEmail = Auth.auth().currentUser?.email {
            self.email = userEmail
        }
    }
    
    private func updateUserData(_ userData: [String: Any]) {
        firstName = userData["firstName"] as? String ?? ""
        lastName = userData["lastName"] as? String ?? ""
        
        if let userEmail = userData["email"] as? String {
            email = userEmail
        }
    }
}
