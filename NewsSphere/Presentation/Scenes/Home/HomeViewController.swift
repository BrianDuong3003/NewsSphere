//
//  HomeViewController.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//
import UIKit
import Stevia

class HomeViewController: UIViewController {
    private lazy var logo = UIImageView()
    private lazy var appLabel = UIButton()
    private lazy var downloadButton = UIButton()
    private lazy var searchButton = UIButton()
    private lazy var listButton = UIButton()
    private lazy var topView = UIView()
    private lazy var topBar = TopBarView()
    private lazy var verticalCollectionView: UICollectionView = createCollectionView(
        scrollDirection: .vertical,
        cellType: VerticalViewCell.self,
        cellIdentifier: "VerticalViewCell")
    
    private let viewModel: HomeViewModel
    var coordinator: HomeCoordinator?
    private lazy var bookmarkRepository: BookmarkRepositoryProtocol = {
        return BookmarkRepository()
    }()
    
    init(viewModel: HomeViewModel) {
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
        setupCollectionViewDelegates()
        topBar.delegate = self
        bindViewModel()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // Update category list and 2light current category
        topBar.refreshCategories()
        
        // 2light current category
        let currentCategory = viewModel.getCurrentCategory()
        if !currentCategory.isEmpty {
            topBar.selectCategory(currentCategory)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension HomeViewController {
    private func setupView() {
        view.subviews {
            topView.subviews {
                logo
                searchButton
                downloadButton
                appLabel
            }
            topBar
            listButton
            verticalCollectionView
        }
    }
    
    private func setupStyle() {
        view.backgroundColor = UIColor.hexBackGround
        
        logo.image = UIImage(named: "Logo")
        
        appLabel.setTitle("NewsSphere", for: .normal)
        appLabel.setGradientText(startColor: .hexDarkRed, endColor: .hexBrown)
        if let titleLabel = appLabel.titleLabel {
            titleLabel.font = UIFont.systemFont(ofSize: 21, weight: .heavy)
        }
        appLabel.contentHorizontalAlignment = .center
        appLabel.semanticContentAttribute = .forceRightToLeft
        
        downloadButton.setImage(UIImage(named: "vtdl"), for: .normal)
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchButton.tintColor = .lightGray
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        
        listButton.setImage(UIImage(named: "list"), for: .normal)
    }
    
    private func setupConstraints() {
        topView.Top == view.safeAreaLayoutGuide.Top
        
        topView.layout {
            |-logo - <=30-appLabel - <=22-downloadButton - <=12-searchButton-|
        }
        
        view.layout {
            |-20-topView.height(55)-35-|
            -8
            |-27-topBar.height(35).width(<=330)-listButton.width(20)-27-|
            12
            |-15-verticalCollectionView-15-|
            20
        }
        
        logo.height(56).width(56)
    }
    
    @objc private func searchButtonTapped() {
        print("Search button tapped")
        navigationController?.setNavigationBarHidden(false, animated: true)
        coordinator?.showSearchScreen()
    }
    
    @objc private func downloadButtonTapped() {
        print("Download button tapped")
        navigationController?.setNavigationBarHidden(false, animated: true)
        coordinator?.showReadOfflineScreen()
    }
    
    private func setupCollectionViewDelegates() {
        verticalCollectionView.delegate = self
        verticalCollectionView.dataSource = self
    }
    
    private func createCollectionView<T: UICollectionViewCell>(scrollDirection: UICollectionView.ScrollDirection, cellType: T.Type, cellIdentifier: String) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = scrollDirection
        layout.minimumLineSpacing = 16
        layout.sectionInset = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = (scrollDirection == .horizontal)
        collectionView.showsHorizontalScrollIndicator = (scrollDirection == .vertical)
        collectionView.register(cellType, forCellWithReuseIdentifier: cellIdentifier)
        return collectionView
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfVerticalArticles()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VerticalViewCell",
                                                      for: indexPath) as? VerticalViewCell else {
            return UICollectionViewCell()
        }
        if let article = viewModel.verticalArticle(at: indexPath.row) {
            cell.configure(articles: article)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section: ArticleSection = .vertical
        viewModel.selectArticle(from: section, at: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 300)
    }
}

extension HomeViewController: TopBarViewDelegate {
    func topBarView(_ view: TopBarView, didSelectCategory category: String) {
        viewModel.fetchArticles(category: category)
    }
}

extension HomeViewController {
    func bindViewModel() {
        viewModel.onArticlesUpdated = { [weak self] in
            guard let self = self else { return }
            self.verticalCollectionView.reloadData()
            
            // 2light current category
            let currentCategory = self.viewModel.getCurrentCategory()
            if !currentCategory.isEmpty {
                self.topBar.selectCategory(currentCategory)
            }
        }
        
        // Handle errors from ViewModel
        viewModel.onError = { [weak self] errorMessage in
            guard let self = self else { return }
            self.showErrorAlert(message: errorMessage)
        }
        
        viewModel.delegate = self
        // Tải nội dung phù hợp dựa trên trạng thái xác thực của người dùng
        viewModel.loadContent()
    }
}

extension HomeViewController: HomeViewModelDelegate {
    func didSelectArticle(_ article: Article, originalCategory: String?) {
        if let coordinator = coordinator {
            let selectedCategory = originalCategory ?? viewModel.getCurrentCategory()
            coordinator.showArticleDetail(article, selectedCategory: selectedCategory)
        } else {
            print("Coordinator is nil")
        }
    }
}
