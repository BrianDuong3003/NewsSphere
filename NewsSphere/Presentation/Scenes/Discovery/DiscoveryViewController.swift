//
//  DiscoveryViewController.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//
import Foundation
import UIKit
import Stevia

class DiscoveryViewController: UIViewController {
    
    private lazy var viewModel = DiscoveryViewModel()
    
    private lazy var mainTitleLabel = UILabel()
    private lazy var contentView = UIView()
    private lazy var searchBar = UISearchBar()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    var coordinator: DiscoveryCoordinator?
    private let categoryRepository = CategoryRepository()
    private var categories: [NewsCategoryType] = NewsCategoryType.allCases
    private var filterCategories: [NewsCategoryType] = NewsCategoryType.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStyle()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

// MARK: - Fetch Data
extension DiscoveryViewController {
    
}

extension DiscoveryViewController {
    private func setupView() {
        view.subviews {
            mainTitleLabel
            contentView.subviews {
                searchBar
                collectionView
            }
        }
    }
    
    private func setupConstraints() {
        mainTitleLabel
            .top(60)
            .centerHorizontally()
        
        contentView
            .top(105)
            .left(0)
            .right(0)
            .bottom(0)
        
        searchBar
            .top(30)
            .left(15)
            .right(16).height(60).centerHorizontally()
        
        collectionView
            .left(12)
            .right(12)
            .bottom(0)
            .height(>=200)
            .Top == searchBar.Bottom + 21
    }
    
    private func setupStyle() {
        view.backgroundColor = .hexBackGround
        
        mainTitleLabel.text = "Discovery"
        mainTitleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        mainTitleLabel.textColor = .white
        mainTitleLabel.textAlignment = .center
        
        contentView.backgroundColor = .hexBackGround
        
        searchBar.barTintColor = .hexDarkGrey
        searchBar.isTranslucent = false
        searchBar.backgroundColor = .clear
        searchBar.searchTextField.backgroundColor = .clear
        searchBar.searchTextField.leftView?.tintColor = .hexBackGround
        searchBar.searchTextField.textColor = .hexBackGround
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.hexGrey.cgColor
        searchBar.layer.cornerRadius = 16
        searchBar.clipsToBounds = true
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(DiscoveryCell.self, forCellWithReuseIdentifier: "DiscoveryCell")
    }
}

// MARK: - CollectionView Deledate, Datasource
extension DiscoveryViewController: UICollectionViewDelegate, UICollectionViewDataSource,
                                   UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(categories.count)
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "DiscoveryCell", for: indexPath)
                as? DiscoveryCell else {
            return UICollectionViewCell()
        }
        let category = categories[indexPath.item]
        cell.configure(with: category.displayName.uppercased(), image: category.image)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCategory = categories[indexPath.item]
        coordinator?.showArticles(for: selectedCategory.rawValue)
    }
    
    func collectionView(_ collectiornView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 15) / 2
        return CGSize(width: width, height: width * 1.2)
    }
}

extension DiscoveryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            categories = filterCategories
            collectionView.reloadData()
            return
        }
        
        if searchText == "" {
            categories = filterCategories
            collectionView.reloadData()
        }
        
        categories = filterCategories.filter({ category in
            category.displayName.lowercased().contains(searchText.lowercased())
        })
        
        collectionView.reloadData()
    }
}
