//
//  UserSessionManager.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 1/5/25.
//

import Foundation
import FirebaseAuth

class UserSessionManager {
    static let shared = UserSessionManager()
    private(set) var realmManager: RealmManager?
    private(set) var currentUserID: String?
    
    private init() {
        setupCurrentUser()
    }
    
    // MARK: - User Management
    private func setupCurrentUser() {
        if let user = Auth.auth().currentUser {
            self.currentUserID = user.uid
            initializeRealmManager(forUserID: user.uid)
        } else {
            self.currentUserID = nil
            self.realmManager = nil
        }
    }
    
    // Handle user login
    func userDidLogin(userID: String) {
        self.currentUserID = userID
        initializeRealmManager(forUserID: userID)
    
        print("DEBUG - UserSessionManager: User logged in with ID: \(userID)")
    }
    
    // Handle user logout
    func userDidLogout() {
        // Clean up resources before logout
        self.realmManager = nil
        self.currentUserID = nil
        
        print("DEBUG - UserSessionManager: User logged out")
    }
    
    // MARK: - RealmManager
    // Initialize a new RealmManager for the given user
    private func initializeRealmManager(forUserID userID: String) {
        self.realmManager = RealmManager(userUID: userID)
        
        if self.realmManager == nil {
            print("ERROR - UserSessionManager: Failed to initialize RealmManager for user \(userID)")
        } else {
            print("DEBUG - UserSessionManager: RealmManager initialized for user \(userID)")
        }
    }
    
    // Get the current RealmManager
    func getCurrentRealmManager() -> RealmManager? {
        if let manager = realmManager {
            return manager
        } else if let userID = currentUserID {
            //  have a user ID but no manager? -> try to init realm mânger
            initializeRealmManager(forUserID: userID)
            return realmManager
        }
        return nil
    }
} 
