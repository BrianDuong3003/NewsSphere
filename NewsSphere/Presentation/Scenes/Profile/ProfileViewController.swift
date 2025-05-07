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
    var coordinator: ProfileCoordinator?
    
    private let profileScrollView = UIScrollView()
    private let contentView = UIView()
    
    private let avatarImageView = UIImageView()
    private let avatarEditButton = UIButton(type: .system)
    
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    
    private let settingsTableView = UITableView(frame: .zero, style: .grouped)
    
    private let firestoreManager = FirestoreUserManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .hexBackGround
        title = "Profile"
        
        setupUI()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserProfile()
    }
    
    private func setupUI() {
        view.subviews {
            profileScrollView
        }
        
        profileScrollView.subviews {
            contentView
        }
        
        contentView.subviews {
            avatarImageView
            avatarEditButton
            nameLabel
            emailLabel
        }
        
        avatarImageView.backgroundColor = .lightGray
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.image = UIImage(named: "default_avatar")
        
        avatarEditButton.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        avatarEditButton.tintColor = .white
        avatarEditButton.backgroundColor = .red
        avatarEditButton.layer.cornerRadius = 15
        avatarEditButton.clipsToBounds = true
        
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        
        emailLabel.font = .systemFont(ofSize: 16, weight: .regular)
        emailLabel.textColor = .hexGrey
        emailLabel.textAlignment = .center
    }
    
    private func setupConstraints() {
        profileScrollView.fillContainer()
        
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
        
        avatarEditButton.width(30).height(30)
        avatarEditButton.right(0).bottom(0)
        avatarEditButton.CenterX == avatarImageView.Trailing + 5
        avatarEditButton.CenterY == avatarImageView.Bottom
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }
    
    private func fetchUserProfile() {
        guard let currentUser = Auth.auth().currentUser else {
            nameLabel.text = "Not signed in"
            emailLabel.text = "Please sign in to continue"
            return
        }
        
        let uid = currentUser.uid
        
        emailLabel.text = currentUser.email
    
        firestoreManager.getUserByUID(uid: uid) { [weak self] userData, error in
            guard let self = self else { return }
            
            if let error = error {
                print("DEBUG - ProfileViewController: Error fetching user profile: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.nameLabel.text = "Error loading profile"
                }
                return
            }
            
            if let userData = userData {
                let firstName = userData["firstName"] as? String ?? ""
                let lastName = userData["lastName"] as? String ?? ""
                
                DispatchQueue.main.async {
                    self.nameLabel.text = "\(firstName) \(lastName)"
                }
            } else {
                print("DEBUG - ProfileViewController: No user profile data found")
                DispatchQueue.main.async {
                    self.nameLabel.text = "Profile not found"
                }
            }
        }
    }
}
