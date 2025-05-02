//
//  ArticleDetailViewModel.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import Foundation
import FirebaseAuth

class RegisterViewModel {

    var onErrorMessage: ((String) -> Void)?
    var onRegisterSuccess: (() -> Void)?

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

        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let error = error {
                self.onErrorMessage?(self.localizedErrorMessage(error))
            } else {
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
