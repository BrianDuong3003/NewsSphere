//
//  ProfileViewController.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//
import UIKit
import FirebaseAuth
import Stevia

class ProfileViewController: UIViewController {
    // MARK: - Properties
    var coordinator: ProfileCoordinator?
    let viewModel: ProfileViewModel
    
    // MARK: - UI Elements
    private let contentView = UIView()
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    
    private let optionsStackView = UIStackView()
    
    // Bookmark
    private let bookmarkOptionView = UIView()
    private let bookmarkLabel = UILabel()
    private let bookmarkIconView = UIImageView()
    
    // Read Offline
    private let readOfflineOptionView = UIView()
    private let readOfflineLabel = UILabel()
    private let readOfflineIconView = UIImageView()
    
    // Favorite Categories
    private let favoriteCategoriesOptionView = UIView()
    private let favoriteCategoriesLabel = UILabel()
    private let favoriteCategoriesIconView = UIImageView()
    
    // Logout
    private let logoutLabel = UILabel()
    private let logoutIconView = UIImageView()
    private let logoutContainerView = UIView()
    
    // Delete Account
    private let deleteAccountLabel = UILabel()
    
    // rule
    private let ruleLabel = UILabel()
    
    // MARK: - Lifecycle
    init(viewModel: ProfileViewModel = ProfileViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStyle()
        setupConstraints()
        setupActions()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserProfile()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updateUIBasedOnAuthState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }
    
    // MARK: - Setup Methods (Private)
    private func setupView() {
        view.subviews {
            contentView
        }
        
        contentView.subviews {
            avatarImageView
            nameLabel
            emailLabel
            optionsStackView
            logoutContainerView.subviews {
                logoutIconView
                logoutLabel
            }
            deleteAccountLabel
            ruleLabel
        }
        
        optionsStackView.addArrangedSubview(bookmarkOptionView)
        optionsStackView.addArrangedSubview(readOfflineOptionView)
        optionsStackView.addArrangedSubview(favoriteCategoriesOptionView)
        
        bookmarkOptionView.subviews {
            bookmarkLabel
            bookmarkIconView
        }
        
        readOfflineOptionView.subviews {
            readOfflineLabel
            readOfflineIconView
        }
        
        favoriteCategoriesOptionView.subviews {
            favoriteCategoriesLabel
            favoriteCategoriesIconView
        }
    }
    
    private func setupStyle() {
        view.backgroundColor = .hexBackGround
        title = "Profile"
        
        avatarImageView.backgroundColor = .hexBackGround
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.image = UIImage(named: "default")
        
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0
        
        emailLabel.font = .systemFont(ofSize: 16, weight: .regular)
        emailLabel.textColor = .hexGrey
        emailLabel.textAlignment = .center
        
        optionsStackView.axis = .vertical
        optionsStackView.spacing = 16
        optionsStackView.distribution = .fillEqually
        
        bookmarkOptionView.backgroundColor = .hexBackGround
        bookmarkOptionView.layer.cornerRadius = 12
        bookmarkOptionView.layer.borderWidth = 0.3
        bookmarkOptionView.layer.borderColor = UIColor.hexGrey.cgColor
        
        bookmarkLabel.text = "Bookmark"
        bookmarkLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        bookmarkLabel.textColor = .white
        
        bookmarkIconView.image = UIImage(systemName: "bookmark.fill")
        bookmarkIconView.tintColor = .hexGrey
        bookmarkIconView.contentMode = .scaleAspectFit
        
        readOfflineOptionView.backgroundColor = .hexBackGround
        readOfflineOptionView.layer.cornerRadius = 12
        readOfflineOptionView.layer.borderWidth = 0.3
        readOfflineOptionView.layer.borderColor = UIColor.hexGrey.cgColor
        
        readOfflineLabel.text = "Read Offline"
        readOfflineLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        readOfflineLabel.textColor = .white
        
        readOfflineIconView.image = UIImage(named: "vtdl")
        readOfflineIconView.tintColor = .white
        readOfflineIconView.contentMode = .scaleAspectFit
        
        logoutIconView.image = UIImage(named: "logout")
        logoutIconView.tintColor = .hexExRed
        logoutIconView.contentMode = .scaleAspectFit
        
        logoutLabel.text = "Logout"
        logoutLabel.font = .systemFont(ofSize: 20, weight: .medium)
        logoutLabel.textColor = .hexExRed
        
        deleteAccountLabel.text = "Delete My Account"
        deleteAccountLabel.font = .systemFont(ofSize: 16, weight: .medium)
        deleteAccountLabel.textColor = .hexExRed
        
        ruleLabel.text = "By registering and using this application, you agree and acknowledge that you understand the End-User License Agreement (EULA) & Privacy Policy."
        ruleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        ruleLabel.textColor = .hexGrey
        ruleLabel.numberOfLines = 0
        
        favoriteCategoriesOptionView.backgroundColor = .hexBackGround
        favoriteCategoriesOptionView.layer.cornerRadius = 12
        favoriteCategoriesOptionView.layer.borderWidth = 0.3
        favoriteCategoriesOptionView.layer.borderColor = UIColor.hexGrey.cgColor
        
        favoriteCategoriesLabel.text = "Favorite Categories"
        favoriteCategoriesLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        favoriteCategoriesLabel.textColor = .white
        
        favoriteCategoriesIconView.image = UIImage(systemName: "star.fill")
        favoriteCategoriesIconView.tintColor = .hexGrey
        favoriteCategoriesIconView.contentMode = .scaleAspectFit
    }
    
