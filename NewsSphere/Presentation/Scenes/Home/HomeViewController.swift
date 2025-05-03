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
    private lazy var locationButton = UIButton()
    private lazy var downloadButton = UIButton()
    private lazy var searchButton = UIButton()
    private lazy var listButton = UIButton()
    private lazy var topView = UIView()
    private lazy var topBar = TopBarView()
    private lazy var headlineLabel = UILabel()
    private lazy var verticalCollectionView: UICollectionView = createCollectionView(
        scrollDirection: .vertical,
        cellType: VerticalViewCell.self,
        cellIdentifier: "VerticalViewCell")
    
    private lazy var horizontalCollectionView: UICollectionView = createCollectionView(
        scrollDirection: .horizontal,
        cellType: HorizontalViewCell.self,
        cellIdentifier: "HorizontalViewCell")
    
    private lazy var viewModel: HomeViewModel = {
        let repository: ArticleRepositoryProtocol = ArticleRepository()
        return HomeViewModel(articleRepository: repository)
    }()
    
    var coordinator: HomeCoordinator?
    private lazy var bookmarkRepository: BookmarkRepositoryProtocol = {
        return BookmarkRepository()
    }()
    
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
                locationButton
            }
            topBar
            listButton
            headlineLabel
            horizontalCollectionView
            verticalCollectionView
        }
    }
    
    private func setupStyle() {
        view.backgroundColor = UIColor.hexBackGround
        
        headlineLabel.text = "Headlines"
        headlineLabel.font = .systemFont(ofSize: 24, weight: .bold)
        headlineLabel.textAlignment = .left
        headlineLabel.textColor = .white
        
        logo.image = UIImage(named: "Logo")
        
        locationButton.setTitle("New York City", for: .normal)
        locationButton.setGradientText(startColor: .hexDarkRed, endColor: .hexBrown)
        if let titleLabel = locationButton.titleLabel {
            titleLabel.font = UIFont.systemFont(ofSize: 21, weight: .heavy)
        }
        locationButton.setImage(UIImage(named: "Vector 5"), for: .normal)
        locationButton.contentHorizontalAlignment = .center
        locationButton.semanticContentAttribute = .forceRightToLeft
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        
        downloadButton.setImage(UIImage(named: "vtdl"), for: .normal)
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchButton.tintColor = .lightGray
        
        listButton.setImage(UIImage(named: "list"), for: .normal)
    }
    
    private func setupConstraints() {
//        topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        topView.Top == view.safeAreaLayoutGuide.Top
        
        topView.layout {
            |-logo - <=30-locationButton - <=22-downloadButton - <=12-searchButton-|
        }
        
        view.layout {
            |-20-topView.height(55)-35-|
            -8
            |-27-topBar.height(35).width(<=330)-listButton.width(20)-27-|
            12
            |-15-headlineLabel.height(27)-|
            20
            |-15-horizontalCollectionView.height(175)-|
            10
            |-15-verticalCollectionView-15-|
            20
        }
        
        logo.height(56).width(56)
    }
    
    @objc private func locationButtonTapped() {
        print("Location button tapped")
        navigationController?.setNavigationBarHidden(false, animated: true)
        coordinator?.showLocationScreen()
    }
    
    @objc private func downloadButtonTapped() {
        print("Download button tapped")
        navigationController?.setNavigationBarHidden(false, animated: true)
        coordinator?.showReadOfflineScreen()
    }
    
    private func setupCollectionViewDelegates() {
        verticalCollectionView.delegate = self
        verticalCollectionView.dataSource = self
        horizontalCollectionView.delegate = self
        horizontalCollectionView.dataSource = self
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
        return collectionView == verticalCollectionView ?
        viewModel.numberOfVerticalArticles() : viewModel.numberOfHorizontalArticles()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == verticalCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VerticalViewCell",
                                                          for: indexPath) as? VerticalViewCell else {
                return UICollectionViewCell()
            }
            if let article = viewModel.verticalArticle(at: indexPath.row) {
                cell.configure(articles: article)
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalViewCell",
                                                          for: indexPath) as? HorizontalViewCell else {
                return UICollectionViewCell()
            }
            if let article = viewModel.horizontalArticle(at: indexPath.row) {
                cell.configure(articles: article)
            }
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section: ArticleSection = (collectionView == verticalCollectionView)
        ? .vertical : .horizontal
        viewModel.selectArticle(from: section, at: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == verticalCollectionView {
            return CGSize(width: collectionView.frame.width, height: 300)
        } else {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
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
            self.horizontalCollectionView.reloadData()
        }
        
        // Handle errors from ViewModel
        viewModel.onErrorOccurred = { [weak self] errorMessage in
            guard let self = self else { return }
            self.showErrorAlert(message: errorMessage)
        }
        
        viewModel.delegate = self
        // default (test)
        viewModel.fetchArticles(category: "business")
    }
}

extension HomeViewController: HomeViewModelDelegate {
    func didSelectArticle(_ article: Article) {
        if let coordinator = coordinator {
            let selectedCategory = viewModel.getCurrentCategory()
            coordinator.showArticleDetail(article, selectedCategory: selectedCategory)
        } else {
            print("Coordinator is nil, using fallback navigation.")
        }
    }
}
