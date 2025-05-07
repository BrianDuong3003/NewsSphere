//
//  RegisterViewController.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import Foundation
import UIKit
import Stevia
import FirebaseCore
import FirebaseAuth

class RegisterViewController: UIViewController, UITextFieldDelegate {
    let viewModel = RegisterViewModel()
    weak var coordinator: AuthCoordinator?
    
    let titleLabel = UILabel()
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    
    let hideStackView = UIStackView()
    let hideImageView = UIImageView()
    let hideLabel = UILabel()
    
    let firstNameTextField = UITextField()
    let lastNameTextField = UITextField()
    
    let policyLabel = UILabel()
    
    let registerButton = GradientButton()
    
    let havedButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStyle()
        setupConstraints()
        setupActions()
        setupBindings()
    }
    
    func setupBindings() {
        viewModel.onErrorMessage = { [weak self] message in
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default))
            self?.present(alert, animated: true)
        }
        
        viewModel.onRegisterSuccess = { [weak self] in
            let alert = UIAlertController(title: "Success",
                                          message: "Registration successful!",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self?.navigationController?.popViewController(animated: true)
            }))
            self?.present(alert, animated: true)
        }
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(togglePasswordVisibility))
        hideImageView.isUserInteractionEnabled = true
        hideImageView.addGestureRecognizer(tapGesture)
        registerButton.addTarget(self, action: #selector(registerAccount), for: .touchUpInside)
        havedButton.addTarget(self, action: #selector(havedAccount), for: .touchUpInside)
    }
    
    @objc func registerAccount() {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        viewModel.register(email: email, password: password,
                           firstName: firstName, lastName: lastName)
    }
    
    @objc func havedAccount() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
    }
    
    private func setupView() {
        navigationItem.hidesBackButton = true
        
        // Setup the hideStackView
        hideStackView.axis = .horizontal
        hideStackView.distribution = .fill
        hideStackView.alignment = .center
        hideStackView.spacing = 6
        hideStackView.addArrangedSubview(hideImageView)
        hideStackView.addArrangedSubview(hideLabel)
        
        // Add subviews using block syntax
        view.subviews {
            titleLabel
            emailTextField
            passwordTextField
            hideStackView
            firstNameTextField
            lastNameTextField
            policyLabel
            registerButton
            havedButton
        }
    }
    
    private func setupStyle() {
        view.backgroundColor = .hexBackGround
        
        titleLabel.font = .systemFont(ofSize: 25, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.text = "Register"
        
        applyTextFieldStyle(emailTextField, placeholder: "Email")
        emailTextField.delegate = self
        
        applyTextFieldStyle(passwordTextField, placeholder: "Password")
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
        
        hideImageView.image = UIImage(named: "hideImage")
        hideImageView.frame.size = CGSize(width: 40, height: 40)
        hideImageView.contentMode = .scaleAspectFill
        
        hideLabel.text = "Hide password"
        hideLabel.textColor = .hexGrey
        hideLabel.font = .systemFont(ofSize: 18, weight: .medium)
        
        applyTextFieldStyle(firstNameTextField, placeholder: "First name")
        firstNameTextField.delegate = self
        applyTextFieldStyle(lastNameTextField, placeholder: "Last name")
        lastNameTextField.delegate = self
        
        policyLabel.text = """
        By registering and using this application, you agree and acknowledge that you understand the \
        End-User License Agreement (EULA) & Privacy Policy. Click here to see detail.
        """
        policyLabel.textColor = .red
        policyLabel.font = .systemFont(ofSize: 15, weight: .medium)
        policyLabel.numberOfLines = 0
        policyLabel.lineBreakMode = .byWordWrapping
        
        registerButton.setTitle("Register", for: .normal)
        registerButton.setTitleColor(.label, for: .normal)
        registerButton.setGradientColors(startColor: .hexBrown,
                                         endColor: .hexDarkRed)
        registerButton.setGradientDirection(startPoint: CGPoint(x: 0, y: 0.5),
                                            endPoint: CGPoint(x: 1, y: 0.5))
        registerButton.layer.cornerRadius = 10
        registerButton.clipsToBounds = true
        
        havedButton.setTitle("Already have an account? Login", for: .normal)
        havedButton.setTitleColor(.label, for: .normal)
        havedButton.backgroundColor = .hexDarkGrey
        havedButton.layer.cornerRadius = 10
    }
    
    private func setupConstraints() {
        titleLabel.top(10%).centerHorizontally()
        
        emailTextField.Top == titleLabel.Bottom + 58
        emailTextField.Leading == view.Leading + 13
        emailTextField.Trailing == view.Trailing - 13
        emailTextField.height(7%)
        
        passwordTextField.Top == emailTextField.Bottom + 24
        passwordTextField.Leading == view.Leading + 13
        passwordTextField.Trailing == view.Trailing - 13
        passwordTextField.height(7%)
        
        hideStackView.Top == passwordTextField.Bottom + 24
        hideStackView.Leading == view.Leading + 13
        
        firstNameTextField.Top == hideStackView.Bottom + 35
        firstNameTextField.Leading == view.Leading + 13
        firstNameTextField.Trailing == view.Trailing - 13
        firstNameTextField.height(7%)
        
        lastNameTextField.Top == firstNameTextField.Bottom + 20
        lastNameTextField.Leading == view.Leading + 13
        lastNameTextField.Trailing == view.Trailing - 13
        lastNameTextField.height(7%)
        
        policyLabel.Top == lastNameTextField.Bottom + 18
        policyLabel.Leading == view.Leading + 13
        policyLabel.Trailing == view.Trailing - 13
        
        registerButton.Top == policyLabel.Bottom + 20
        registerButton.Leading == view.Leading + 13
        registerButton.Trailing == view.Trailing - 13
        registerButton.height(7%)
        
        havedButton.Top == registerButton.Bottom + 20
        havedButton.Leading == view.Leading + 13
        havedButton.Trailing == view.Trailing - 13
        havedButton.height(7%)
    }
    
    private func applyTextFieldStyle(_ textField: UITextField, placeholder: String) {
        textField.backgroundColor = .hexDarkGrey
        textField.textColor = .hexDarkText
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(.hexDarkText)]
        )
    }
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
