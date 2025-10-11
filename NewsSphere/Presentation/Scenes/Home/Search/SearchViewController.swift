//
//  SearchViewController.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 12/3/25.
//

import UIKit
import Stevia

class SearchViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: SearchViewModel
    var coordinator: HomeCoordinator?

    // MARK: - UI Elements
    private lazy var titleSearch = UILabel()
    private lazy var backButton = UIButton()
    private lazy var viewHeader = UIView()
    private lazy var historySearch = UILabel()
    private lazy var underlineView = UIView()
    private lazy var searchList = UITableView()
    private lazy var searchBar = UISearchBar()
    private lazy var resultsTableView = UITableView()
    private lazy var noResultsLabel = UILabel()
    private lazy var loadingIndicator = UIActivityIndicatorView(style: .medium)

    private var searchTimer: Timer?
    private let debounceTime: TimeInterval = 0.5

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupView()
        setupStyle()
        setupConstraints()
        setupBindings()
        
        // Add theme change observer
        ThemeManager.shared.addThemeChangeObserver(self, selector: #selector(updateThemeBasedUI))
    }
    
    deinit {
        ThemeManager.shared.removeThemeChangeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updateThemeBasedUI() // Apply theme when view appears
    }
    
    @objc private func updateThemeBasedUI() {
        // Update background colors
        view.backgroundColor = .themeBackgroundColor()
        searchList.backgroundColor = .clear
        resultsTableView.backgroundColor = .clear
        
        // Update text colors
        historySearch.textColor = .primaryTextColor
        noResultsLabel.textColor = .primaryTextColor
        
        // Update search bar appearance
        let isLightMode = ThemeManager.shared.currentTheme.isLight
        searchBar.barTintColor = isLightMode ? .white : .hexDarkGrey
        searchBar.searchTextField.backgroundColor = isLightMode ? .white : .clear
        searchBar.searchTextField.textColor = isLightMode ? .black : .white
        searchBar.layer.borderColor = UIColor.borderColor.cgColor
        
        // Update loading indicator color
        loadingIndicator.color = .primaryTextColor
        
        // Reload tables to update cells
        searchList.reloadData()
        resultsTableView.reloadData()
    }

    // MARK: - ViewModel Bindings
    private func setupBindings() {
        viewModel.searchHistory.bind { [weak self] _ in
            self?.searchList.reloadData()
        }

        viewModel.articles.bind { [weak self] articles in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if articles.isEmpty && self.searchBar.text?.isEmpty == false {
                    self.resultsTableView.isHidden = true
                    self.noResultsLabel.isHidden = false
                    self.noResultsLabel.text = "No results found for \"\(self.searchBar.text ?? "")\""
                    self.searchList.isHidden = true
                    self.historySearch.isHidden = true
                    self.underlineView.isHidden = true
                } else if !articles.isEmpty {
                    self.resultsTableView.isHidden = false
                    self.noResultsLabel.isHidden = true
                    self.searchList.isHidden = true
                    self.historySearch.isHidden = true
                    self.underlineView.isHidden = true
                    self.resultsTableView.reloadData()
                } else {
                    self.resultsTableView.isHidden = true
                    self.noResultsLabel.isHidden = true
                    self.searchList.isHidden = false
                    self.historySearch.isHidden = false
                    self.underlineView.isHidden = false
                }
            }
        }

        viewModel.isLoading.bind { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                    self?.loadingIndicator.isHidden = false
                } else {
                    self?.loadingIndicator.stopAnimating()
                    self?.loadingIndicator.isHidden = true
                }
            }
        }

        viewModel.error.bind { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showError(error)
                }
            }
        }
    }

    // MARK: - Error Display
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Search Handling
    private func handleSearch(_ query: String) {
        if query.isEmpty {
            viewModel.clearSearchResults()
        } else {
            viewModel.searchArticles(with: query)
        }
    }
}

// MARK: - UI Setup
extension SearchViewController {
    private func setupView() {
        view.subviews {
            viewHeader.subviews {
                titleSearch
                backButton
            }
            searchBar
            loadingIndicator
            historySearch
            underlineView
            searchList
            resultsTableView
            noResultsLabel
        }
    }