    private func setupConstraints() {
        contentView.width(UIScreen.main.bounds.width)
        contentView.height(UIScreen.main.bounds.height)
        contentView.top(0).left(0).right(0).bottom(0)
        
        avatarImageView.width(120).height(120)
        avatarImageView.centerHorizontally()
        avatarImageView.top(100)
        
        nameLabel.centerHorizontally()
        nameLabel.Top == avatarImageView.Bottom + 20
        nameLabel.left(20).right(20)
        
        emailLabel.centerHorizontally()
        emailLabel.Top == nameLabel.Bottom + 8
        emailLabel.left(20).right(20)
        
        optionsStackView.Top == emailLabel.Bottom + 40
        optionsStackView.left(20).right(20)
        optionsStackView.height(180)
        
        bookmarkLabel.centerVertically()
        bookmarkLabel.Leading == bookmarkOptionView.Leading + 16
        
        bookmarkIconView.centerVertically()
        bookmarkIconView.Trailing == bookmarkOptionView.Trailing - 16
        bookmarkIconView.width(24).height(24)
        
        readOfflineLabel.centerVertically()
        readOfflineLabel.Leading == readOfflineOptionView.Leading + 16
        
        readOfflineIconView.centerVertically()
        readOfflineIconView.Trailing == readOfflineOptionView.Trailing - 16
        readOfflineIconView.width(24).height(24)
        
        favoriteCategoriesLabel.centerVertically()
        favoriteCategoriesLabel.Leading == favoriteCategoriesOptionView.Leading + 16
        
        favoriteCategoriesIconView.centerVertically()
        favoriteCategoriesIconView.Trailing == favoriteCategoriesOptionView.Trailing - 16
        favoriteCategoriesIconView.width(24).height(24)
        
        logoutContainerView.Top == optionsStackView.Bottom + 40
        logoutContainerView.centerHorizontally()
        
        logoutIconView.Leading == logoutContainerView.Leading
        logoutIconView.CenterY == logoutContainerView.CenterY
        logoutIconView.width(26).height(26)
        
        logoutLabel.Leading == logoutIconView.Trailing + 10
        logoutLabel.CenterY == logoutIconView.CenterY
        logoutLabel.Trailing == logoutContainerView.Trailing
        
        logoutContainerView.Height >= logoutIconView.Height
        logoutContainerView.Height >= logoutLabel.Height
        
        ruleLabel.Top == logoutContainerView.Bottom + 50
        ruleLabel.left(20).right(20)
        
        deleteAccountLabel.Top == ruleLabel.Bottom + 20
        deleteAccountLabel.left(20).right(20)
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        viewModel.onProfileDataLoaded = { [weak self] in
            self?.updateUIWithUserData()
        }
        
        viewModel.onError = { [weak self] errorMessage in
            // Show error message to user
            print("DEBUG - ProfileViewController: Error: \(errorMessage)")
        }
        
        viewModel.onLogoutSuccess = { [weak self] in
            self?.coordinator?.didLogout()
        }
        
        viewModel.onAccountDeleted = { [weak self] in
            print("DEBUG_DELETE_ACCOUNT: Account deleted callback received in ProfileViewController")
            self?.coordinator?.didLogout()
        }
    }
    
