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
    private let firestoreManager = FirestoreUserManager.shared

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
    
    // Logout
    private let logoutButton = UIButton(type: .system)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStyle()
        setupConstraints()
        setupActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserProfile()
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
            logoutButton
        }

        optionsStackView.addArrangedSubview(bookmarkOptionView)
        optionsStackView.addArrangedSubview(readOfflineOptionView)

        bookmarkOptionView.subviews {
            bookmarkLabel
            bookmarkIconView
        }

        readOfflineOptionView.subviews {
            readOfflineLabel
            readOfflineIconView
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
        
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.hexRed, for: .normal)
        logoutButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        logoutButton.backgroundColor = .hexBackGround
        logoutButton.layer.cornerRadius = 12
        logoutButton.layer.borderWidth = 0.3
        logoutButton.layer.borderColor = UIColor.systemRed.cgColor
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
            optionsStackView.height(120)
    
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
            
            logoutButton.Top == optionsStackView.Bottom + 40
            logoutButton.centerHorizontally()
            logoutButton.width(170).height(50)
        }

    // MARK: - Actions
    private func setupActions() {
        let bookmarkTapGesture = UITapGestureRecognizer(target: self, action: #selector(bookmarkOptionTapped))
        bookmarkOptionView.addGestureRecognizer(bookmarkTapGesture)
        bookmarkOptionView.isUserInteractionEnabled = true

        let readOfflineTapGesture = UITapGestureRecognizer(target: self, action: #selector(readOfflineOptionTapped))
        readOfflineOptionView.addGestureRecognizer(readOfflineTapGesture)
        readOfflineOptionView.isUserInteractionEnabled = true
        
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
    }

    @objc private func bookmarkOptionTapped() {
        coordinator?.navigateToBookmarks()
    }

    @objc private func readOfflineOptionTapped() {
        coordinator?.navigateToReadOffline()
    }
    
    @objc private func logoutButtonTapped() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        do {
            try Auth.auth().signOut()
            
            UserSessionManager.shared.userDidLogout()
            
            // Reset user defaults
            UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
            
            coordinator?.didLogout()
            
        } catch {
            print("ERROR - ProfileViewController: Failed to sign out: \(error.localizedDescription)")
            
            let alert = UIAlertController(title: "Error", 
                                         message: "Failed to logout. Please try again.", 
                                         preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    // MARK: - Data Fetching
    private func fetchUserProfile() {
        guard let currentUser = Auth.auth().currentUser else {
            DispatchQueue.main.async {
                self.nameLabel.text = "Not signed in"
                self.emailLabel.text = "Please sign in to continue"
                self.avatarImageView.image = UIImage(named: "default")
            }
            return
        }

        let uid = currentUser.uid
        DispatchQueue.main.async {
            self.emailLabel.text = currentUser.email
        }

        firestoreManager.getUserByUID(uid: uid) { [weak self] userData, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if let error = error {
                    print("DEBUG - ProfileViewController: Error fetching user profile: \(error.localizedDescription)")
                    self.nameLabel.text = "Error loading profile"
                    return
                }

                if let userData = userData {
                    let firstName = userData["firstName"] as? String ?? ""
                    let lastName = userData["lastName"] as? String ?? ""
                    self.nameLabel.text = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
                } else {
                    print("DEBUG - ProfileViewController: No user profile data found in Firestore for UID: \(uid)")
                    self.nameLabel.text = "Profile Incomplete"
                }
            }
        }
    }
}
