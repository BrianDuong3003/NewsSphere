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
    
    private lazy var mainTitleLB = UILabel()
    private lazy var contentview = UIView()
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
        config()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func config() {
        setupViews()
        setupConstraints()
        styleViews()
    }
}

// MARK: - Fetch Data
extension DiscoveryViewController {
    
}

extension DiscoveryViewController {
    func setupViews() {
        view.subviews {
            mainTitleLB
            contentview
        }
        
        contentview.subviews {
            searchBar
            collectionView
        }
    }
    
    func setupConstraints() {
        mainTitleLB
            .top(60)
            .centerHorizontally()
        
        contentview
            .top(105)
            .left(0)
            .right(0)
            .bottom(0)
        
        searchBar
            .top(30)
            .left(15)
            .right(16)
            .height(60)
            .centerHorizontally()
        
        collectionView
            .left(12)
            .right(12)
            .bottom(0)
            .height(>=200)
            .Top == searchBar.Bottom + 21
    }
    
    func styleViews() {
        view.backgroundColor = UIColor.C_01_D_2_E
        
        mainTitleLB.style {
            $0.text = "Discovery"
            $0.font = .systemFont(ofSize: 24, weight: .bold)
            $0.textColor = .white
            $0.textAlignment = .center
        }
        
        contentview.style {
            $0.backgroundColor = UIColor._1_B_1_B_1_B
        }
        
        searchBar.style {
            $0.barTintColor = ._1_B_1_B_1_B
            $0.isTranslucent = false
            $0.backgroundColor = .clear
            $0.searchTextField.backgroundColor = .clear
            $0.searchTextField.leftView?.tintColor = .B_9_B_9_B_6
            $0.searchTextField.textColor = .B_9_B_9_B_6
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.B_9_B_9_B_6.cgColor
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
            $0.placeholder = "Search"
            $0.delegate = self
        }
        
        collectionView.style {
            $0.backgroundColor = .clear
            $0.delegate = self
            $0.dataSource = self
            $0.showsVerticalScrollIndicator = false
            $0.register(DiscoveryCell.self, forCellWithReuseIdentifier: "DiscoveryCell")
        }
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
        let categoryArticlesVC = CategoryArticlesViewController(category: selectedCategory.rawValue)
        navigationController?.pushViewController(categoryArticlesVC, animated: true)
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
