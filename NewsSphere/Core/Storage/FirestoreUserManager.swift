//
//  FirestoreUserManager.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 20/9/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class FirestoreUserManager {
    static let shared = FirestoreUserManager()
    private let db = Firestore.firestore()
    private let usersCollection = "users"
    
    private init() {}
    
    // Save user in4 to firestore
    func saveUser(uid: String, email: String, firstName: String, lastName: String, completion: @escaping (Error?) -> Void) {
        let userData: [String: Any] = [
            "email": email,
            "firstName": firstName,
            "lastName": lastName,
            "registerDate": Timestamp(date: Date())
        ]
        
        // Use UID to make document ID
        db.collection(usersCollection).document(uid).setData(userData) { error in
            if let error = error {
                print("DEBUG - FirestoreUserManager: Error saving user to Firestore: \(error.localizedDescription)")
                completion(error)
            } else {
                print("DEBUG - FirestoreUserManager: User saved successfully to Firestore: \(firstName) \(lastName)")
                completion(nil)
            }
        }
    }
    
    // Save user in4 from firestore by UID
    func getUserByUID(uid: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        db.collection(usersCollection).document(uid).getDocument { snapshot, error in
            if let error = error {
                print("DEBUG - FirestoreUserManager: Error getting user from Firestore: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists, let userData = snapshot.data() else {
                print("DEBUG - FirestoreUserManager: User not found in Firestore for UID: \(uid)")
                completion(nil, nil)
                return
            }
            
            print("DEBUG - FirestoreUserManager: Retrieved user from Firestore: \(userData["firstName"] ?? "unknown") \(userData["lastName"] ?? "unknown")")
            completion(userData, nil)
        }
    }
    
    // Get current user in4
    func getCurrentUserProfile(completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard let currentUser = Auth.auth().currentUser, let uid = Auth.auth().currentUser?.uid else {
            print("DEBUG - FirestoreUserManager: No user currently signed in")
            completion(nil, nil)
            return
        }
        
        getUserByUID(uid: uid, completion: completion)
    }
} 
