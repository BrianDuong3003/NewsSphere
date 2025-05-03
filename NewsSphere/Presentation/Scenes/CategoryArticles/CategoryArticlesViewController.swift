//
//  CategoryArticlesViewController.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 7/4/25.
//

import UIKit
import Stevia

class CategoryArticlesViewController: UIViewController {
    
    private lazy var mainTitleLabel = UILabel()
    private lazy var contentView = UIView()
    private lazy var backButton = UIButton()
    private lazy var topView = UIView() // Thêm topView giống ReadOfflineViewController
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    weak var coordinator: CategoryArticlesCoordinator?
    private var viewModel: CategoryArticlesViewModel!
    private var articles: [Article] = []
    
    init(category: String) {
        // Initialize ViewModel later in viewDidLoad after coordinator is set
        super.init(nibName: nil, bundle: nil)
        self.viewModel = CategoryArticlesViewModel(category: category, coordinator: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupStyle()
        fetchArticles()
    }
    
    @objc private func backButtonTapped() {
        coordinator?.navigateBack()
    }
}

// MARK: - Fetch Data
extension CategoryArticlesViewController {
    private func fetchArticles() {
        // Hiển thị loading state nếu cần
        viewModel.fetchArticles { [weak self] articles in
            self?.articles = articles
            self?.collectionView.reloadData()
            
            // Kiểm tra và hiển thị trạng thái khi không có bài viết
            if articles.isEmpty {
                self?.showEmptyState()
            } else {
                self?.hideEmptyState()
            }
        }
    }
    
    private func showEmptyState() {
        // Có thể hiển thị message hoặc view trống tùy thuộc vào UI của app
        print("No articles found for this category")
    }
    
    private func hideEmptyState() {
        // Ẩn message hoặc view trống nếu cần
    }
}

extension CategoryArticlesViewController {
    private func setupView() {
        view.subviews {
            topView.subviews {
                backButton
                mainTitleLabel
            }
            contentView.subviews {
                collectionView
            }
        }
        
        // Add target cho backButton
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        // Top view
        topView.top(0).left(0).right(0)
        topView.Height == view.Height * 0.15
        
        // Title
        mainTitleLabel.centerHorizontally().CenterY == backButton.CenterY

        // Back button - vị trí giống như trong read offline
        backButton.Leading == view.Leading + 20
        backButton.Bottom == topView.Bottom - 15
        backButton.width(30).height(30)
        
        // Content view
        contentView.Top == topView.Bottom
        contentView.left(0).right(0).bottom(0)
        
        // Collection view
        collectionView.left(12).right(12).bottom(0).top(10)
    }
    
    private func setupStyle() {
        
        view.backgroundColor = .hexBackGround
        topView.backgroundColor = .hexRed
        
        mainTitleLabel.text =
        NewsCategoryType(rawValue: viewModel.category)?.displayName ?? viewModel.category.uppercased()
        mainTitleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        mainTitleLabel.textColor = .white
        mainTitleLabel.textAlignment = .center
        
        // Style cho backButton - giống như ReadOfflineViewController
        backButton.setImage(UIImage(named: "ic_back_button"), for: .normal)
        backButton.tintColor = .white
        
        contentView.backgroundColor = .hexBackGround
        
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(CategoryArticlesCell.self, forCellWithReuseIdentifier: "CategoryArticlesCell")
    }
}

// MARK: - CollectionView Delegate, Datasource
extension CategoryArticlesViewController: UICollectionViewDelegate, UICollectionViewDataSource,
                                          UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CategoryArticlesCell", for: indexPath)
                as? CategoryArticlesCell else {
            return UICollectionViewCell()
        }
        let article = articles[indexPath.item]
        cell.configure(with: article)
        return cell
    }
    
    // Thêm xử lý khi người dùng bấm vào cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedArticle = articles[indexPath.item]
        coordinator?.showArticleDetail(selectedArticle)
    }
    
    func collectionView(_ collectiornView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: 300)
    }
}

// Mở rộng CategoryArticlesViewController để tuân thủ CategoryArticlesCoordinatorProtocol
extension CategoryArticlesViewController: CategoryArticlesCoordinatorProtocol {
    func navigateBack() {
        coordinator?.navigateBack()
    }
    
    func showArticleDetail(_ article: Article) {
        coordinator?.showArticleDetail(article)
    }
}
