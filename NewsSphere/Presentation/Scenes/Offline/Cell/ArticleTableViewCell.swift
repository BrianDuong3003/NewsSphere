//
//  ArticleTableViewCell.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 14/3/25.
//

import UIKit
import Stevia
import Kingfisher

class ArticleTableViewCell: UITableViewCell {
    static let identifierOffline = "ReadOfflineTableViewCell"
    static let identifierBookmark = "BookmarkTableViewCell"
    
    private lazy var articleTitle = UILabel()
    private lazy var articleImage = UIImageView()
    private lazy var timeLabel = UILabel()
    private lazy var sourceName = UILabel()
    private lazy var indicatorView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupStyle()
        setupConstraints()
        
        // Add theme change observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeChanged),
            name: ThemeManager.themeChangedNotification,
            object: nil
        )
        
        // Apply initial theme
        updateThemeBasedUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func themeChanged() {
        updateThemeBasedUI()
    }
    
    private func updateThemeBasedUI() {
        let isLightMode = ThemeManager.shared.currentTheme.isLight
        
        // Update text colors based on theme
        articleTitle.textColor = isLightMode ? .black : .white
        indicatorView.backgroundColor = isLightMode ? .lightGray : .darkGray
        
        // Keep gray color for time and source
        timeLabel.textColor = UIColor.hexGrey
        sourceName.textColor = UIColor.hexGrey
    }
    
    // Configure cell with article data
    func configure(with article: Article, timeAgo: String) {
        articleTitle.text = article.title
        
        if let imageUrlString = article.imageUrl, let url = URL(string: imageUrlString) {
            articleImage.kf.setImage(with: url, placeholder: UIImage(named: "ic_example"))
        } else {
            articleImage.image = UIImage(named: "ic_example")
        }
        
        timeLabel.text = timeAgo
        sourceName.text = article.sourceName
        
        updateThemeBasedUI()
    }
}

// MARK: - Setup UI
extension ArticleTableViewCell {
    private func setupView() {
        subviews {
            articleTitle
            articleImage
            timeLabel
            sourceName
            indicatorView
        }
    }
    
    private func setupStyle() {
        backgroundColor = .clear
        
        articleTitle.font = .systemFont(ofSize: 15, weight: .medium)
        articleTitle.numberOfLines = 0
        
        articleImage.image = UIImage(named: "ic_example")
        articleImage.contentMode = .scaleAspectFill
        articleImage.clipsToBounds = true
        articleImage.layer.cornerRadius = 5
        
        timeLabel.text = "15h"
        timeLabel.font = .systemFont(ofSize: 13, weight: .medium)
        
        sourceName.text = "ABC News"
        sourceName.font = .systemFont(ofSize: 13, weight: .medium)
    }
    
    private func setupConstraints() {
        articleTitle.Top == contentView.Top + 5
        articleTitle.Leading == contentView.Leading + 10
        articleTitle.Trailing == articleImage.Leading - 5
        
        articleImage.CenterY == articleTitle.CenterY
        articleImage.Trailing == contentView.Trailing - 10
        articleImage.width(70).height(70)

        timeLabel.Top == articleTitle.Bottom + 20
        timeLabel.Leading == contentView.Leading + 10
        
        sourceName.CenterY == timeLabel.CenterY
        sourceName.Leading == timeLabel.Trailing + 20
        
        indicatorView.Top == timeLabel.Bottom + 15
        indicatorView.Leading == contentView.Leading + 10
        indicatorView.Trailing == contentView.Trailing - 10
        indicatorView.Bottom == contentView.Bottom - 20
        indicatorView.Height == 1
    }
}
