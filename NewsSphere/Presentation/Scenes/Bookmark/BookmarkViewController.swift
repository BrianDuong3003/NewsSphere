import UIKit
import Stevia

class BookmarkViewController: UIViewController {
    
    private lazy var topView = UIView()
    private lazy var titleLabel = UILabel()
    private lazy var tableView = UITableView()
    private var bookmarkedArticles: [Article] = []
    private lazy var backButton = UIButton()
    
    var viewModel: BookmarkViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStyle()
        setupConstraints()
        bindViewModel()
    }
    
    init(viewModel: BookmarkViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindViewModel() {
        viewModel.bookmarkedArticles.bind { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadBookmarks()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @objc private func backButtonTapped() {
        viewModel.navigateBack()
    }
}

extension BookmarkViewController {
    private func setupView() {
        view.subviews {
            topView
            backButton
            titleLabel
            tableView
        }
    }
    
    private func setupStyle() {
        view.backgroundColor = UIColor.hexBackGround
        topView.backgroundColor = UIColor(.hexRed)
        
        backButton.setImage(UIImage(named: "ic_back_button"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        titleLabel.text = "Bookmark"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        
        tableView.backgroundColor = UIColor(.hexBackGround)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(ArticleTableViewCell.self,
                           forCellReuseIdentifier: ArticleTableViewCell.identifierBookmark)
    }
    
    private func setupConstraints() {
        topView.top(0).leading(0).trailing(0)
        topView.Height == view.Height * 0.15
        
        backButton.Leading == topView.Leading + 20
        backButton.Bottom == topView.Bottom - 15
        backButton.width(30).height(30)
        
        backButton.Leading == topView.Leading + 16
        backButton.Bottom == topView.Bottom - 12
        
        titleLabel.CenterX == topView.CenterX
        titleLabel.CenterY == backButton.CenterY
        
        tableView.Top == topView.Bottom + 10
        tableView.Leading == view.Leading
        tableView.Trailing == view.Trailing
        tableView.Bottom == view.Bottom
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension BookmarkViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfArticles()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ArticleTableViewCell.identifierBookmark,
            for: indexPath
        ) as? ArticleTableViewCell else {
            return UITableViewCell()
        }
        
        if indexPath.row < viewModel.numberOfArticles() {
            let article = viewModel.article(at: indexPath.row)
            let timeAgo = viewModel.formatTimeAgo(from: article.pubDate)
            cell.configure(with: article, timeAgo: timeAgo)
        }
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.navigateToArticleDetail(at: indexPath.row)
    }
}
