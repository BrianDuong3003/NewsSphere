//
//  UserRepository.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 1/5/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol UserRepositoryProtocol {
    func getUserProfile(uid: String, completion: @escaping ([String: Any]?, Error?) -> Void)
    func getCurrentUserProfile(completion: @escaping ([String: Any]?, Error?) -> Void)
    func deleteUserData(uid: String, completion: @escaping (Error?) -> Void)
    func saveUser(uid: String, email: String, firstName: String, lastName: String, completion: @escaping (Error?) -> Void)
    func logout() throws
    func deleteUserAccount(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class UserRepository: UserRepositoryProtocol {
    private let firestoreManager: FirestoreUserManager
    
    // MARK: - Initialization
    init(firestoreManager: FirestoreUserManager = FirestoreUserManager.shared) {
        self.firestoreManager = firestoreManager
    }
    
    // MARK: - UserRepositoryProtocol Implementation
    
    func getUserProfile(uid: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        firestoreManager.getUserByUID(uid: uid, completion: completion)
    }
    
    func getCurrentUserProfile(completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(nil, NSError(domain: "com.newssphere", code: 1000, userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in"]))
            return
        }
        
        getUserProfile(uid: currentUser.uid, completion: completion)
    }
    
    func deleteUserData(uid: String, completion: @escaping (Error?) -> Void) {
        firestoreManager.deleteUserData(uid: uid, completion: completion)
    }
    
    func saveUser(uid: String, email: String, firstName: String, lastName: String, completion: @escaping (Error?) -> Void) {
        firestoreManager.saveUser(uid: uid, email: email, firstName: firstName, lastName: lastName, completion: completion)
    }
    
    func logout() throws {
        try Auth.auth().signOut()
        UserSessionManager.shared.userDidLogout()
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
    }
    
    func deleteUserAccount(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("DEBUG_DELETE_ACCOUNT: UserRepository.deleteUserAccount called with email: \(email)")
        
        guard let currentUser = Auth.auth().currentUser else {
            print("DEBUG_DELETE_ACCOUNT: No user is currently signed in")
            completion(.failure(NSError(domain: "com.newssphere", code: 1001, userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in"])))
            return
        }
        
        print("DEBUG_DELETE_ACCOUNT: Creating credential for re-authentication")
        // Create credential for re-authentication
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        print("DEBUG_DELETE_ACCOUNT: Attempting to re-authenticate user")
        // Re-authenticate the user
        currentUser.reauthenticate(with: credential) { [weak self] _, error in
            guard let self = self else { return }
            
            if let error = error {
                print("DEBUG_DELETE_ACCOUNT: Re-authentication failed: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            print("DEBUG_DELETE_ACCOUNT: Re-authentication successful, proceeding with deletion")
            // Re-authentication successful, proceed with deletion
            self.performUserDeletion(completion: completion)
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func performUserDeletion(completion: @escaping (Result<Void, Error>) -> Void) {
        print("DEBUG_DELETE_ACCOUNT: performUserDeletion started")
        
        guard let currentUser = Auth.auth().currentUser,
              let userID = currentUser.uid as String? else {
            print("DEBUG_DELETE_ACCOUNT: Failed to get current user ID")
            completion(.failure(NSError(domain: "com.newssphere", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Failed to get current user ID"])))
            return
        }
        
        print("DEBUG_DELETE_ACCOUNT: Deleting user data from Firestore for UID: \(userID)")
        // Delete user data from Firestore
        deleteUserData(uid: userID) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("DEBUG_DELETE_ACCOUNT: Failed to delete Firestore data: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            print("DEBUG_DELETE_ACCOUNT: Firestore data deleted successfully, now deleting Auth account")
            // Delete user account from Firebase Auth
            currentUser.delete { error in
                if let error = error {
                    print("DEBUG_DELETE_ACCOUNT: Failed to delete Firebase Auth account: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                print("DEBUG_DELETE_ACCOUNT: Firebase Auth account deleted successfully")
                // Clean up local Realm data
                UserSessionManager.shared.userDidLogout()
                
                print("DEBUG_DELETE_ACCOUNT: User account deleted successfully, all steps completed")
                completion(.success(()))
            }
        }
    }
} 
