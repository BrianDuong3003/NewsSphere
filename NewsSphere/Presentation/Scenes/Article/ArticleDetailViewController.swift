//
//  ArticleDetailViewController.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import UIKit
import Stevia

class ArticleDetailViewController: UIViewController {
    
    // MARK: - UI Elements
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = ArticleContentView()
    
    private lazy var headerView = UIView()
    private lazy var backButton = UIButton()
    private lazy var shareButton = UIButton()
    private lazy var textSizeButton = UIButton()
    private lazy var bookmarkButton = UIButton()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Properties
    var viewModel: ArticleDetailViewModel!
    private var webViewContainer: WebViewContainer?
    private var backToContentButton: UIButton?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        guard viewModel != nil else {
            fatalError("ViewModel must be set before viewDidLoad")
        }
        setupView()
        setupStyle()
        setupConstraints()
        bindViewModel()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupView() {
        view.subviews {
            headerView.subviews {
                backButton
                shareButton
                textSizeButton
                bookmarkButton
            }
            scrollView.subviews {
                contentView
            }
            loadingIndicator
        }
    }
    
    private func bindViewModel() {
        viewModel.article.bind { [weak self] article in
            guard let self = self, let article = article else { return }
            self.contentView.configure(with: article, selectedCategory: viewModel.selectedCategory)
        }
        
        viewModel.isLoading.bind { [weak self] isLoading in
            guard let self = self else { return }
            if isLoading {
                self.loadingIndicator.startAnimating()
            } else {
                self.loadingIndicator.stopAnimating()
            }
        }
        
        viewModel.isBookmarked.bind { [weak self] isBookmarked in
            guard let self = self else { return }
            let imageName = isBookmarked ? "bookmark.fill" : "bookmark"
            self.bookmarkButton.setImage(UIImage(systemName: imageName), for: .normal)
        }

        viewModel.currentFontSize.bind { [weak self] fontSize in
            guard let self = self else { return }
            self.contentView.updateFontSize(fontSize)
        }
    }
}

// MARK: - Setup UI
extension ArticleDetailViewController {
    private func setupStyle() {
        view.backgroundColor = UIColor.hexBackGround
        
        headerView.backgroundColor = UIColor.hexRed
        
        backButton.setImage(UIImage(named: "ic_back_button"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        shareButton.setImage(UIImage(named: "share"), for: .normal)
        shareButton.tintColor = UIColor.hexGrey
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        
        textSizeButton.setImage(UIImage(named: "textSize"), for: .normal)
        textSizeButton.tintColor = .white
        textSizeButton.addTarget(self, action: #selector(textSizeButtonTapped), for: .touchUpInside)
        
        bookmarkButton.tintColor = .white
        bookmarkButton.addTarget(self, action: #selector(bookmarkButtonTapped), for: .touchUpInside)

        contentView.delegate = self
        
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
    }
    
    private func setupConstraints() {
        headerView.top(0).leading(0).trailing(0)
        headerView.Height == view.Height * 0.13
        
        backButton.Leading == headerView.Leading + 20
        backButton.Bottom == headerView.Bottom - 15
        backButton.width(30).height(30)
        
        bookmarkButton.Trailing == headerView.Trailing - 16
        bookmarkButton.Bottom == headerView.Bottom - 12
        bookmarkButton.width(30).height(30)
        
        textSizeButton.Trailing == bookmarkButton.Leading - 20
        textSizeButton.Bottom == headerView.Bottom - 12
        textSizeButton.width(30).height(30)
        
        shareButton.Trailing == textSizeButton.Leading - 20
        shareButton.Bottom == headerView.Bottom - 12
        shareButton.width(30).height(30)
        
        scrollView.Top == headerView.Bottom
        scrollView.leading(0).trailing(0).bottom(0)
        
        contentView.top(0).leading(0).trailing(0).bottom(0)
        contentView.Width == scrollView.Width
        
        loadingIndicator.centerInContainer()
    }
    
    // MARK: - Action Handlers
    @objc private func backButtonTapped() {
        guard let viewModel = viewModel else { return }
        viewModel.navigateBack()
    }
    
    @objc private func shareButtonTapped() {
        guard let viewModel = viewModel else { return }
        viewModel.shareArticle()
    }
    
    @objc private func textSizeButtonTapped() {
        showFontSizeActionSheet()
    }
    
    @objc private func bookmarkButtonTapped() {
        guard let viewModel = viewModel else { return }
        viewModel.toggleBookmark()
    }
    
    // MARK: - Helper Methods
    private func showFontSizeActionSheet() {
        let actionSheet = UIAlertController(title: "", message: "Choose Font Size",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Small", style: .default) { [weak self] _ in
            self?.changeFontSize(to: 13.0)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Medium", style: .default) { [weak self] _ in
            self?.changeFontSize(to: 15.0)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Large", style: .default) { [weak self] _ in
            self?.changeFontSize(to: 17.0)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    private func changeFontSize(to size: CGFloat) {
        guard let viewModel = viewModel else { return }
        viewModel.changeFontSize(to: size)
    }
    
    private func saveArticleToBookmark() {
        
    }
    
    private func removeArticleFromBookmark() {
        
    }
}

// MARK: - ArticleContentViewDelegate
extension ArticleDetailViewController: ArticleContentViewDelegate {
    func seeFullContentButtonTapped() {
        guard let viewModel = viewModel,
              let article = viewModel.article.value,
              let urlString = article.link else { return }
        
        showInAppWebView(for: urlString)
    }
   
    private func showInAppWebView(for urlString: String) {
        if webViewContainer == nil {
            webViewContainer = WebViewContainer(frame: .zero)
            if let webViewContainer = webViewContainer {
                view.addSubview(webViewContainer)
                webViewContainer.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    webViewContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor),
                    webViewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    webViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    webViewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
                
                webViewContainer.webView.scrollView.isScrollEnabled = true
            }
        }
        
        scrollView.isHidden = true
        webViewContainer?.isHidden = false
        webViewContainer?.loadURL(urlString)
    }
}
