//
//  HomeViewController.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//
import UIKit
import Stevia

class HomeViewController: UIViewController {
    private lazy var img = UIImageView()
    private lazy var btnLocation = UIButton()
    private lazy var btnDownload = UIButton()
    private lazy var btnSearch = UIButton()
    private lazy var btnList = UIButton()
    private lazy var topView = UIView()
    private lazy var topBar = TopBarView()
    private lazy var headLabel = UILabel()
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
        setupViews()
        styleViews()
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
    private func setupViews() {
        view.subviews {
            topView
            topBar
            btnList
            headLabel
            horizontalCollectionView
            verticalCollectionView
        }
        
        topView.subviews {
            img
            btnSearch
            btnDownload
            btnLocation
        }
    }
    
    private func styleViews() {
//        view.backgroundColor = UIColor.hexBackGround
        view.backgroundColor = UIColor.hexBackGround
        
        headLabel.style {
            $0.text = "Headlines"
            $0.font = .systemFont(ofSize: 24, weight: .bold)
            $0.textAlignment = .left
            $0.textColor = .white
        }
        img.style {
            $0.image = UIImage(named: "Logo")
        }
        btnLocation.style {
            $0.setTitle("New York City", for: .normal)
            $0.setGradientText(startColor: .hexDarkRed, endColor: .hexBrown)
            if let titleLabel = $0.titleLabel {
                titleLabel.font = UIFont.systemFont(ofSize: 21, weight: .heavy)
            }
            $0.setImage(UIImage(named: "Vector 5"), for: .normal)
            
            $0.contentHorizontalAlignment = .center
            $0.semanticContentAttribute = .forceRightToLeft
            $0.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        }
        btnDownload.style {
            $0.setImage(UIImage(named: "vtdl"), for: .normal)
            $0.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        }
        btnSearch.style {
            $0.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            $0.tintColor = .lightGray
        }
        btnList.style {
            $0.setImage(UIImage(named: "list"), for: .normal)
        }
    }
    
    private func setupConstraints() {
        topView
            .topAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)
            .isActive = true
        
        topView.layout {
            |-img - <=30-btnLocation - <=22-btnDownload - <=12-btnSearch-|
        }
        
        view.layout {
            |-20-topView.height(55)-35-|
            -8
            |-27-topBar.height(35).width(<=330)-btnList.width(20)-27-|
            12
            |-15-headLabel.height(27)-|
            20
            |-15-horizontalCollectionView.height(175)-|
            10
            |-15-verticalCollectionView-15-|
            20
        }
        
        img.height(56).width(56)
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
            guard let navigationController = self.navigationController else {
                print("Error: NavigationController is nil in fallback.")
                return
            }
            
            let repository: ArticleRepositoryProtocol = ArticleRepository()
            let bookmarkRepository: BookmarkRepositoryProtocol = BookmarkRepository()
            let detailCoordinator = ArticleDetailCoordinator(navigationController:
                                                                navigationController,
                                                             article: article,
                                                             repository: repository,
                                                             bookmarkRepository: bookmarkRepository)
            let selectedCategory = viewModel.getCurrentCategory()
            let detailViewModel = ArticleDetailViewModel(repository: repository,
                                                         bookmarkRepository: bookmarkRepository,
                                                         coordinator: detailCoordinator,
                                                         article: article)
            detailViewModel.selectedCategory = selectedCategory
            let detailViewController = ArticleDetailViewController()
            detailViewController.viewModel = detailViewModel
            navigationController.pushViewController(detailViewController, animated: true)
        }
    }
}
