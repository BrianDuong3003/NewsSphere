import UIKit
import Stevia
import FirebaseAuth

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = LoginViewModel()
    weak var coordinator: AuthCoordinator?
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    
    private let hideStackView = UIStackView()
    private let hideImageView = UIImageView()
    private let hideLabel = UILabel()
    
    private let loginButton = GradientButton()
    private let registerButton = UIButton()
    private let forgotPassButton = UIButton()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStyle()
        setupConstraints()
        setupActions()
        setupBindings()
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        viewModel.onLoginSuccess = { [weak self] in
            guard let self = self else { return }
            
            print("Login successful")
            
            self.activityIndicator.stopAnimating()
            
            if let coordinator = self.coordinator {
                coordinator.didFinishLogin()
            } else {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                    
                    let mainCoordinator = MainCoordinator(window: window)
                    window.rootViewController = nil
                    mainCoordinator.start()
                }
            }
        }
        
        viewModel.onLoginFailure = { [weak self] errorMessage in
            guard let self = self else { return }
            
            print("Login failed: \(errorMessage)")
            self.activityIndicator.stopAnimating()
            
            let alert = UIAlertController(
                title: "Login Error",
                message: errorMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    // MARK: - Actions
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(togglePasswordVisibility))
        hideImageView.isUserInteractionEnabled = true
        hideImageView.addGestureRecognizer(tapGesture)
        
        loginButton.addTarget(self, action: #selector(loginAccount), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerAccount), for: .touchUpInside)
        forgotPassButton.addTarget(self, action: #selector(forgotPassword), for: .touchUpInside)
        
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapToDismissKeyboard)
    }
    
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        hideLabel.text = passwordTextField.isSecureTextEntry ? "Show password" : "Hide password"
    }
    
    @objc private func loginAccount() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else { return }
        
        viewModel.login(email: email, password: password)
    }
    
    @objc private func registerAccount() {
        navigationController?.pushViewController(RegisterViewController(), animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func forgotPassword() {
        let alert = UIAlertController(
            title: "Password Recovery",
            message: "Please enter your email to recover your password",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
            if let email = self.emailTextField.text, !email.isEmpty {
                textField.text = email
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let resetAction = UIAlertAction(title: "Send", style: .default) { [weak self] _ in
            guard let email = alert.textFields?.first?.text, !email.isEmpty else {
                self?.showAlert(title: "Error", message: "Please enter email")
                return
            }
            
            if !(self?.viewModel.isValidEmail(email) ?? false) {
                self?.showAlert(title: "Error", message: "Invalid email format")
                return
            }
            
            self?.activityIndicator.startAnimating()
            
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                self?.activityIndicator.stopAnimating()
                
                if let error = error {
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                } else {
                    self?.showAlert(title: "Success", message:
                                        "Password reset link has been sent to your email")
                }
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(resetAction)
        present(alert, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - UI Setup
    private func setupView() {
        setupHideStack()
        
        view.subviews {
            titleLabel
            emailTextField
            passwordTextField
            hideStackView
            loginButton
            registerButton
            forgotPassButton
            activityIndicator
        }
    }
    
    private func setupHideStack() {
        hideStackView.axis = .horizontal
        hideStackView.spacing = 6
        hideStackView.alignment = .center
        hideStackView.distribution = .fill
        hideStackView.addArrangedSubview(hideImageView)
        hideStackView.addArrangedSubview(hideLabel)
    }
    
    private func setupStyle() {
        view.backgroundColor = .hexBackGround
        
        titleLabel.text = "Login"
        titleLabel.font = .systemFont(ofSize: 25, weight: .semibold)
        titleLabel.textColor = .white
        
        applyTextFieldStyle(emailTextField, placeholder: "Email")
        applyTextFieldStyle(passwordTextField, placeholder: "Password")
        passwordTextField.isSecureTextEntry = true
        
        hideImageView.image = UIImage(named: "hideImage")
        hideImageView.frame.size = CGSize(width: 40, height: 40)
        hideImageView.contentMode = .scaleAspectFill
        
        hideLabel.text = "Hide password"
        hideLabel.textColor = .hexDarkGrey
        hideLabel.font = .systemFont(ofSize: 18, weight: .medium)
        
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.label, for: .normal)
        loginButton.setGradientColors(startColor: .hexBrown,
                                      endColor: .hexDarkRed)
        loginButton.setGradientDirection(startPoint: CGPoint(x: 0, y: 0.5),
                                         endPoint: CGPoint(x: 1, y: 0.5))
        loginButton.layer.cornerRadius = 10
        loginButton.clipsToBounds = true
        
        [registerButton, forgotPassButton].forEach {
            $0.setTitleColor(.label, for: .normal)
            $0.backgroundColor = .hexDarkGrey
            $0.layer.cornerRadius = 10
            $0.clipsToBounds = true
        }
        
        registerButton.setTitle("Register", for: .normal)
        forgotPassButton.setTitle("Forgot Password?", for: .normal)
        
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
    }
    
    private func setupConstraints() {
        titleLabel.top(10%).centerHorizontally()
        
        emailTextField.Top == titleLabel.Bottom + 58
        emailTextField.Leading == view.Leading + 13
        emailTextField.Trailing == view.Trailing - 13
        emailTextField.height(7%)
        
        passwordTextField.Top == emailTextField.Bottom + 24
        passwordTextField.Leading == emailTextField.Leading
        passwordTextField.Trailing == emailTextField.Trailing
        passwordTextField.height(7%)
        
        hideStackView.Top == passwordTextField.Bottom + 24
        hideStackView.Leading == emailTextField.Leading
        
        loginButton.Top == hideStackView.Bottom + 35
        loginButton.Leading == emailTextField.Leading
        loginButton.Trailing == emailTextField.Trailing
        loginButton.height(7%)
        
        registerButton.Top == loginButton.Bottom + 20
        registerButton.Leading == loginButton.Leading
        registerButton.Trailing == loginButton.Trailing
        registerButton.height(7%)
        
        forgotPassButton.Top == registerButton.Bottom + 20
        forgotPassButton.Leading == loginButton.Leading
        forgotPassButton.Trailing == loginButton.Trailing
        forgotPassButton.height(7%)
        
        activityIndicator.centerInContainer()
    }
    
    private func applyTextFieldStyle(_ textField: UITextField, placeholder: String) {
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 10
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
    }
}
