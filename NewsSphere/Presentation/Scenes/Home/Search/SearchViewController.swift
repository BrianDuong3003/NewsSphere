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
    weak var coordinator: HomeCoordinator?
    
    private lazy var titleSearch = UILabel()
    private lazy var backButton = UIButton()
    private lazy var viewHeader = UIView()
    private lazy var historySearch = UILabel()
    private lazy var underlineView = UIView()
    private lazy var searchList = UITableView()
    private lazy var textField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStyle()
        setupConstraints()
        setupBindings()
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
    private func setupView() {
        view.subviews {
            viewHeader.subviews {
                backButton
                titleSearch
            }
            textField
            historySearch
            underlineView
            searchList
        }
    }
    
    private func setupStyle() {
        view.backgroundColor = .hexBackGround
        
        textField.delegate = self
        
        titleSearch.text = "Search"
        titleSearch.textColor = .white
        titleSearch.font = .systemFont(ofSize: 24, weight: .semibold)
        titleSearch.textAlignment = .center
        
        backButton.setImage(UIImage(named: "ic_back"), for: .normal)
        
        viewHeader.backgroundColor = .hexRed
        
        historySearch.text = "History"
        historySearch.textColor = .white
        historySearch.font = .systemFont(ofSize: 18, weight: .semibold)
        
        underlineView.backgroundColor = .darkGray
        
        textField.backgroundColor = .lightGray
        textField.layer.cornerRadius = 10
        textField.placeholder = "Search..."
        textField.textAlignment = .left
        
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
    }
    
    private func setupConstraints() {
        viewHeader.height(100).top(0).left(0).right(0)
        backButton.left(16).width(30).height(30)
        textField.height(40).left(16).right(16)
        historySearch.left(16)
        underlineView.height(0.5).left(16).right(16)
        searchList.left(0).right(0).bottom(0)
        
        backButton.CenterY == titleSearch.CenterY
        
        titleSearch.centerHorizontally()
        titleSearch.Top == viewHeader.Top + 65
        
        textField.Top == viewHeader.Bottom + 16
        historySearch.Top == textField.Bottom + 24
        underlineView.Top == historySearch.Bottom + 12
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
