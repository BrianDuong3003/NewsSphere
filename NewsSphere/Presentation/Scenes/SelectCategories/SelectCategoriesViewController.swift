//
//  SelectCategoriesViewController.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import UIKit
import Stevia

class SelectCategoriesViewController: UIViewController {
    
    private lazy var scrollView = UIScrollView()
    private let contentView = UIView()
    private lazy var titleLabel = UILabel()
    private lazy var descLabel = UILabel()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 100, height: 40)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collection
    }()
    private lazy var loginRegisterButotnDescLabel = UILabel()
    private lazy var navigateLoginRegisterButton = GradientButton(type: .system)
    private lazy var skipButton = UIButton(type: .system)
    
    private var collectionViewHeightConstraint: NSLayoutConstraint?
    
    private var tags: [String] =
    ["Business", "Health", "General", "Sports", "Entertainment", "Science", "Technology"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStyle()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
        updateCollectionViewHeight()
    }
    
    private func updateCollectionViewHeight() {
        collectionView.layoutIfNeeded()
        let contentHeight = collectionView.contentSize.height
        collectionViewHeightConstraint?.constant = contentHeight
    }
    
    private func setupView() {
        view.subviews {
            scrollView.subviews {
                contentView.subviews {
                    titleLabel
                    descLabel
                    collectionView
                    loginRegisterButotnDescLabel
                    navigateLoginRegisterButton
                    skipButton
                }
            }
        }
    }
    
    private func setupStyle() {
        view.backgroundColor = .black
        
        scrollView.showsVerticalScrollIndicator = false
        
        titleLabel.text = "Select favorite categories"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 25, weight: .bold)
        
        descLabel.text = "These categories will be used to personalized news for you"
        descLabel.textColor = .white
        descLabel.font = .systemFont(ofSize: 14, weight: .medium)
        descLabel.numberOfLines = 0
        descLabel.lineBreakMode = .byWordWrapping
        
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.register(TagCell.self, forCellWithReuseIdentifier: "TagCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        loginRegisterButotnDescLabel.text = "You need to login to use this feature"
        loginRegisterButotnDescLabel.textColor = .white
        loginRegisterButotnDescLabel.font = .systemFont(ofSize: 18, weight: .bold)
        loginRegisterButotnDescLabel.numberOfLines = 0
        loginRegisterButotnDescLabel.lineBreakMode = .byWordWrapping
        
        if let startColor = UIColor(named: "hex_C78055"),
           let endColor = UIColor(named: "hex_A8273E") {
            navigateLoginRegisterButton.setGradientColors(startColor: startColor,
                                   endColor: endColor)
        }
        
        navigateLoginRegisterButton.setGradientDirection(startPoint: CGPoint(x: 0, y: 0),
                                  endPoint: CGPoint(x: 1, y: 0))
        
        navigateLoginRegisterButton.setTitle("Login or Register", for: .normal)
        navigateLoginRegisterButton.setTitleColor(.white, for: .normal)
        navigateLoginRegisterButton.titleLabel?.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        navigateLoginRegisterButton.layer.cornerRadius = 8
        navigateLoginRegisterButton.clipsToBounds = true
        
        skipButton.setTitle("Skip", for: .normal)
        skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        skipButton.setTitleColor(.black, for: .normal)
        skipButton.backgroundColor = .hexGrWhite
        skipButton.layer.cornerRadius = 8
    }
    
    private func setupConstraints() {
        scrollView.fillContainer(padding: 0)
        contentView.width(UIScreen.main.bounds.width)
        
        contentView.layout(
            26,
            |-18-titleLabel-18-|,
            11,
            |-18-descLabel-18-|,
            21,
            |-18-collectionView-18-|,
            79,
            |-18-loginRegisterButotnDescLabel-18-|,
            10,
            |-18-navigateLoginRegisterButton-18-|,
            18,
            |-16-skipButton-16-|,
            16
        )
        
        navigateLoginRegisterButton.height(48)
        skipButton.height(48)
        
        scrollView.Top == view.safeAreaLayoutGuide.Top
        scrollView.Bottom == view.safeAreaLayoutGuide.Bottom
        
        contentView.Top == scrollView.Top
        contentView.Bottom == scrollView.Bottom
        
        collectionViewHeightConstraint = collectionView.heightAnchor
            .constraint(equalToConstant: 200)
        collectionViewHeightConstraint?.isActive = true
    }
}

extension SelectCategoriesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell",
                                                      for: indexPath) as? TagCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: tags[indexPath.item])
        return cell
    }
}

extension SelectCategoriesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tag = tags[indexPath.item]
        let width = tag.size(withAttributes: [.font: UIFont.systemFont(ofSize: 14)]).width + 40
        return CGSize(width: width, height: 36)
    }
}
