//
//  CategoryArticlesCell.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 7/4/25.
//

import UIKit
import Stevia
import Kingfisher

class CategoryArticlesCell: UICollectionViewCell {
    private lazy var picture = UIImageView()
    private lazy var sourceIcon = UIImageView()
    private lazy var sourceName = UILabel()
    private lazy var titleLabel = UILabel()
    private lazy var categoryLB = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sourceIcon.layer.cornerRadius = sourceIcon.frame.width / 2
        sourceIcon.clipsToBounds = true
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
        titleLabel.textColor = isLightMode ? .black : .white
        sourceName.textColor = .secondaryTextColor
    }
    
    func configure(with article: Article) {
        titleLabel.text = article.title
        sourceName.text = article.sourceName
        categoryLB.text = article.category?.first?.capitalized ?? "Unknown"
        
        if let imageUrl = article.imageUrl, let url = URL(string: imageUrl) {
            picture.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholder_image"),
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]
            )
        } else {
            picture.image = UIImage(named: "placeholder_image")
        }
        
        if let iconUrl = article.sourceIcon, let url = URL(string: iconUrl) {
            sourceIcon.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholder_icon"),
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]
            )
        } else {
            sourceIcon.image = UIImage(named: "placeholder_icon")
        }
        
        updateThemeBasedUI()
    }
}

extension CategoryArticlesCell {
    private func setupView() {
        subviews {
            picture
            sourceIcon
            sourceName
            titleLabel
            categoryLB
        }
    }
    
    private func setupStyle() {
        picture.layer.cornerRadius = 8
        picture.clipsToBounds = true
        picture.contentMode = .scaleAspectFill
        
        sourceIcon.contentMode = .scaleAspectFill
        sourceIcon.backgroundColor = .lightGray
        
        sourceName.font = .systemFont(ofSize: 14, weight: .regular)
        
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.numberOfLines = 0
        
        categoryLB.textColor = .hexOrange
        categoryLB.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
    private func setupConstraints() {
        picture.height(175)
            .centerHorizontally()
            .top(0)
        
        sourceIcon.left(8)
            .width(28)
            .height(28)
            .Top == picture.Bottom + 10
        
        sourceName.left(44).right(12).centerVertically()
        sourceName.height(15)
            .Left == sourceIcon.Right + 8
        align(horizontally: sourceIcon, sourceName)
        
        titleLabel.bottom(28)
            .left(8)
            .height(50)
            .width(360)
            .Top == sourceName.Bottom + 10
        
        categoryLB.left(8).right(12).bottom(12)
        categoryLB.Top == titleLabel.Bottom + 6
    }
}