    // MARK: - Private Methods
    private func loadUserProfile() {
        viewModel.loadUserProfile()
    }
    
    private func updateUIWithUserData() {
        nameLabel.text = viewModel.getFormattedFullName()
        emailLabel.text = viewModel.getDisplayEmail()
        
        // Update auth button text
        logoutLabel.text = viewModel.getAuthButtonText()
        
        updateUIBasedOnAuthState()
    }
    
    private func updateUIBasedOnAuthState() {
        // Show/hide elements based on authentication state
        favoriteCategoriesOptionView.isHidden = !viewModel.canAccessFavoriteCategories()
        bookmarkOptionView.isHidden = !viewModel.canAccessBookmarks()
        readOfflineOptionView.isHidden = !viewModel.canAccessReadOffline()
        deleteAccountLabel.isHidden = !viewModel.shouldShowDeleteAccount()
        
        // Update logout/login button appearance
        if viewModel.shouldShowLogout() {
            logoutLabel.text = "Logout"
            logoutLabel.textColor = .hexExRed
            logoutIconView.tintColor = .hexExRed
        } else {
            logoutLabel.text = "Login"
            logoutLabel.textColor = .hexOrange
            logoutIconView.image = UIImage(systemName: "person.circle.fill")
            logoutIconView.tintColor = .hexOrange
        }
        
        // Adjust stack view spacing based on what's visible
        optionsStackView.arrangedSubviews.forEach { view in
            view.isHidden = view.isHidden // Trigger layout update
        }
    }
    
    // MARK: - Actions
    private func setupActions() {
        let bookmarkGesture = UITapGestureRecognizer(target: self, action: #selector(bookmarkTapped))
        bookmarkOptionView.addGestureRecognizer(bookmarkGesture)
        
        let readOfflineGesture = UITapGestureRecognizer(target: self, action: #selector(readOfflineTapped))
        readOfflineOptionView.addGestureRecognizer(readOfflineGesture)
        
        let favoriteCategoriesGesture = UITapGestureRecognizer(target: self, action: #selector(favoriteCategoriesTapped))
        favoriteCategoriesOptionView.addGestureRecognizer(favoriteCategoriesGesture)
        
        let logoutGesture = UITapGestureRecognizer(target: self, action: #selector(logoutTapped))
        logoutContainerView.addGestureRecognizer(logoutGesture)
        
        let deleteAccountGesture = UITapGestureRecognizer(target: self, action: #selector(deleteAccountTapped))
        deleteAccountLabel.addGestureRecognizer(deleteAccountGesture)
        deleteAccountLabel.isUserInteractionEnabled = true
    }
    
    @objc private func bookmarkTapped() {
        coordinator?.navigateToBookmarks()
    }
    
    @objc private func readOfflineTapped() {
        coordinator?.navigateToReadOffline()
    }
    
    @objc private func favoriteCategoriesTapped() {
        coordinator?.showEditFavoriteCategories()
    }
    
    @objc private func logoutTapped() {
        if viewModel.shouldShowLogout() {
            viewModel.logout()
        } else {
            // If not authenticated, navigate to login screen
            coordinator?.navigateToLogin()
        }
    }
    
    @objc private func deleteAccountTapped() {
        print("DEBUG_DELETE_ACCOUNT: deleteAccountOptionTapped method called")
        if let coordinator = coordinator {
            print("DEBUG_DELETE_ACCOUNT: coordinator exists, calling showDeleteAccountConfirmation")
            coordinator.showDeleteAccountConfirmation()
        } else {
            print("DEBUG_DELETE_ACCOUNT: ERROR - coordinator is nil")
        }
    }
}
