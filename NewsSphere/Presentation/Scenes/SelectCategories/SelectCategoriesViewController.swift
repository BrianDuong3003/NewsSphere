//
//  SelectCategoriesViewController.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import UIKit
import Stevia

class SelectCategoriesViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select favorite categories"
        label.textColor = .white
        label.font = .systemFont(ofSize: 25, weight: .bold)
        return label
    }()
    
    private let descLabel: UILabel = {
        let label = UILabel()
        label.text = "These categories will be used to personalized news for you"
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 100, height: 40) // Add estimated size
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.isScrollEnabled = false
        collection.register(TagCell.self, forCellWithReuseIdentifier: "TagCell")
        collection.delegate = self
        collection.dataSource = self
        collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return collection
    }()
    
    private let loginRegisterButotnDescLabel: UILabel = {
        let label = UILabel()
        label.text = "You need to login to use this feature"
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let navigateLoginRegisterButton: GradientButton = {
        let button = GradientButton(type: .system)
        
        if let startColor = UIColor(named: "hex_C78055"),
           let endColor = UIColor(named: "hex_A8273E") {
            button.setGradientColors(startColor: startColor,
                                     endColor: endColor)
        }
        
        button.setGradientDirection(startPoint: CGPoint(x: 0, y: 0),
                                    endPoint: CGPoint(x: 1, y: 0))
        
        button.setTitle("Login or Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        
        return button
    }()
    
    let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor(named: "hex_90_C3C3E5")
        button.layer.cornerRadius = 8
        return button
    }()
    
    private var collectionViewHeightConstraint: NSLayoutConstraint?
    
    private var tags: [String] =
    ["Business", "Health", "General", "Sports", "Entertainment", "Science", "Technology"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .black
        
        view.subviews(
            scrollView.subviews(
                contentView
            )
        )
        
        scrollView.fillContainer(padding: 0)
        contentView.width(UIScreen.main.bounds.width)
        
        contentView.subviews(
            titleLabel,
            descLabel,
            collectionView,
            loginRegisterButotnDescLabel,
            navigateLoginRegisterButton,
            skipButton
        )
        
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
