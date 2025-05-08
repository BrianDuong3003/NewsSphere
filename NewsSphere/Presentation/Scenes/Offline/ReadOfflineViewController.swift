//
//  ReadOfflineViewController.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 14/3/25.
//

import UIKit
import Stevia

class ReadOfflineViewController: UIViewController {
    private lazy var topView = UIView()
    private lazy var backButton = UIButton()
    private lazy var reloadButton = UIButton()
    private lazy var deleteButton = UIButton()
    private lazy var titleLabel = UILabel()
    private lazy var articlesTableView = UITableView()
    private lazy var loadingIndicator = UIActivityIndicatorView(style: .medium)
    private lazy var emptyStateLabel = UILabel()
    
    var coordinator: ArticleNavigator?
    var viewModel: ReadOfflineViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupView()
        setupStyle()
        setupConstraints()
        bindViewModel()
    }
    
    init(viewModel: ReadOfflineViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        view.subviews {
            topView.subviews {
                backButton
                titleLabel
                reloadButton
                deleteButton
            }
            
            articlesTableView
            loadingIndicator
            emptyStateLabel
        }
    }
    
    private func bindViewModel() {
        viewModel.onArticlesUpdated = { [weak self] in
            guard let self = self else { return }
            print("DEBUG - ReadOfflineViewController: Articles updated, count: \(self.viewModel.numberOfArticles())")
            DispatchQueue.main.async {
                self.articlesTableView.reloadData()
                self.updateEmptyState()
            }
        }
        
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            guard let self = self else { return }
            print("DEBUG - ReadOfflineViewController: Loading state changed to: \(isLoading)")
            DispatchQueue.main.async {
                if isLoading {
                    self.loadingIndicator.startAnimating()
                } else {
                    self.loadingIndicator.stopAnimating()
                }
            }
        }
        
        viewModel.onError = { [weak self] errorMessage in
            guard let self = self else { return }
            print("DEBUG - ReadOfflineViewController: Error received: \(errorMessage)")
            DispatchQueue.main.async {
                self.showAlert(title: "Error", message: errorMessage)
            }
        }
    }
    
    private func updateEmptyState() {
        if viewModel.numberOfArticles() == 0 {
            emptyStateLabel.isHidden = false
            articlesTableView.isHidden = true
        } else {
            emptyStateLabel.isHidden = true
            articlesTableView.isHidden = false
        }
    }
    
    @objc private func backButtonTapped() {
        print("DEBUG - ReadOfflineViewController: Back button tapped")
        coordinator?.didFinishReadOffline()
    }
    
    @objc private func reloadArticles() {
        print("DEBUG - ReadOfflineViewController: Reload button tapped")
        viewModel.reloadLatestArticles { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    self.showAlert(title: "Success", message: message)
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func deleteArticles() {
        print("DEBUG - ReadOfflineViewController: Delete button tapped")
        viewModel.deleteAllArticles { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    self.showAlert(title: "Success", message: message)
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Setup UI
extension ReadOfflineViewController {
    private func setupStyle() {
        view.backgroundColor = UIColor.hexBackGround
        topView.backgroundColor = UIColor.hexRed
        
        titleLabel.text = "Read Offline"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        
        backButton.setImage(UIImage(named: "ic_back_button"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        reloadButton.setImage(UIImage(named: "ic_reload_button"), for: .normal)
        reloadButton.addTarget(self, action: #selector(reloadArticles), for: .touchUpInside)
        
        deleteButton.setImage(UIImage(named: "ic_trash_button"), for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteArticles), for: .touchUpInside)
        
        articlesTableView.register(ReadOfflineTableViewCell.self,
                                   forCellReuseIdentifier: ReadOfflineTableViewCell.identifier)
        articlesTableView.dataSource = self
        articlesTableView.delegate = self
        articlesTableView.estimatedRowHeight = 100
        articlesTableView.rowHeight = UITableView.automaticDimension
        articlesTableView.backgroundColor = .clear
        articlesTableView.separatorStyle = .none
        
        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = true
        
        emptyStateLabel.text = "No offline articles available.\nTap the reload button to download articles."
        emptyStateLabel.font = .systemFont(ofSize: 16)
        emptyStateLabel.textColor = .white
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        
        updateEmptyState()
    }
    
    private func setupConstraints() {
        topView.top(0).leading(0).trailing(0)
        topView.Height == view.Height * 0.15
        
        backButton.Leading == topView.Leading + 20
        backButton.Bottom == topView.Bottom - 15
        backButton.width(30).height(30)
        
        titleLabel.CenterY == backButton.CenterY
        titleLabel.CenterX == topView.CenterX
        
        deleteButton.CenterY == backButton.CenterY
        deleteButton.Trailing == topView.Trailing - 20
        deleteButton.width(30).height(30)
        
        reloadButton.CenterY == backButton.CenterY
        reloadButton.Trailing == deleteButton.Leading - 5
        reloadButton.width(30).height(30)
        
        articlesTableView.Top == topView.Bottom + 10
        articlesTableView.Leading == view.Leading
        articlesTableView.Trailing == view.Trailing
        articlesTableView.Bottom == view.Bottom
        
        loadingIndicator.centerInContainer()
        loadingIndicator.width(40).height(40)
        
        emptyStateLabel.centerInContainer()
        emptyStateLabel.Leading == view.Leading + 40
        emptyStateLabel.Trailing == view.Trailing - 40
    }
}

// MARK: - TableView Delegate, Datasource
extension ReadOfflineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfArticles()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = articlesTableView.dequeueReusableCell(
            withIdentifier: ReadOfflineTableViewCell.identifier,
            for: indexPath
        ) as? ReadOfflineTableViewCell else {
            return UITableViewCell()
        }
        
        if let article = viewModel.article(at: indexPath.row) {
            let timeAgo = viewModel.formatTimeAgo(from: article.pubDate)
            cell.configure(with: article, timeAgo: timeAgo)
            print("DEBUG - ReadOfflineViewController: Configured cell with article: \(article.title ?? "Unknown")")
        }
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        articlesTableView.deselectRow(at: indexPath, animated: true)
        print("DEBUG - ReadOfflineViewController: Selected article at index: \(indexPath.row)")
        
        if let article = viewModel.article(at: indexPath.row) {
            print("DEBUG - ReadOfflineViewController: Opening article: \(article.title ?? "Unknown")")
            coordinator?.showArticleDetail(article, selectedCategory: "offline")
        }
    }
}
