import UIKit
import Stevia

class BookmarkViewController: UIViewController {
    
    private lazy var topView = UIView()
    private lazy var titleLabel = UILabel()
    private lazy var tableView = UITableView()
    private var bookmarkedArticles: [Article] = []
    private lazy var backButton = UIButton()
    var viewModel: BookmarkViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStyle()
        setupConstraints()
        bindViewModel()
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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(BookmarkTableViewCell.self,
                      forCellReuseIdentifier: BookmarkTableViewCell.identifier)
    }
    
    private func setupConstraints() {
        topView.top(0).leading(0).trailing(0)
        backButton.width(24).height(24)
        
        topView.Height == view.Height * 0.15
        
        backButton.Leading == topView.Leading + 16
        backButton.Bottom == topView.Bottom - 12
        
        titleLabel.CenterX == topView.CenterX
        titleLabel.CenterY == backButton.CenterY
        
        tableView.Top == topView.Bottom
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
            withIdentifier: BookmarkTableViewCell.identifier,
            for: indexPath
        ) as? BookmarkTableViewCell else {
            return UITableViewCell()
        }
        
        if indexPath.row < viewModel.numberOfArticles() {
            let article = viewModel.article(at: indexPath.row)
            cell.configure(with: article)
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
