//
//  VerticalViewCell.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 19/3/25.
//

import UIKit
import Stevia
import SDWebImage

class VerticalViewCell: UICollectionViewCell {
    private lazy var background = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var authorImage = UIImageView()
    private lazy var authorName = UILabel()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupStyle()
        setupConstraints()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeChanged),
            name: ThemeManager.themeChangedNotification,
            object: nil
        )
        
        updateThemeBasedUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupStyle()
        setupConstraints()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeChanged),
            name: ThemeManager.themeChangedNotification,
            object: nil
        )
        
        updateThemeBasedUI()
    }
    
    @objc private func themeChanged() {
        updateThemeBasedUI()
    }
    
    private func updateThemeBasedUI() {
        let isLightMode = ThemeManager.shared.currentTheme.isLight
        
        // Update text colors based on theme
        titleLabel.textColor = isLightMode ? .black : .white
        authorName.textColor = .secondaryTextColor
    }
    
    // MARK: - Setup View
    private func setupView() {
        subviews(background,
                 authorImage,
                 authorName,
                 titleLabel)
    }
    
    func setupStyle() {
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        
        background.image = UIImage(named: "rectangle7")
        background.contentMode = .scaleAspectFit
        
        authorImage.image = UIImage(named: "ellipse1")
        authorImage.contentMode = .scaleAspectFill
        authorImage.layer.cornerRadius = 10
        authorImage.clipsToBounds = true
        
        authorName.text = "Reuters"
        authorName.font = .systemFont(ofSize: 14, weight: .medium)
        
        titleLabel.text = "Apple's foldable iPhone is expected to save a surprisingly declining market"
        titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        titleLabel.numberOfLines = 3
        titleLabel.lineBreakMode = .byTruncatingTail
    }
    
    func setupConstraints() {
        background.height(175)
            .centerHorizontally()
        
        titleLabel.bottom(28)
            .left(8)
            .height(50)
            .width(360)
            .Top == authorImage.Bottom + 10
        
        authorImage.left(8)
            .width(28)
            .height(28)
            .Top == background.Bottom + 10
        
        authorName.height(15)
            .Left == authorImage.Right + 8
        align(horizontally: authorImage, authorName)
    }
    
    func configure(articles: Article) {
        titleLabel.text = articles.title
        authorName.text = articles.sourceName
        
        if let articleImg = articles.imageUrl, let url = URL(string: articleImg) {
            background.sd_setImage(with: url, placeholderImage: UIImage(named: "rectangle7"))
        } else {
            background.image = UIImage(named: "rectangle7")
        }
        
        if let authorImg = articles.sourceIcon, let url = URL(string: authorImg) {
            authorImage.sd_setImage(with: url, placeholderImage: UIImage(named: "ellipse1"))
        } else {
            authorImage.image = UIImage(named: "ellipse1")
        }
        
        updateThemeBasedUI()
    }
}
