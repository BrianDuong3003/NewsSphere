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
    
    // FirestoreUserManager để lưu thông tin người dùng lên cloud
    private let firestoreManager = FirestoreUserManager.shared

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
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                print("DEBUG - RegisterViewModel: Firebase error: \(error.localizedDescription)")
                self.onErrorMessage?(self.localizedErrorMessage(error))
            } else {
                print("DEBUG - RegisterViewModel: Firebase user created successfully")
                
                // Lấy UID từ kết quả đăng ký
                guard let user = authResult?.user, let uid = Auth.auth().currentUser?.uid else {
                    print("DEBUG - RegisterViewModel: Unable to get UID from Firebase Auth")
                    self.onErrorMessage?("Lỗi xác thực. Vui lòng thử lại.")
                    return
                }
                
                // Lưu thông tin người dùng vào Firestore với UID
                self.firestoreManager.saveUser(uid: uid, email: email, firstName: firstName, lastName: lastName) { error in
                    if let error = error {
                        print("DEBUG - RegisterViewModel: Error saving user to Firestore: \(error.localizedDescription)")
                        self.onErrorMessage?("Đăng ký thành công nhưng không lưu được thông tin người dùng. Vui lòng cập nhật trong Profile.")
                        self.onRegisterSuccess?()
                    } else {
                        print("DEBUG - RegisterViewModel: User successfully saved to Firestore")
                        self.onRegisterSuccess?()
                    }
                }
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
