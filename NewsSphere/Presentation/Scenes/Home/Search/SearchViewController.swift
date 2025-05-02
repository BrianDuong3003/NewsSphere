//
//  SearchViewController.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 12/3/25.
//

import UIKit
import Stevia

class SearchViewController: UIViewController {
    private let viewModel = SearchViewModel()
    private lazy var titleSearch = UILabel()
    private lazy var backButton = UIButton()
    private lazy var viewHeader = UIView()
    private lazy var historySearch = UILabel()
    private lazy var underlineView = UIView()
    private lazy var searchList = UITableView()
    private lazy var textField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpConstranist()
        setupBindings()
        viewModel.searchHistory.bind { [weak self] _ in
            self?.searchList.reloadData()
        }
        
    }
    private func setupBindings() {
        viewModel.searchHistory.bind { [weak self] _ in
            self?.searchList.reloadData()
        }
        viewModel.articles.bind { articles in
            debugPrint("Articles fetched: \(articles)")
        }
    }
    private func handleSearch(_ query: String) {
        viewModel.searchArticles(with: query)
    }
}
extension SearchViewController {
    private func setUpUI() {
        textField.delegate = self
        
        titleSearch.style {
            $0.text = "Search"
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 24, weight: .semibold)
            $0.textAlignment = .center
        }
        backButton.style {
            $0.setImage(UIImage(named: "ic_back"), for: .normal)
        }
        viewHeader.style {
            $0.backgroundColor = .hexRed
        }
        historySearch.style {
            $0.text = "History"
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 18, weight: .semibold)
        }
        underlineView.style {
            $0.backgroundColor = .darkGray
        }
        textField.style {
            $0.backgroundColor = .lightGray
            $0.layer.cornerRadius = 10
            $0.placeholder = "Search..."
            $0.textAlignment = .left
            
        }
        searchList.style {
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.backgroundColor = .clear
            $0.separatorStyle = .none
            $0.delegate = self
            $0.dataSource = self
            $0.estimatedRowHeight = 60
            $0.rowHeight = UITableView.automaticDimension
            $0.register(SearchListTableViewCell.self,
                        forCellReuseIdentifier: SearchListTableViewCell.identifier)
        }
    }
    private func setUpConstranist() {
        view.subviews {
            viewHeader
            textField
            historySearch
            underlineView
            searchList
        }
        
        viewHeader.subviews {
            backButton
            titleSearch
        }
        
        // Header View
        viewHeader.height(100).top(0).left(0).right(0)
        
        // Back Button
        backButton.left(16)
        backButton.CenterY == titleSearch.CenterY
        backButton.width(30).height(30)
        
        // Title
        titleSearch.centerHorizontally()
        titleSearch.Top == viewHeader.Top + 65
        
        // Search TextField
        textField.height(40).left(16).right(16)
        textField.Top == viewHeader.Bottom + 16
        
        // History Label
        historySearch.left(16)
        historySearch.Top == textField.Bottom + 24
        
        // Underline
        underlineView.height(0.5).left(16).right(16)
        underlineView.Top == historySearch.Bottom + 12
        
        // Table View (Search List)
        searchList.left(0).right(0).bottom(0)
        searchList.Top == underlineView.Bottom + 8
    }
}
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text, !text.isEmpty {
            handleSearch(text)
        }
        return true
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchHistory.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchListTableViewCell.identifier,
            for: indexPath
        ) as? SearchListTableViewCell else {
            return UITableViewCell()
        }
        
        let history = viewModel.searchHistory.value[indexPath.row]
        cell.configure(with: history.keyword)
        cell.delegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedKeyword = viewModel.searchHistory.value[indexPath.row]
        textField.text = selectedKeyword.keyword
        handleSearch(selectedKeyword.keyword)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
extension SearchViewController: SearchListTableViewCellDelegate {
    func didTapOptionButton(in cell: SearchListTableViewCell) {
        guard let keyword = cell.keyword else { return }
        viewModel.deleteSearchKeyword(keyword)
    }
}