    private func setupStyle() {
        view.backgroundColor = .themeBackgroundColor()
        title = "Search"
        
        // Search bar styling - will be updated in updateThemeBasedUI
        searchBar.isTranslucent = false
        searchBar.backgroundColor = .clear
        searchBar.layer.borderWidth = 1
        searchBar.layer.cornerRadius = 10
        searchBar.clipsToBounds = true
        searchBar.placeholder = "Search"
        searchBar.delegate = self

        // Keep red header and white text on header regardless of theme
        viewHeader.backgroundColor = .hexRed
        titleSearch.text = "Search"
        titleSearch.textColor = .white
        titleSearch.font = .systemFont(ofSize: 24, weight: .bold)
        titleSearch.textAlignment = .center

        backButton.setImage(UIImage(named: "ic_back_button"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.isUserInteractionEnabled = true

        historySearch.text = "History"
        historySearch.font = .systemFont(ofSize: 18, weight: .semibold)
        // Text color will be set in updateThemeBasedUI

        underlineView.backgroundColor = .borderColor

        searchList.showsHorizontalScrollIndicator = false
        searchList.showsVerticalScrollIndicator = false
        searchList.backgroundColor = .clear
        searchList.separatorStyle = .none
        searchList.delegate = self
        searchList.dataSource = self
        searchList.estimatedRowHeight = 60
        searchList.rowHeight = UITableView.automaticDimension
        searchList.register(SearchListTableViewCell.self,
                            forCellReuseIdentifier: SearchListTableViewCell.identifier)

        resultsTableView.showsHorizontalScrollIndicator = false
        resultsTableView.showsVerticalScrollIndicator = false
        resultsTableView.backgroundColor = .clear
        resultsTableView.separatorStyle = .none
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.estimatedRowHeight = 120
        resultsTableView.rowHeight = UITableView.automaticDimension
        resultsTableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: "SearchResultArticleCell")
        resultsTableView.isHidden = true

        noResultsLabel.font = .systemFont(ofSize: 16)
        noResultsLabel.textAlignment = .center
        noResultsLabel.numberOfLines = 0
        noResultsLabel.isHidden = true
        // Text color will be set in updateThemeBasedUI

        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.isHidden = true
        // Color will be set in updateThemeBasedUI
    }

    private func setupConstraints() {
        viewHeader.top(0).leading(0).trailing(0)
        viewHeader.Height == view.Height * 0.15
        
        backButton.Leading == viewHeader.Leading + 20
        backButton.Bottom == viewHeader.Bottom - 15
        backButton.width(30).height(30)
                
        searchBar.height(60).left(15).right(16)
        historySearch.left(16)
        underlineView.height(0.5).left(16).right(16)
        searchList.left(0).right(0).bottom(0)
        
        titleSearch.CenterX == viewHeader.CenterX
        titleSearch.CenterY == backButton.CenterY

        searchBar.Top == viewHeader.Bottom + 50

        historySearch.Top == searchBar.Bottom + 24
        underlineView.Top == historySearch.Bottom + 12
        searchList.Top == underlineView.Bottom + 8

        resultsTableView.left(0).right(0).bottom(0)
        resultsTableView.Top == searchBar.Bottom + 16

        noResultsLabel.centerHorizontally()
        noResultsLabel.Top == searchBar.Bottom + 100
        noResultsLabel.width(300)

        loadingIndicator.centerHorizontally()
        loadingIndicator.Top == searchBar.Bottom + 50
    }
}

// MARK: - Button Actions
extension SearchViewController {
    @objc private func backButtonTapped() {
        print("Back button tapped")
        if coordinator == nil {
            print("ERROR: Coordinator is nil in SearchViewController!")
        }
        coordinator?.navigationController.popViewController(animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer?.invalidate()

        if searchText.isEmpty {
            viewModel.clearSearchResults()
        } else {
            searchTimer = Timer.scheduledTimer(withTimeInterval: debounceTime, repeats: false) { [weak self] _ in
                self?.handleSearch(searchText)
            }
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searchBar.text, !text.isEmpty {
            searchTimer?.invalidate()
            handleSearch(text)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchList {
            return viewModel.searchHistory.value.count
        } else if tableView == resultsTableView {
            return viewModel.articles.value.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == searchList {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchListTableViewCell.identifier,
                for: indexPath
            ) as? SearchListTableViewCell else {
                return UITableViewCell()
            }

            let historyItem = viewModel.searchHistory.value[indexPath.row]
            cell.configure(with: historyItem.keyword)
            cell.delegate = self
            return cell
        } else if tableView == resultsTableView {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "SearchResultArticleCell",
                for: indexPath
            ) as? ArticleTableViewCell else {
                return UITableViewCell()
            }

            let article = viewModel.articles.value[indexPath.row]
            let timeAgo = viewModel.formatTimeAgo(from: article.pubDate)
            cell.configure(with: article, timeAgo: timeAgo)
            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == searchList {
            let selectedKeyword = viewModel.searchHistory.value[indexPath.row]
            searchBar.text = selectedKeyword.keyword
            handleSearch(selectedKeyword.keyword)
            searchBar.resignFirstResponder()

            tableView.deselectRow(at: indexPath, animated: true)
        } else if tableView == resultsTableView {
            let selectedArticle = viewModel.articles.value[indexPath.row]
            // Get the original category of the article if available
            let originalCategory = viewModel.getArticleCategory(at: indexPath.row)
            coordinator?.showArticleDetail(selectedArticle, selectedCategory: originalCategory ?? "Search Results")
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

// MARK: - SearchListTableViewCellDelegate
extension SearchViewController: SearchListTableViewCellDelegate {
    func didTapOptionButton(in cell: SearchListTableViewCell) {
        guard let keyword = cell.keyword else { return }
        viewModel.deleteSearchKeyword(keyword)
    }
}
