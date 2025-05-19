//
//  HorizontalViewCell.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 19/3/25.
//

import UIKit
import Stevia
import Kingfisher

class HorizontalViewCell: UICollectionViewCell {
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
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupStyle()
        setupConstraints()
    }
    
    // MARK: - Setup View
    private func setupView() {
        subviews {
            background
            titleLabel
            authorImage
            authorName
        }
    }
    
    private func setupStyle() {
        contentView.layer.cornerRadius = 8
        contentView.backgroundColor = .brown
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.clipsToBounds = true
        
        background.contentMode = .scaleAspectFill
        background.image = UIImage(named: "rectangle5")
        
        authorImage.image = UIImage(named: "ellipse1")
        authorImage.contentMode = .scaleAspectFill
        authorImage.layer.cornerRadius = 10
        authorImage.clipsToBounds = true
        
        authorName.text = "U.S.News"
        authorName.textColor = .white
        authorName.font = .systemFont(ofSize: 15, weight: .medium)
        
        titleLabel.text = "Political Storms Hit Florida Before Hurricane Milton Makes Landfall"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 3
        titleLabel.lineBreakMode = .byTruncatingTail
    }
    
    private func setupConstraints() {
        background
            .height(200)
            .centerHorizontally()
        
        authorImage
            .left(20)
            .width(30)
            .height(30)
        
        authorName.CenterY == authorImage.CenterY
        authorName.Left == authorImage.Right + 8
        
        titleLabel.bottom(20)
            .left(40)
            .right(15)
            .width(340)
            .height(40)
            .Top == authorImage.Bottom + 15
    }
    
    func configure(articles: Article) {
        titleLabel.text = articles.title
        authorName.text = articles.sourceName
        
        if let articleImg = articles.imageUrl, let url = URL(string: articleImg) {
            background.kf.setImage(
                with: url,
                placeholder: UIImage(named: "rectangle5"),
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]
            )
        } else {
            background.image = UIImage(named: "rectangle5")
        }
        
        if let authorImg = articles.sourceIcon, let url = URL(string: authorImg) {
            authorImage.kf.setImage(
                with: url,
                placeholder: UIImage(named: "ellipse1"),
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]
            )
        } else {
            authorImage.image = UIImage(named: "ellipse1")
        }
    }
}
