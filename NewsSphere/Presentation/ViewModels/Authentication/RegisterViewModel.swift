//
//  RegisterViewModel.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import Foundation
import FirebaseAuth
import RealmSwift

class RegisterViewModel {

    var onErrorMessage: ((String) -> Void)?
    var onRegisterSuccess: (() -> Void)?
    
    // RealmManager để lưu thông tin người dùng
    private let realmManager = RealmManager.shared

    func register(email: String, password: String, firstName: String, lastName: String) {
        
        guard !email.isEmpty, !password.isEmpty, !firstName.isEmpty, !lastName.isEmpty else {
            onErrorMessage?("Please fill in all required fields.")
            return
        }
        
        guard email.contains("@"), email.contains(".") else {
            onErrorMessage?("Invalid email.")
            return
        }
        
        guard password.count >= 6 else {
            onErrorMessage?("Password must be at least 6 characters long.")
            return
        }

        print("DEBUG - RegisterViewModel: Creating Firebase user with email: \(email)")
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] _, error in
            guard let self = self else { return }
            
            if let error = error {
                print("DEBUG - RegisterViewModel: Firebase error: \(error.localizedDescription)")
                self.onErrorMessage?(self.localizedErrorMessage(error))
            } else {
                print("DEBUG - RegisterViewModel: Firebase user created successfully")
                
                // Lưu thông tin người dùng vào Realm
                self.realmManager.saveUser(
                    email: email,
                    firstName: firstName,
                    lastName: lastName
                )
                
                // Test lại việc lưu bằng cách thử đọc thông tin
                if let user = self.realmManager.getUser(email: email) {
                    print("DEBUG - RegisterViewModel: Successfully verified user in Realm: \(user.firstName) \(user.lastName)")
                } else {
                    print("DEBUG - RegisterViewModel: Warning: Could not verify user in Realm after saving")
                }
                
                self.onRegisterSuccess?()
            }
        }
    }

    private func localizedErrorMessage(_ error: Error) -> String {
        let errCode = error as NSError
        
        if errCode.code == 17007 {
            return "Email is already in use."
        } else if errCode.code == 17008 {
            return "Invalid email."
        } else if errCode.code == 17026 {
            return "Password is too weak."
        } else {
            return "An error occurred. Please try again."
        }
    }
}
