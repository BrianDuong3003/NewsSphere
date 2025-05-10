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
        
        avatarImageView.backgroundColor = .lightGray
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
        // Handle profile data loaded event
        viewModel.onProfileDataLoaded = { [weak self] in
            guard let self = self else { return }
            self.updateUIWithProfileData()
        }
        
        // Handle error event
        viewModel.onError = { [weak self] errorMessage in
            guard let self = self else { return }
            print("DEBUG_DELETE_ACCOUNT: ProfileViewModel error: \(errorMessage)")
            self.showError(errorMessage)
        }
        
        // Handle logout success event
        viewModel.onLogoutSuccess = { [weak self] in
            guard let self = self else { return }
            self.coordinator?.didLogout()
        }
        
        // Handle account deleted event
        viewModel.onAccountDeleted = { [weak self] in
            guard let self = self else { return }
            print("DEBUG_DELETE_ACCOUNT: Account deleted successfully, calling didLogout")
            self.coordinator?.didLogout()
        }
    }
    
    // MARK: - Private Methods
    private func loadUserProfile() {
        viewModel.loadUserProfile()
    }
    
    private func updateUIWithProfileData() {
        nameLabel.text = viewModel.getFormattedFullName()
        emailLabel.text = viewModel.email
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    private func setupActions() {
        let bookmarkTapGesture = UITapGestureRecognizer(target: self, action: #selector(bookmarkOptionTapped))
        bookmarkOptionView.addGestureRecognizer(bookmarkTapGesture)
        bookmarkOptionView.isUserInteractionEnabled = true
        
        let readOfflineTapGesture = UITapGestureRecognizer(target: self, action: #selector(readOfflineOptionTapped))
        readOfflineOptionView.addGestureRecognizer(readOfflineTapGesture)
        readOfflineOptionView.isUserInteractionEnabled = true
        
        let deleteAccountTapGesture = UITapGestureRecognizer(target: self, action: #selector(deleteAccountOptionTapped))
        deleteAccountLabel.addGestureRecognizer(deleteAccountTapGesture)
        deleteAccountLabel.isUserInteractionEnabled = true
        
        let logoutTapGesture = UITapGestureRecognizer(target: self, action: #selector(logoutButtonTapped))
        logoutContainerView.addGestureRecognizer(logoutTapGesture)
        logoutContainerView.isUserInteractionEnabled = true
        
        let favoriteCategoriesTapGesture = UITapGestureRecognizer(target: self, action: #selector(favoriteCategoriesTapped))
        favoriteCategoriesOptionView.addGestureRecognizer(favoriteCategoriesTapGesture)
        favoriteCategoriesOptionView.isUserInteractionEnabled = true
    }
    
    @objc private func bookmarkOptionTapped() {
        coordinator?.navigateToBookmarks()
    }
    
    @objc private func readOfflineOptionTapped() {
        coordinator?.navigateToReadOffline()
    }
    
    @objc private func deleteAccountOptionTapped() {
        print("DEBUG_DELETE_ACCOUNT: deleteAccountOptionTapped method called")
        if let coordinator = coordinator {
            print("DEBUG_DELETE_ACCOUNT: coordinator exists, calling showDeleteAccountConfirmation")
            coordinator.showDeleteAccountConfirmation()
        } else {
            print("DEBUG_DELETE_ACCOUNT: ERROR - coordinator is nil")
        }
    }
    
    @objc private func logoutButtonTapped() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    @objc private func favoriteCategoriesTapped() {
        print("DEBUG - ProfileViewController: Favorite categories tapped")
        coordinator?.showEditFavoriteCategories()
    }
    
    private func performLogout() {
        viewModel.logout()
    }
}
