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
    
    // MARK: - Properties
    private let viewModel: DiscoveryViewModel
    
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
    
    // MARK: - Initialization
    init(viewModel: DiscoveryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStyle()
        setupConstraints()
        setupBindings()
        
        ThemeManager.shared.addThemeChangeObserver(self, selector: #selector(themeChanged))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    deinit {
        ThemeManager.shared.removeThemeChangeObserver(self)
    }
    
    @objc private func themeChanged() {
        updateThemeBasedUI()
    }
    
    private func updateThemeBasedUI() {
        view.backgroundColor = .themeBackgroundColor()
        contentView.backgroundColor = .themeBackgroundColor()
        mainTitleLabel.textColor = ThemeManager.shared.currentTheme.isLight ? .black : .white
        collectionView.reloadData()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        viewModel.onCategoriesUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        viewModel.onErrorOccurred = { [weak self] errorMessage in
            DispatchQueue.main.async {
                print("Error: \(errorMessage)")
            }
        }
    }
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
        view.backgroundColor = .themeBackgroundColor()
        
        mainTitleLabel.text = "Discovery"
        mainTitleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        mainTitleLabel.textColor = .white
        mainTitleLabel.textAlignment = .center
        
        contentView.backgroundColor = .themeBackgroundColor()
        
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(DiscoveryCell.self, forCellWithReuseIdentifier: "DiscoveryCell")
        
        searchBar.barTintColor = .hexDarkGrey
        searchBar.isTranslucent = false
        searchBar.backgroundColor = .clear
        searchBar.searchTextField.backgroundColor = .clear
        searchBar.searchTextField.textColor = UIColor(named: "hex_BackGround")
        searchBar.layer.cornerRadius = 16
        searchBar.clipsToBounds = true
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        
        updateThemeBasedUI()
    }
}

// MARK: - CollectionView Delegate, Datasource
extension DiscoveryViewController: UICollectionViewDelegate, UICollectionViewDataSource,
                                   UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfCategories()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "DiscoveryCell", for: indexPath)
                as? DiscoveryCell,
              let category = viewModel.category(at: indexPath.item) else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: category.displayName.uppercased(), image: category.image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectCategory(at: indexPath.item)
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
        viewModel.filterCategories(with: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        viewModel.resetFilter()
        searchBar.resignFirstResponder()
    }
}
